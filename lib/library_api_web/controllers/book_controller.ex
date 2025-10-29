defmodule LibraryApiWeb.BookController do
  use Phoenix.Controller
  alias LibraryApi.Books
  alias LibraryApi.StatsCache

  @moduledoc """
  Controller que demonstra PATTERN MATCHING nas respostas.
  """

  @doc """
  Lista todos os livros.
  """
  def index(conn, _params) do
    books = Books.list_books()
    json(conn, %{data: books})
  end

  @doc """
  Mostra um livro específico.
  PATTERN MATCHING no resultado da busca.
  """
  def show(conn, %{"id" => id}) do
    # Pattern matching no resultado
    case Books.get_book(id) do
      {:ok, book} ->
        json(conn, %{data: book})

      {:error, :not_found} ->
        conn
        |> put_status(:not_found)
        |> json(%{error: "Book not found"})
    end
  end

  @doc """
  Cria um novo livro.
  PATTERN MATCHING no resultado da criação.
  """
  def create(conn, %{"book" => book_params}) do
    case Books.create_book(book_params) do
      {:ok, book} ->
        # Atualiza cache de estatísticas (modelo de atores)
        StatsCache.increment_operation(:book_created)

        conn
        |> put_status(:created)
        |> json(%{data: book})

      {:error, %Ecto.Changeset{} = changeset} ->
        errors = format_changeset_errors(changeset)

        conn
        |> put_status(:unprocessable_entity)
        |> json(%{errors: errors})
    end
  end

  @doc """
  Atualiza um livro.
  """
  def update(conn, %{"id" => id, "book" => book_params}) do
    case Books.update_book(id, book_params) do
      {:ok, book} ->
        StatsCache.increment_operation(:book_updated)
        json(conn, %{data: book})

      {:error, :not_found} ->
        conn
        |> put_status(:not_found)
        |> json(%{error: "Book not found"})

      {:error, changeset} ->
        errors = format_changeset_errors(changeset)

        conn
        |> put_status(:unprocessable_entity)
        |> json(%{errors: errors})
    end
  end

  @doc """
  Deleta um livro.
  """
  def delete(conn, %{"id" => id}) do
    case Books.delete_book(id) do
      {:ok, _book} ->
        StatsCache.increment_operation(:book_deleted)

        conn
        |> put_status(:no_content)
        |> json(%{})

      {:error, :not_found} ->
        conn
        |> put_status(:not_found)
        |> json(%{error: "Book not found"})
    end
  end

  @doc """
  Empresta um livro.
  PATTERN MATCHING em múltiplos casos de erro.
  """
  def borrow(conn, %{"id" => id}) do
    case Books.borrow_book(id) do
      {:ok, book} ->
        StatsCache.increment_operation(:book_borrowed)
        json(conn, %{data: book, message: "Book borrowed successfully"})

      {:error, :not_found} ->
        conn
        |> put_status(:not_found)
        |> json(%{error: "Book not found"})

      {:error, :already_borrowed} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{error: "Book is already borrowed"})
    end
  end

  @doc """
  Devolve um livro.
  """
  def return(conn, %{"id" => id}) do
    case Books.return_book(id) do
      {:ok, book} ->
        StatsCache.increment_operation(:book_returned)
        json(conn, %{data: book, message: "Book returned successfully"})

      {:error, :not_found} ->
        conn
        |> put_status(:not_found)
        |> json(%{error: "Book not found"})

      {:error, :already_available} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{error: "Book is already available"})
    end
  end

  # PATTERN MATCHING privado para formatar erros de validação
  defp format_changeset_errors(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
      Enum.reduce(opts, msg, fn {key, value}, acc ->
        String.replace(acc, "%{#{key}}", to_string(value))
      end)
    end)
  end
end
