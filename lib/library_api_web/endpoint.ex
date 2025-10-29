defmodule LibraryApiWeb.Endpoint do
  use Phoenix.Endpoint, otp_app: :library_api

  plug Plug.Logger

  plug Plug.Parsers,
    parsers: [:json],
    pass: ["*/*"],
    json_decoder: Jason

  plug LibraryApiWeb.Router
end
