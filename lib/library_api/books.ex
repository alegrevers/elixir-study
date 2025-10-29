defmodule LibraryApi.Books do
  @moduledoc """
  Context para operações com livros.
  Demonstra PATTERN MATCHING extensivamente.
  """

  import Ecto.Query
  alias LibraryApi.Repo
  alias LibraryApi.Books.Book
  alias LibraryApi.Logs

  @doc """
  Lista todos os livros.
  Pattern matching no retorno da query.
  """
  def list_books do
    Repo.all(Book)
  end

  @doc """
  Busca um livro por ID.
  PATTERN MATCHING nos casos de sucesso/erro.
  """
  def get_book(id) do
    case Repo.get(Book, id) do
      # Pattern matching: quando encontra o livro
      %Book{} = book ->
        {:ok, book}

      # Pattern matching: quando não encontra (retorna nil)
      nil ->
        {:error, :not_found}
    end
  end

  @doc """
  Cria um novo livro.
  PATTERN MATCHING no resultado do changeset.
  """
  def create_book(attrs) do
    # Pattern matching encadeado com pipe operator
    %Book{}
    |> Book.changeset(attrs)
    |> Repo.insert()
    |> case do
      # Pattern matching: sucesso na inserção
      {:ok, book} = result ->
        # Registra log assíncrono no MongoDB
        Logs.create_log(%{
          action: "book_created",
          book_id: book.id,
          details: %{title: book.title}
        })
        result

      # Pattern matching: erro de validação
      {:error, _changeset} = error ->
        error
    end
  end

  @doc """
  Atualiza um livro existente.
  PATTERN MATCHING com cláusulas múltiplas.
  """
  def update_book(id, attrs) do
    # Pattern matching na busca
    with {:ok, book} <- get_book(id),
         changeset <- Book.changeset(book, attrs),
         {:ok, updated_book} <- Repo.update(changeset) do

      Logs.create_log(%{
        action: "book_updated",
        book_id: updated_book.id,
        details: attrs
      })

      {:ok, updated_book}
    else
      # Pattern matching nos erros
      {:error, :not_found} = error -> error
      {:error, changeset} -> {:error, changeset}
    end
  end

  @doc """
  Deleta um livro.
  PATTERN MATCHING simples.
  """
  def delete_book(id) do
    with {:ok, book} <- get_book(id),
         {:ok, deleted_book} <- Repo.delete(book) do

      Logs.create_log(%{
        action: "book_deleted",
        book_id: deleted_book.id,
        details: %{title: deleted_book.title}
      })

      {:ok, deleted_book}
    end
  end

  @doc """
  Busca livros por disponibilidade.
  PATTERN MATCHING em função pública com cláusulas múltiplas.
  """
  def list_books_by_availability(true = _available) do
    Book
    |> where([b], b.available == true)
    |> Repo.all()
  end

  def list_books_by_availability(false = _available) do
    Book
    |> where([b], b.available == false)
    |> Repo.all()
  end

  @doc """
  Empresta um livro (marca como indisponível).
  PATTERN MATCHING com guards.
  """
  def borrow_book(id) do
    with {:ok, %Book{available: true} = book} <- get_book(id) do
      update_book(id, %{available: false})
    else
      {:ok, %Book{available: false}} ->
        {:error, :already_borrowed}

      error ->
        error
    end
  end

  @doc """
  Devolve um livro (marca como disponível).
  """
  def return_book(id) do
    with {:ok, %Book{available: false} = book} <- get_book(id) do
      update_book(id, %{available: true})
    else
      {:ok, %Book{available: true}} ->
        {:error, :already_available}

      error ->
        error
    end
  end
end
