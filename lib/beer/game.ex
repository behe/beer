defmodule Beer.Game do
  alias Beer.Player

  defstruct name: nil, round: 1, players: %{}

  def join(game, role) do
    case game do
      %{players: %{^role => _player}} -> game
      _ -> %{game | players: Map.put(game.players, role, %Player{role: role})}
    end
    |> case do
      %{players: players} = game when map_size(players) == 2 ->
        %{
          game
          | players:
              Enum.into(players, %{}, fn {role, player} -> {role, %{player | state: "ready"}} end)
        }

      game ->
        game
    end
  end

  def receive_delivery(game, role) do
    %{game | players: Map.update!(game.players, role, &Player.receive_delivery/1)}
  end

  def receive_order(game, "retailer" = role) do
    %{game | players: Map.update!(game.players, role, &Player.receive_order(&1, 4))}
  end

  def receive_order(game, "manufacturer" = role) do
    {order, players} = Map.get_and_update(game.players, "retailer", &Player.pop_order/1)

    %{game | players: Map.update!(players, role, &Player.receive_order(&1, order))}
  end

  def send_delivery(game, "retailer" = role) do
    %{game | players: Map.update!(game.players, role, &Player.send_delivery(&1))}
  end

  def send_delivery(game, "manufacturer" = role) do
    players = Map.update!(game.players, role, &Player.send_delivery(&1))

    delivery = players[role].latest_sent_delivery
    players = Map.update!(players, "retailer", &Player.add_to_shipping_delay(&1, delivery))

    %{game | players: players}
  end

  def send_order(game, role, units) do
    %{game | players: Map.update!(game.players, role, &Player.send_order(&1, units))}
  end
end
