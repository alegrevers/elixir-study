defmodule LibraryApiWeb.LogController do
  use Phoenix.Controller
  alias LibraryApi.Logs

  @doc """
  Lista todos os logs.
  PATTERN MATCHING no resultado do MongoDB.
  """
  def index(conn, params) do
    filters = build_filters(params)

    case Logs.list_logs(filters) do
      {:ok, logs} ->
        json(conn, %{data: logs})

      {:error, :query_failed} ->
        conn
        |> put_status(:internal_server_error)
        |> json(%{error: "Failed to retrieve logs"})
    end
  end

  @doc """
  Lista logs de um livro específico.
  """
  def by_book(conn, %{"book_id" => book_id}) do
    {id, _} = Integer.parse(book_id)

    case Logs.get_logs_by_book(id) do
      {:ok, logs} ->
        json(conn, %{data: logs})

      {:error, reason} ->
        conn
        |> put_status(:internal_server_error)
        |> json(%{error: "Failed to retrieve logs: #{inspect(reason)}"})
    end
  end

  # PATTERN MATCHING para construir filtros da query string
  defp build_filters(params) do
    params
    |> Enum.reduce(%{}, fn
      {"action", value}, acc -> Map.put(acc, "action", value)
      {"environment", value}, acc -> Map.put(acc, "environment", value)
      _other, acc -> acc
    end)
  end
end
