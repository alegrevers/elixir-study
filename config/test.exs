import Config

config :library_api, LibraryApi.Repo,
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: 10

config :library_api, LibraryApiWeb.Endpoint,
  http: [port: 4002],
  server: false

config :logger, level: :warning
