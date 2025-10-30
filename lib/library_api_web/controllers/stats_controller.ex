defmodule LibraryApiWeb.StatsController do
  use Phoenix.Controller
  alias LibraryApi.StatsCache

  @doc """
  Retorna estatísticas do cache.
  Demonstra comunicação com ATOR (GenServer).
  """
  def show(conn, _params) do
    # Chama o GenServer de forma síncrona
    stats = StatsCache.get_stats()
    json(conn, %{data: stats})
  end
end
