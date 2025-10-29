defmodule LibraryApi.StatsCacheTest do
  use ExUnit.Case, async: false
  alias LibraryApi.StatsCache

  @moduledoc """
  Testes que demonstram o MODELO DE ATORES (GenServer).
  """

  setup do
    # Reseta estatísticas antes de cada teste
    StatsCache.reset_stats()
    :ok
  end

  describe "get_stats/0" do
    test "returns initial stats" do
      stats = StatsCache.get_stats()

      # Pattern matching: verifica estrutura do estado
      assert %{
        books_created: 0,
        books_updated: 0,
        books_deleted: 0,
        books_borrowed: 0,
        books_returned: 0,
        last_reset: %DateTime{}
      } = stats
    end
  end

  describe "increment_operation/1" do
    test "increments book_created counter" do
      # Comunicação assíncrona com o ator (cast)
      StatsCache.increment_operation(:book_created)

      # Pequeno delay para garantir processamento assíncrono
      Process.sleep(10)

      # Comunicação síncrona com o ator (call)
      stats = StatsCache.get_stats()

      # Pattern matching: verifica incremento
      assert stats.books_created == 1
    end

    test "increments multiple operation types" do
      StatsCache.increment_operation(:book_created)
      StatsCache.increment_operation(:book_created)
      StatsCache.increment_operation(:book_updated)
      StatsCache.increment_operation(:book_borrowed)

      Process.sleep(10)

      stats = StatsCache.get_stats()

      # Pattern matching: múltiplos valores
      assert stats.books_created == 2
      assert stats.books_updated == 1
      assert stats.books_borrowed == 1
      assert stats.books_deleted == 0
    end

    test "ignores unknown operation types" do
      initial_stats = StatsCache.get_stats()

      # Tenta incrementar operação inválida
      StatsCache.increment_operation(:invalid_operation)

      Process.sleep(10)

      final_stats = StatsCache.get_stats()

      # Pattern matching: estado não muda
      assert initial_stats.books_created == final_stats.books_created
    end
  end

  describe "reset_stats/0" do
    test "resets all counters to zero" do
      # Incrementa alguns contadores
      StatsCache.increment_operation(:book_created)
      StatsCache.increment_operation(:book_updated)
      StatsCache.increment_operation(:book_deleted)

      Process.sleep(10)

      # Verifica que foram incrementados
      stats_before = StatsCache.get_stats()
      assert stats_before.books_created > 0

      # Reseta
      StatsCache.reset_stats()
      Process.sleep(10)

      # Verifica reset
      stats_after = StatsCache.get_stats()

      # Pattern matching: todos voltam a zero
      assert stats_after.books_created == 0
      assert stats_after.books_updated == 0
      assert stats_after.books_deleted == 0
      assert stats_after.books_borrowed == 0
      assert stats_after.books_returned == 0
    end

    test "updates last_reset timestamp" do
      initial_stats = StatsCache.get_stats()

      Process.sleep(100)

      StatsCache.reset_stats()
      Process.sleep(10)

      final_stats = StatsCache.get_stats()

      # Pattern matching: timestamp foi atualizado
      assert DateTime.compare(final_stats.last_reset, initial_stats.last_reset) == :gt
    end
  end

  describe "concurrent operations" do
    test "handles multiple concurrent increments correctly" do
      # Demonstra que o GenServer serializa mensagens corretamente
      tasks =
        for _ <- 1..50 do
          Task.async(fn ->
            StatsCache.increment_operation(:book_created)
          end)
        end

      # Aguarda todas as tasks
      Task.await_many(tasks)
      Process.sleep(50)

      stats = StatsCache.get_stats()

      # Pattern matching: contador reflete todas as operações
      assert stats.books_created == 50
    end
  end
end
