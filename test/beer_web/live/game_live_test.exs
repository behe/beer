defmodule BeerWeb.GameLiveTest do
  use ExUnit.Case
  import Phoenix.LiveViewTest

  setup do
    Beer.Games.create("existing")
    Beer.Games.join("existing", "retailer")

    on_exit(fn ->
      Agent.update(Beer.GameRepo, fn _ -> [] end)
    end)
  end

  test "Disconnected render" do
    {:ok, _view, html} =
      mount_disconnected(BeerWeb.Endpoint, BeerWeb.GameLive,
        session: %{name: "existing", role: "retailer"}
      )

    assert html =~ "Waiting for players…"
  end

  describe "gameplay" do
    setup do
      name = "existing"
      role = "manufacturer"
      Beer.Games.join(name, role)

      {:ok, view, _html} =
        mount(BeerWeb.Endpoint, BeerWeb.GameLive, session: %{name: name, role: role})

      %{view: view}
    end

    test "update from event", %{view: view} do
      game = %Beer.Game{
        name: "updated game",
        players: %{"manufacturer" => %Beer.Player{role: "updated player"}}
      }

      send(view.pid, {:game, game})

      html = render(view)
      assert html =~ "<h1>updated game</h1>"
      assert html =~ "<h2>updated player</h2>"
    end

    test "start game", %{view: view} do
      assert render(view) =~ "Receive delivery"
    end

    test "receive delivery", %{view: view} do
      render_click(view, "receive_delivery")
      assert render(view) =~ "Receive incoming order"
    end

    test "receive incoming order", %{view: view} do
      render_click(view, "receive_order")
      assert render(view) =~ "Fulfill order"
    end

    test "send delivery", %{view: view} do
      render_click(view, "send_delivery")
      assert render(view) =~ "Place order"
    end

    test "place order", %{view: view} do
      render_submit(view, "order", %{"units" => "4"})
      assert render(view) =~ "Receive delivery"
    end
  end
end
