ExUnit.start()

# Configuração do sandbox do Ecto para testes isolados
Ecto.Adapters.SQL.Sandbox.mode(LibraryApi.Repo, :manual)
