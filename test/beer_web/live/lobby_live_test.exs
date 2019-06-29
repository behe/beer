defmodule BeerWeb.LobbyLiveTest do
  use BeerWeb.ConnCase
  import Phoenix.LiveViewTest

  setup %{conn: conn} do
    on_exit(fn ->
      Agent.update(Beer.GameRepo, fn _ -> [] end)
    end)

    {:ok, conn: Plug.Conn.assign(conn, :live_view_module, BeerWeb.LobbyLive)}
  end

  test "Disconnected render", %{conn: conn} do
    conn = get(conn, "/game")
    assert html_response(conn, 200) =~ "There are currently no active games."
  end

  test "create game", %{conn: conn} do
    {:ok, view, html} = live(conn, "/game")
    assert html =~ "There are currently no active games."
    assert render_click(view, "new") =~ "Name this game:"

    assert render_submit(view, "create", %{"game" => "game name"}) =~
             "There are currently no active games."

    assert render(view) =~ "game name"
  end

  test "join game", %{conn: conn} do
    Beer.Games.create("existing")
    {:ok, view, _html} = live(conn, "/game")
    assert render_click(view, "join", "existing") =~ "Pick a role:"
  end
end
