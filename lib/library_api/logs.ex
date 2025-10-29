defmodule LibraryApi.Logs do
  @moduledoc """
  Context para operações com logs no MongoDB.
  Demonstra operações assíncronas e PATTERN MATCHING.
  """

  @doc """
  Cria um log no MongoDB de forma assíncrona.
  PATTERN MATCHING no spawn de processo.
  """
  def create_log(attrs) do
    # Spawn assíncrono - não bloqueia a operação principal
    # Demonstra o MODELO DE ATORES (processos leves e isolados)
    Task.start(fn ->
      log = Map.merge(attrs, %{
        timestamp: DateTime.utc_now(),
        environment: Mix.env()
      })

      # Pattern matching no resultado do insert
      case Mongo.insert_one(:mongo, "logs", log) do
        {:ok, _result} ->
          :ok

        {:error, reason} ->
          IO.puts("Erro ao salvar log: #{inspect(reason)}")
      end
    end)

    :ok
  end

  @doc """
  Lista logs com filtros opcionais.
  PATTERN MATCHING em parâmetros opcionais.
  """
  def list_logs(filters \\ %{}) do
    # Pattern matching para construir query
    query = build_query(filters)

    case Mongo.find(:mongo, "logs", query) |> Enum.to_list() do
      logs when is_list(logs) ->
        {:ok, logs}

      _ ->
        {:error, :query_failed}
    end
  end

  @doc """
  Busca logs por ação.
  PATTERN MATCHING direto no parâmetro da função.
  """
  def get_logs_by_action(action) when is_binary(action) do
    list_logs(%{"action" => action})
  end

  @doc """
  Busca logs de um livro específico.
  """
  def get_logs_by_book(book_id) when is_integer(book_id) do
    list_logs(%{"book_id" => book_id})
  end

  # PATTERN MATCHING privado para construir query MongoDB
  # Demonstra múltiplas cláusulas com pattern matching
  defp build_query(%{} = filters) when map_size(filters) == 0 do
    %{}
  end

  defp build_query(filters) do
    filters
    |> Enum.reduce(%{}, fn
      # Pattern matching: filtra apenas chaves válidas
      {key, value}, acc when key in ["action", "book_id", "environment"] ->
        Map.put(acc, key, value)

      # Pattern matching: ignora outras chaves
      _invalid, acc ->
        acc
    end)
  end
end
