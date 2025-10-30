defmodule LibraryApi.DataCase do
  use ExUnit.CaseTemplate

  using do
    quote do
      alias LibraryApi.Repo
      import Ecto
      import Ecto.Changeset
      import Ecto.Query
      import LibraryApi.DataCase
    end
  end

  setup tags do
    pid = Ecto.Adapters.SQL.Sandbox.start_owner!(LibraryApi.Repo, shared: not tags[:async])
    on_exit(fn -> Ecto.Adapters.SQL.Sandbox.stop_owner(pid) end)
    :ok
  end
end
