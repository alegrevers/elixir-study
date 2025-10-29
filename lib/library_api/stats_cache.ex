defmodule LibraryApi.StatsCache do
  use GenServer

  @moduledoc """
  GenServer que demonstra o MODELO DE ATORES do Elixir.

  Conceitos demonstrados:
  - ATOR: Processo isolado com estado próprio (cache de estatísticas)
  - Comunicação por mensagens assíncronas (cast) e síncronas (call)
  - Estado imutável - cada atualização cria novo estado
  - Supervisão automática pelo Application Supervisor
  """

  # Cliente API - Funções públicas que enviam mensagens ao ator

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  @doc """
  Obtém estatísticas (CALL - síncrono).
  Demonstra comunicação síncrona entre atores.
  """
  def get_stats do
    GenServer.call(__MODULE__, :get_stats)
  end

  @doc """
  Incrementa contador de operações (CAST - assíncrono).
  Demonstra comunicação assíncrona entre atores.
  """
  def increment_operation(operation_type) do
    GenServer.cast(__MODULE__, {:increment, operation_type})
  end

  @doc """
  Reseta estatísticas.
  """
  def reset_stats do
    GenServer.cast(__MODULE__, :reset)
  end

  # Callbacks do GenServer - Lógica interna do ator

  @impl true
  def init(_init_arg) do
    # Estado inicial do ator
    initial_state = %{
      books_created: 0,
      books_updated: 0,
      books_deleted: 0,
      books_borrowed: 0,
      books_returned: 0,
      last_reset: DateTime.utc_now()
    }

    {:ok, initial_state}
  end

  @impl true
  @doc """
  Trata mensagem GET síncrona.
  PATTERN MATCHING no tipo de mensagem.
  """
  def handle_call(:get_stats, _from, state) do
    # Responde com o estado atual
    {:reply, state, state}
  end

  @impl true
  @doc """
  Trata mensagem INCREMENT assíncrona.
  PATTERN MATCHING no tipo de operação.
  """
  def handle_cast({:increment, operation_type}, state) do
    # Pattern matching para cada tipo de operação
    new_state = case operation_type do
      :book_created ->
        Map.update!(state, :books_created, &(&1 + 1))

      :book_updated ->
        Map.update!(state, :books_updated, &(&1 + 1))

      :book_deleted ->
        Map.update!(state, :books_deleted, &(&1 + 1))

      :book_borrowed ->
        Map.update!(state, :books_borrowed, &(&1 + 1))

      :book_returned ->
        Map.update!(state, :books_returned, &(&1 + 1))

      # Pattern matching: operação desconhecida, mantém estado
      _unknown ->
        state
    end

    # Estado imutável - retorna novo estado
    {:noreply, new_state}
  end

  @impl true
  @doc """
  Trata reset de estatísticas.
  """
  def handle_cast(:reset, _state) do
    new_state = %{
      books_created: 0,
      books_updated: 0,
      books_deleted: 0,
      books_borrowed: 0,
      books_returned: 0,
      last_reset: DateTime.utc_now()
    }

    {:noreply, new_state}
  end
end
