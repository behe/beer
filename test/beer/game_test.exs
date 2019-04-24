defmodule Beee.GameTest do
  use ExUnit.Case
  alias Beer.{Game, Player}

  test "new game" do
    assert %Game{name: "new game"} == %Game{name: "new game", round: 1, players: %{}}
  end

  test "join game" do
    assert Game.join(%Game{name: "new game"}, "retailer") == %Game{
             name: "new game",
             round: 1,
             players: %{
               "retailer" => %Player{
                 backlog: 0,
                 latest_delivery: 0,
                 latest_fulfilled_order: 0,
                 latest_order: 0,
                 orders: [4, 4],
                 shipping_delay: [4, 4],
                 state: "new",
                 stock: 12,
                 role: "retailer"
               }
             }
           }
  end

  test "rejoin game with same role" do
    game = %Game{
      name: "new game",
      round: 1,
      players: %{
        "retailer" => %Player{
          backlog: 0,
          latest_delivery: 0,
          latest_fulfilled_order: 0,
          latest_order: 0,
          orders: [4, 4],
          shipping_delay: [4, 4],
          state: "new",
          stock: 12,
          role: "retailer"
        }
      }
    }

    assert Game.join(game, "retailer") == game
  end

  test "fill roles to change player into ready state" do
    game = %Game{
      name: "new game",
      round: 1,
      players: %{
        "retailer" => %Player{
          backlog: 0,
          latest_delivery: 0,
          latest_fulfilled_order: 0,
          latest_order: 0,
          orders: [4, 4],
          shipping_delay: [4, 4],
          state: "new",
          stock: 12,
          role: "retailer"
        }
      }
    }

    assert Game.join(game, "manufacturer") == %Game{
             name: "new game",
             round: 1,
             players: %{
               "retailer" => %Player{
                 backlog: 0,
                 latest_delivery: 0,
                 latest_fulfilled_order: 0,
                 latest_order: 0,
                 orders: [4, 4],
                 shipping_delay: [4, 4],
                 state: "ready",
                 stock: 12,
                 role: "retailer"
               },
               "manufacturer" => %Player{
                 backlog: 0,
                 latest_delivery: 0,
                 latest_fulfilled_order: 0,
                 latest_order: 0,
                 orders: [4, 4],
                 shipping_delay: [4, 4],
                 state: "ready",
                 stock: 12,
                 role: "manufacturer"
               }
             }
           }
  end

  describe "ready game" do
    setup do
      {:ok,
       game: %Game{
         name: "new game",
         round: 1,
         players: %{
           "retailer" => %Player{
             backlog: 0,
             latest_delivery: 0,
             latest_fulfilled_order: 0,
             latest_order: 0,
             orders: [4, 4],
             shipping_delay: [4, 4],
             state: "ready",
             stock: 12,
             role: "retailer"
           },
           "manufacturer" => %Player{
             backlog: 0,
             latest_delivery: 0,
             latest_fulfilled_order: 0,
             latest_order: 0,
             orders: [4, 4],
             shipping_delay: [4, 4],
             state: "ready",
             stock: 12,
             role: "manufacturer"
           }
         }
       }}
    end

    test "receive delivery", %{game: game} do
      retailer = %Player{
        game.players["retailer"]
        | latest_delivery: 4,
          shipping_delay: [4],
          state: "delivered",
          stock: 16
      }

      assert Game.receive_delivery(game, "retailer") == %Game{
               game
               | players: %{game.players | "retailer" => retailer}
             }
    end

    test "receive incoming order as a retailer", %{game: game} do
      retailer = %Player{
        game.players["retailer"]
        | backlog: 4,
          latest_order: 4,
          state: "incoming_order"
      }

      assert Game.receive_incoming_order(game, "retailer") == %Game{
               game
               | players: %{game.players | "retailer" => retailer}
             }
    end

    test "receive incoming order as a manufacturer", %{game: game} do
      manufacturer = %Player{
        game.players["manufacturer"]
        | backlog: 4,
          latest_order: 4,
          state: "incoming_order"
      }

      retailer = %Player{game.players["retailer"] | orders: [4]}

      assert Game.receive_incoming_order(game, "manufacturer") == %Game{
               game
               | players: %{"retailer" => retailer, "manufacturer" => manufacturer}
             }
    end

    test "fulfill order as a retailer", %{game: game} do
      retailer = %Player{game.players["retailer"] | backlog: 16}
      game = %Game{game | players: %{game.players | "retailer" => retailer}}

      retailer = %Player{
        retailer
        | latest_fulfilled_order: 12,
          backlog: 4,
          stock: 0,
          state: "fulfill_order"
      }

      assert Game.fulfill_order(game, "retailer") == %Game{
               game
               | players: %{game.players | "retailer" => retailer}
             }
    end

    test "fulfill order as a manufacturer", %{game: game} do
      manufacturer = %Player{game.players["manufacturer"] | backlog: 8}
      game = %Game{game | players: %{game.players | "manufacturer" => manufacturer}}

      retailer = %Player{game.players["retailer"] | shipping_delay: [8, 4, 4]}

      manufacturer = %Player{
        manufacturer
        | latest_fulfilled_order: 8,
          backlog: 0,
          stock: 4,
          state: "fulfill_order"
      }

      assert Game.fulfill_order(game, "manufacturer") == %Game{
               game
               | players: %{"retailer" => retailer, "manufacturer" => manufacturer}
             }
    end

    test "order", %{game: game} do
      retailer = %Player{game.players["retailer"] | state: "ready", orders: [8, 4, 4]}

      assert Game.order(game, "retailer", 8) == %Game{
               game
               | players: %{game.players | "retailer" => retailer}
             }
    end
  end
end
