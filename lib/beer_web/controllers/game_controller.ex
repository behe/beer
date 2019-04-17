defmodule BeerWeb.GameController do
  use BeerWeb, :controller
  import Phoenix.LiveView.Controller, only: [live_render: 3]

  def index(conn, _params) do
    render(conn, "index.html")
  end

  def show(conn, %{"game" => name, "role" => role}) do
    Beer.Games.join(name, role)

    live_render(conn, BeerWeb.GameLive, session: %{name: name, role: role})
  end
end
