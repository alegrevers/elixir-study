defmodule LibraryApi.Application do
  use Application

  @moduledoc """
  Aplicação principal que demonstra o padrão SUPERVISOR.

  O Supervisor é responsável por monitorar processos filhos e reiniciá-los
  em caso de falha, garantindo alta disponibilidade do sistema.

  Estratégias de supervisão:
  - :one_for_one - Se um filho falha, apenas ele é reiniciado
  - :one_for_all - Se um filho falha, todos são reiniciados
  - :rest_for_one - Se um filho falha, ele e os processos iniciados depois dele são reiniciados
  """

  def start(_type, _args) do
    children = [
      # Repo do PostgreSQL - Gerencia conexões com o banco
      LibraryApi.Repo,

      # MongoDB Connection - Pool de conexões
      {Mongo, [
        name: :mongo,
        url: System.get_env("MONGODB_URL") || "mongodb://localhost:27017/library_logs",
        pool_size: 10,
        ssl_opts: [verify: :verify_none]
      ]},

      # GenServer para cache de estatísticas (demonstra modelo de ATORES)
      LibraryApi.StatsCache,

      # Phoenix Endpoint para API REST
      LibraryApiWeb.Endpoint
    ]

    # Supervisor com estratégia :one_for_one
    # Se o Repo falhar, só ele será reiniciado, não afetando o MongoDB
    opts = [strategy: :one_for_one, name: LibraryApi.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
