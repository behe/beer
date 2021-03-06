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
                 latest_received_delivery: 0,
                 latest_sent_delivery: 0,
                 latest_received_order: 0,
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
          latest_received_delivery: 0,
          latest_sent_delivery: 0,
          latest_received_order: 0,
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
          latest_received_delivery: 0,
          latest_sent_delivery: 0,
          latest_received_order: 0,
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
                 latest_received_delivery: 0,
                 latest_sent_delivery: 0,
                 latest_received_order: 0,
                 orders: [4, 4],
                 shipping_delay: [4, 4],
                 state: "ready",
                 stock: 12,
                 role: "retailer"
               },
               "manufacturer" => %Player{
                 backlog: 0,
                 latest_received_delivery: 0,
                 latest_sent_delivery: 0,
                 latest_received_order: 0,
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
             latest_received_delivery: 0,
             latest_sent_delivery: 0,
             latest_received_order: 0,
             orders: [4, 4],
             shipping_delay: [4, 4],
             state: "ready",
             stock: 12,
             role: "retailer"
           },
           "manufacturer" => %Player{
             backlog: 0,
             latest_received_delivery: 0,
             latest_sent_delivery: 0,
             latest_received_order: 0,
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
        | latest_received_delivery: 4,
          shipping_delay: [4],
          state: "received_delivery",
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
          latest_received_order: 4,
          state: "received_order"
      }

      assert Game.receive_order(game, "retailer") == %Game{
               game
               | players: %{game.players | "retailer" => retailer}
             }
    end

    test "receive incoming order as a manufacturer", %{game: game} do
      manufacturer = %Player{
        game.players["manufacturer"]
        | backlog: 4,
          latest_received_order: 4,
          state: "received_order"
      }

      retailer = %Player{game.players["retailer"] | orders: [4]}

      assert Game.receive_order(game, "manufacturer") == %Game{
               game
               | players: %{"retailer" => retailer, "manufacturer" => manufacturer}
             }
    end

    test "send delivery as a retailer", %{game: game} do
      retailer = %Player{game.players["retailer"] | backlog: 16}
      game = %Game{game | players: %{game.players | "retailer" => retailer}}

      retailer = %Player{
        retailer
        | latest_sent_delivery: 12,
          backlog: 4,
          stock: 0,
          state: "sent_delivery"
      }

      assert Game.send_delivery(game, "retailer") == %Game{
               game
               | players: %{game.players | "retailer" => retailer}
             }
    end

    test "send delivery as a manufacturer", %{game: game} do
      manufacturer = %Player{game.players["manufacturer"] | backlog: 8}
      game = %Game{game | players: %{game.players | "manufacturer" => manufacturer}}

      retailer = %Player{game.players["retailer"] | shipping_delay: [8, 4, 4]}

      manufacturer = %Player{
        manufacturer
        | latest_sent_delivery: 8,
          backlog: 0,
          stock: 4,
          state: "sent_delivery"
      }

      assert Game.send_delivery(game, "manufacturer") == %Game{
               game
               | players: %{"retailer" => retailer, "manufacturer" => manufacturer}
             }
    end

    test "order", %{game: game} do
      retailer = %Player{game.players["retailer"] | state: "ready", orders: [8, 4, 4]}

      assert Game.send_order(game, "retailer", 8) == %Game{
               game
               | players: %{game.players | "retailer" => retailer}
             }
    end
  end
end
