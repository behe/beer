defmodule BeerWeb.LobbyLiveTest do
  use ExUnit.Case
  import Phoenix.LiveViewTest

  setup do
    on_exit(fn ->
      Agent.update(Beer.GameRepo, fn _ -> [] end)
    end)
  end

  test "Disconnected render" do
    {:ok, _view, html} = mount_disconnected(BeerWeb.Endpoint, BeerWeb.LobbyLive, session: %{})
    assert html =~ "There are currently no active games."
  end

  test "create game" do
    {:ok, view, html} = mount(BeerWeb.Endpoint, BeerWeb.LobbyLive, session: %{})
    assert html =~ "There are currently no active games."
    assert render_click(view, "new") =~ "Name this game:"

    assert render_submit(view, "create", %{"game" => "game name"}) =~
             "There are currently no active games."

    assert render(view) =~ "game name"
  end

  test "join game" do
    Beer.Games.create("existing")
    {:ok, view, _html} = mount(BeerWeb.Endpoint, BeerWeb.LobbyLive, session: %{})
    assert render_click(view, "join", "existing") =~ "Pick a role:"
  end
end
