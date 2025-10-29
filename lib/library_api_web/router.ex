defmodule LibraryApiWeb.Router do
  use Phoenix.Router
  import Plug.Conn

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", LibraryApiWeb do
    pipe_through :api

    # Rotas de livros
    get "/books", BookController, :index
    get "/books/:id", BookController, :show
    post "/books", BookController, :create
    put "/books/:id", BookController, :update
    delete "/books/:id", BookController, :delete

    # Rotas de empréstimo
    post "/books/:id/borrow", BookController, :borrow
    post "/books/:id/return", BookController, :return

    # Rotas de logs
    get "/logs", LogController, :index
    get "/logs/book/:book_id", LogController, :by_book

    # Rotas de estatísticas
    get "/stats", StatsController, :show
  end
end
