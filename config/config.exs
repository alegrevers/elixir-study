import Config

# Configuração do Ecto/PostgreSQL
config :library_api, LibraryApi.Repo,
  database: "library_api",
  username: System.get_env("DATABASE_USERNAME") || "postgres",
  password: System.get_env("DATABASE_PASSWORD") || "postgres",
  hostname: System.get_env("DATABASE_HOSTNAME") || "localhost",
  port: 5432,
  pool_size: 10

config :library_api, ecto_repos: [LibraryApi.Repo]

# Configuração do Phoenix
config :library_api, LibraryApiWeb.Endpoint,
  http: [port: 4000],
  secret_key_base: "super_secret_key_base_change_in_production",
  render_errors: [view: LibraryApiWeb.ErrorView, accepts: ~w(json)],
  pubsub_server: LibraryApi.PubSub

config :phoenix, :json_library, Jason

# Configurações por ambiente
import_config "#{config_env()}.exs"
