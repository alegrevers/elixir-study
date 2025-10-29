defmodule LibraryApiWeb.ConnCase do
  @moduledoc """
  Case template para testes de controllers.
  """

  use ExUnit.CaseTemplate

  using do
    quote do
      import Plug.Conn
      import Phoenix.ConnTest
      import LibraryApiWeb.ConnCase

      alias LibraryApiWeb.Router.Helpers, as: Routes

      @endpoint LibraryApiWeb.Endpoint
    end
  end

  setup tags do
    pid = Ecto.Adapters.SQL.Sandbox.start_owner!(LibraryApi.Repo, shared: not tags[:async])
    on_exit(fn -> Ecto.Adapters.SQL.Sandbox.stop_owner(pid) end)

    {:ok, conn: Phoenix.ConnTest.build_conn()}
  end
end
