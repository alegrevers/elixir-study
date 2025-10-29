defmodule LibraryApiWeb.BookControllerTest do
  use LibraryApiWeb.ConnCase
  alias LibraryApi.Books

  @moduledoc """
  Testes de integração da API REST.
  Demonstram PATTERN MATCHING nas respostas HTTP.
  """

  setup do
    # Reseta stats antes de cada teste
    LibraryApi.StatsCache.reset_stats()
    :ok
  end

  describe "GET /api/books" do
    test "returns empty list when no books exist", %{conn: conn} do
      conn = get(conn, "/api/books")

      # Pattern matching: status 200 e lista vazia
      assert %{"data" => []} = json_response(conn, 200)
    end

    test "returns all books", %{conn: conn} do
      create_book(%{title: "Book 1", author: "Author 1", isbn: "1234567890123", year: 2020})
      create_book(%{title: "Book 2", author: "Author 2", isbn: "1234567890124", year: 2021})

      conn = get(conn, "/api/books")

      # Pattern matching: lista com 2 elementos
      assert %{"data" => books} = json_response(conn, 200)
      assert length(books) == 2
    end
  end

  describe "GET /api/books/:id" do
    test "returns book when id exists", %{conn: conn} do
      book = create_book(%{title: "Test Book", author: "Author", isbn: "1234567890123", year: 2020})

      conn = get(conn, "/api/books/#{book.id}")

      # Pattern matching: estrutura da resposta
      assert %{
        "data" => %{
          "id" => id,
          "title" => "Test Book",
          "author" => "Author"
        }
      } = json_response(conn, 200)

      assert id == book.id
    end

    test "returns 404 when book does not exist", %{conn: conn} do
      conn = get(conn, "/api/books/99999")

      # Pattern matching: erro 404
      assert %{"error" => "Book not found"} = json_response(conn, 404)
    end
  end

  describe "POST /api/books" do
    test "creates book with valid data", %{conn: conn} do
      attrs = %{
        "book" => %{
          "title" => "New Book",
          "author" => "New Author",
          "isbn" => "1234567890123",
          "year" => 2023
        }
      }

      conn = post(conn, "/api/books", attrs)

      # Pattern matching: status 201 (created)
      assert %{
        "data" => %{
          "id" => _id,
          "title" => "New Book",
          "available" => true
        }
      } = json_response(conn, 201)

      # Verifica que stats foram atualizadas (integração com GenServer)
      Process.sleep(10)
      stats = LibraryApi.StatsCache.get_stats()
      assert stats.books_created == 1
    end

    test "returns 422 with invalid data", %{conn: conn} do
      attrs = %{
        "book" => %{
          "title" => "AB",
          "author" => "",
          "isbn" => "123",
          "year" => 1000
        }
      }

      conn = post(conn, "/api/books", attrs)

      # Pattern matching: erro de validação
      assert %{"errors" => errors} = json_response(conn, 422)
      assert Map.has_key?(errors, "title")
      assert Map.has_key?(errors, "author")
      assert Map.has_key?(errors, "isbn")
      assert Map.has_key?(errors, "year")
    end
  end

  describe "PUT /api/books/:id" do
    test "updates book with valid data", %{conn: conn} do
      book = create_book(%{title: "Old Title", author: "Author", isbn: "1234567890123", year: 2020})

      attrs = %{"book" => %{"title" => "New Title"}}
      conn = put(conn, "/api/books/#{book.id}", attrs)

      # Pattern matching: sucesso na atualização
      assert %{
        "data" => %{
          "title" => "New Title",
          "author" => "Author"
        }
      } = json_response(conn, 200)

      # Verifica stats
      Process.sleep(10)
      stats = LibraryApi.StatsCache.get_stats()
      assert stats.books_updated == 1
    end

    test "returns 404 when book does not exist", %{conn: conn} do
      attrs = %{"book" => %{"title" => "New Title"}}
      conn = put(conn, "/api/books/99999", attrs)

      assert %{"error" => "Book not found"} = json_response(conn, 404)
    end

    test "returns 422 with invalid data", %{conn: conn} do
      book = create_book(%{title: "Title", author: "Author", isbn: "1234567890123", year: 2020})

      attrs = %{"book" => %{"year" => 1000}}
      conn = put(conn, "/api/books/#{book.id}", attrs)

      assert %{"errors" => _errors} = json_response(conn, 422)
    end
  end

  describe "DELETE /api/books/:id" do
    test "deletes existing book", %{conn: conn} do
      book = create_book(%{title: "Book", author: "Author", isbn: "1234567890123", year: 2020})

      conn = delete(conn, "/api/books/#{book.id}")

      # Pattern matching: status 204 (no content)
      assert response(conn, 204)

      # Verifica que foi deletado
      assert {:error, :not_found} = Books.get_book(book.id)

      # Verifica stats
      Process.sleep(10)
      stats = LibraryApi.StatsCache.get_stats()
      assert stats.books_deleted == 1
    end

    test "returns 404 when book does not exist", %{conn: conn} do
      conn = delete(conn, "/api/books/99999")

      assert %{"error" => "Book not found"} = json_response(conn, 404)
    end
  end

  describe "POST /api/books/:id/borrow" do
    test "borrows available book", %{conn: conn} do
      book = create_book(%{title: "Book", author: "Author", isbn: "1234567890123", year: 2020, available: true})

      conn = post(conn, "/api/books/#{book.id}/borrow")

      # Pattern matching: sucesso
      assert %{
        "data" => %{"available" => false},
        "message" => "Book borrowed successfully"
      } = json_response(conn, 200)

      # Verifica stats
      Process.sleep(10)
      stats = LibraryApi.StatsCache.get_stats()
      assert stats.books_borrowed == 1
    end

    test "returns 422 when book already borrowed", %{conn: conn} do
      book = create_book(%{title: "Book", author: "Author", isbn: "1234567890123", year: 2020, available: false})

      conn = post(conn, "/api/books/#{book.id}/borrow")

      # Pattern matching: erro específico
      assert %{"error" => "Book is already borrowed"} = json_response(conn, 422)
    end

    test "returns 404 when book does not exist", %{conn: conn} do
      conn = post(conn, "/api/books/99999/borrow")

      assert %{"error" => "Book not found"} = json_response(conn, 404)
    end
  end

  describe "POST /api/books/:id/return" do
    test "returns borrowed book", %{conn: conn} do
      book = create_book(%{title: "Book", author: "Author", isbn: "1234567890123", year: 2020, available: false})

      conn = post(conn, "/api/books/#{book.id}/return")

      # Pattern matching: sucesso
      assert %{
        "data" => %{"available" => true},
        "message" => "Book returned successfully"
      } = json_response(conn, 200)

      # Verifica stats
      Process.sleep(10)
      stats = LibraryApi.StatsCache.get_stats()
      assert stats.books_returned == 1
    end

    test "returns 422 when book already available", %{conn: conn} do
      book = create_book(%{title: "Book", author: "Author", isbn: "1234567890123", year: 2020, available: true})

      conn = post(conn, "/api/books/#{book.id}/return")

      assert %{"error" => "Book is already available"} = json_response(conn, 422)
    end
  end

  describe "GET /api/stats" do
    test "returns current statistics", %{conn: conn} do
      # Cria algumas operações
      book1 = create_book(%{title: "Book 1", author: "Author", isbn: "1234567890123", year: 2020})
      create_book(%{title: "Book 2", author: "Author", isbn: "1234567890124", year: 2021})

      Books.update_book(book1.id, %{title: "Updated"})
      Books.borrow_book(book1.id)

      Process.sleep(20)

      conn = get(conn, "/api/stats")

      # Pattern matching: estrutura de stats
      assert %{
        "data" => %{
          "books_created" => 2,
          "books_updated" => 1,
          "books_borrowed" => 1,
          "books_returned" => 0,
          "books_deleted" => 0
        }
      } = json_response(conn, 200)
    end
  end

  # Helper privado
  defp create_book(attrs) do
    default_attrs = %{
      title: "Default Title",
      author: "Default Author",
      isbn: "0000000000000",
      year: 2020,
      available: true
    }

    {:ok, book} =
      default_attrs
      |> Map.merge(attrs)
      |> Books.create_book()

    book
  end
end
