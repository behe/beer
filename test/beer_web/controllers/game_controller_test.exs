defmodule BeerWeb.GameControllerTest do
  use BeerWeb.ConnCase

  setup do
    Agent.update(Beer.GameRepo, fn _ -> [] end)
  end

  describe "no games" do
    test "GET /game", %{conn: conn} do
      conn = get(conn, "/game")
      assert html_response(conn, 200) =~ "There are currently no active games."
    end
  end

  describe "existing game" do
    setup do
      Beer.Games.create("existing")
    end

    test "GET /game", %{conn: conn} do
      conn = get(conn, "/game")
      assert html_response(conn, 200) =~ "existing"
    end

    test "GET /game/:game/role/:role", %{conn: conn} do
      conn = get(conn, "/game/existing/role/retailer")
      assert html_response(conn, 200) =~ "Waiting for players…"
    end
  end
end
