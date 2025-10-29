defmodule LibraryApi.Repo.Migrations.CreateBooks do
  use Ecto.Migration

  def change do
    create table(:books) do
      add :title, :string, null: false
      add :author, :string, null: false
      add :isbn, :string, null: false
      add :year, :integer, null: false
      add :available, :boolean, default: true, null: false

      timestamps()
    end

    create unique_index(:books, [:isbn])
    create index(:books, [:available])
    create index(:books, [:author])
  end
end
