defmodule LibraryApi.BooksTest do
  use LibraryApi.DataCase
  alias LibraryApi.Books
  alias LibraryApi.Books.Book

  @moduledoc """
  Testes unitários que demonstram PATTERN MATCHING nos asserts.
  """

  describe "list_books/0" do
    test "returns all books" do
      book1 = create_book(%{title: "Book 1", author: "Author 1", isbn: "1234567890123", year: 2020})
      book2 = create_book(%{title: "Book 2", author: "Author 2", isbn: "1234567890124", year: 2021})

      books = Books.list_books()

      # Pattern matching: verifica que retornou lista
      assert is_list(books)
      assert length(books) == 2
    end

    test "returns empty list when no books exist" do
      # Pattern matching: lista vazia
      assert [] = Books.list_books()
    end
  end

  describe "get_book/1" do
    test "returns book when id exists" do
      book = create_book(%{title: "Test Book", author: "Test Author", isbn: "1234567890123", year: 2020})

      # Pattern matching: sucesso retorna tupla {:ok, book}
      assert {:ok, found_book} = Books.get_book(book.id)
      assert found_book.id == book.id
      assert found_book.title == "Test Book"
    end

    test "returns error when book does not exist" do
      # Pattern matching: erro retorna tupla {:error, :not_found}
      assert {:error, :not_found} = Books.get_book(99999)
    end
  end

  describe "create_book/1" do
    test "creates book with valid attributes" do
      attrs = %{
        title: "New Book",
        author: "New Author",
        isbn: "1234567890123",
        year: 2023
      }

      # Pattern matching: sucesso
      assert {:ok, %Book{} = book} = Books.create_book(attrs)
      assert book.title == "New Book"
      assert book.author == "New Author"
      assert book.available == true
    end

    test "returns error with invalid attributes" do
      attrs = %{title: "AB", author: "", isbn: "123", year: 1000}

      # Pattern matching: erro com changeset
      assert {:error, %Ecto.Changeset{} = changeset} = Books.create_book(attrs)

      # Pattern matching: verifica erros específicos
      assert %{
        title: ["should be at least 3 character(s)"],
        author: ["can't be blank"],
        isbn: ["should be 13 character(s)"],
        year: ["must be greater than 1450"]
      } = errors_on(changeset)
    end

    test "returns error when isbn already exists" do
      create_book(%{title: "Book 1", author: "Author 1", isbn: "1234567890123", year: 2020})

      attrs = %{title: "Book 2", author: "Author 2", isbn: "1234567890123", year: 2021}

      # Pattern matching: erro de constraint
      assert {:error, %Ecto.Changeset{} = changeset} = Books.create_book(attrs)
      assert %{isbn: ["has already been taken"]} = errors_on(changeset)
    end
  end

  describe "update_book/2" do
    test "updates book with valid attributes" do
      book = create_book(%{title: "Old Title", author: "Author", isbn: "1234567890123", year: 2020})

      # Pattern matching: sucesso na atualização
      assert {:ok, %Book{} = updated_book} = Books.update_book(book.id, %{title: "New Title"})
      assert updated_book.title == "New Title"
      assert updated_book.author == "Author"
    end

    test "returns error when book does not exist" do
      assert {:error, :not_found} = Books.update_book(99999, %{title: "New Title"})
    end

    test "returns error with invalid attributes" do
      book = create_book(%{title: "Book", author: "Author", isbn: "1234567890123", year: 2020})

      assert {:error, %Ecto.Changeset{}} = Books.update_book(book.id, %{year: 1000})
    end
  end

  describe "delete_book/1" do
    test "deletes existing book" do
      book = create_book(%{title: "Book", author: "Author", isbn: "1234567890123", year: 2020})

      # Pattern matching: sucesso na deleção
      assert {:ok, %Book{}} = Books.delete_book(book.id)
      assert {:error, :not_found} = Books.get_book(book.id)
    end

    test "returns error when book does not exist" do
      assert {:error, :not_found} = Books.delete_book(99999)
    end
  end

  describe "borrow_book/1" do
    test "borrows available book" do
      book = create_book(%{title: "Book", author: "Author", isbn: "1234567890123", year: 2020, available: true})

      # Pattern matching: sucesso
      assert {:ok, %Book{available: false} = borrowed_book} = Books.borrow_book(book.id)
      assert borrowed_book.id == book.id
    end

    test "returns error when book already borrowed" do
      book = create_book(%{title: "Book", author: "Author", isbn: "1234567890123", year: 2020, available: false})

      # Pattern matching: erro específico
      assert {:error, :already_borrowed} = Books.borrow_book(book.id)
    end

    test "returns error when book does not exist" do
      assert {:error, :not_found} = Books.borrow_book(99999)
    end
  end

  describe "return_book/1" do
    test "returns borrowed book" do
      book = create_book(%{title: "Book", author: "Author", isbn: "1234567890123", year: 2020, available: false})

      # Pattern matching: sucesso
      assert {:ok, %Book{available: true} = returned_book} = Books.return_book(book.id)
      assert returned_book.id == book.id
    end

    test "returns error when book already available" do
      book = create_book(%{title: "Book", author: "Author", isbn: "1234567890123", year: 2020, available: true})

      # Pattern matching: erro específico
      assert {:error, :already_available} = Books.return_book(book.id)
    end
  end

  describe "list_books_by_availability/1" do
    test "returns only available books" do
      _unavailable = create_book(%{title: "Book 1", author: "Author", isbn: "1234567890123", year: 2020, available: false})
      available = create_book(%{title: "Book 2", author: "Author", isbn: "1234567890124", year: 2021, available: true})

      # Pattern matching: demonstra múltiplas cláusulas de função
      books = Books.list_books_by_availability(true)

      assert length(books) == 1
      assert hd(books).id == available.id
    end

    test "returns only unavailable books" do
      unavailable = create_book(%{title: "Book 1", author: "Author", isbn: "1234567890123", year: 2020, available: false})
      _available = create_book(%{title: "Book 2", author: "Author", isbn: "1234567890124", year: 2021, available: true})

      books = Books.list_books_by_availability(false)

      assert length(books) == 1
      assert hd(books).id == unavailable.id
    end
  end

  # Helper privado para criar livros nos testes
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
      |> then(&Books.create_book/1)

    book
  end

  # Helper para extrair erros do changeset
  defp errors_on(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {message, opts} ->
      Regex.replace(~r"%{(\w+)}", message, fn _, key ->
        opts |> Keyword.get(String.to_existing_atom(key), key) |> to_string()
      end)
    end)
  end
end
