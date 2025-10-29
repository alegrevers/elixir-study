alias LibraryApi.Repo
alias LibraryApi.Books.Book

# Limpa dados existentes
Repo.delete_all(Book)

# Dados fake de livros
books = [
  %{
    title: "Clean Code: A Handbook of Agile Software Craftsmanship",
    author: "Robert C. Martin",
    isbn: "9780132350884",
    year: 2008,
    available: true
  },
  %{
    title: "The Pragmatic Programmer",
    author: "David Thomas",
    isbn: "9780201616224",
    year: 1999,
    available: true
  },
  %{
    title: "Design Patterns: Elements of Reusable Object-Oriented Software",
    author: "Erich Gamma",
    isbn: "9780201633610",
    year: 1994,
    available: false
  },
  %{
    title: "Refactoring: Improving the Design of Existing Code",
    author: "Martin Fowler",
    isbn: "9780201485677",
    year: 1999,
    available: true
  },
  %{
    title: "Introduction to Algorithms",
    author: "Thomas H. Cormen",
    isbn: "9780262033848",
    year: 2009,
    available: true
  },
  %{
    title: "Elixir in Action",
    author: "Saša Jurić",
    isbn: "9781617295027",
    year: 2019,
    available: false
  },
  %{
    title: "Programming Elixir",
    author: "Dave Thomas",
    isbn: "9781680502992",
    year: 2018,
    available: true
  },
  %{
    title: "Functional Programming in Scala",
    author: "Paul Chiusano",
    isbn: "9781617290657",
    year: 2014,
    available: true
  },
  %{
    title: "Structure and Interpretation of Computer Programs",
    author: "Harold Abelson",
    isbn: "9780262510871",
    year: 1996,
    available: true
  },
  %{
    title: "The Art of Computer Programming",
    author: "Donald Knuth",
    isbn: "9780201896831",
    year: 1997,
    available: false
  }
]

Enum.each(books, fn book_attrs ->
  %Book{}
  |> Book.changeset(book_attrs)
  |> Repo.insert!()
end)

IO.puts("✓ Inserted #{length(books)} books into PostgreSQL")

# Seeds para MongoDB (logs de exemplo)
{:ok, _} = Mongo.insert_one(:mongo, "logs", %{
  action: "book_created",
  book_id: 1,
  details: %{title: "Clean Code"},
  timestamp: DateTime.utc_now() |> DateTime.add(-86400, :second),
  environment: "dev"
})

{:ok, _} = Mongo.insert_one(:mongo, "logs", %{
  action: "book_borrowed",
  book_id: 3,
  details: %{},
  timestamp: DateTime.utc_now() |> DateTime.add(-43200, :second),
  environment: "dev"
})

{:ok, _} = Mongo.insert_one(:mongo, "logs", %{
  action: "book_returned",
  book_id: 1,
  details: %{},
  timestamp: DateTime.utc_now() |> DateTime.add(-3600, :second),
  environment: "dev"
})

IO.puts("✓ Inserted sample logs into MongoDB")
