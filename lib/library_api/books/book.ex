defmodule LibraryApi.Books.Book do
  use Ecto.Schema
  import Ecto.Changeset

  @moduledoc """
  Schema que representa um livro no PostgreSQL.
  Demonstra validações e transformações de dados.
  """

  schema "books" do
    field :title, :string
    field :author, :string
    field :isbn, :string
    field :year, :integer
    field :available, :boolean, default: true

    timestamps()
  end

  @doc """
  Cria um changeset para validação.
  Demonstra transformações funcionais e validações.
  """
  def changeset(book, attrs) do
    book
    |> cast(attrs, [:title, :author, :isbn, :year, :available])
    |> validate_required([:title, :author, :isbn, :year])
    |> validate_length(:title, min: 3, max: 200)
    |> validate_length(:isbn, is: 13)
    |> validate_number(:year, greater_than: 1450, less_than_or_equal_to: 2025)
    |> unique_constraint(:isbn)
  end
end
