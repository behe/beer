# TODO: Wrap the following into a Round struct to keep an order history
# * latest_received_delivery
# * latest_received_order
# * latest_sent_delivery
# * latest_sent_order
# TODO: Move shipping_delay and orders into a Buffer held by the Game
# TODO: Move the state into the Game
# TODO: Combine receiving delivery, orders and sending delivery into one function that produes a Round / history
defmodule Beer.Player do
  defstruct state: "new",
            role: nil,
            stock: 12,
            backlog: 0,
            shipping_delay: [4, 4],
            orders: [4, 4],
            latest_received_delivery: 0,
            latest_received_order: 0,
            latest_sent_delivery: 0

  def receive_delivery(player) do
    {latest_received_delivery, shipping_delay} = List.pop_at(player.shipping_delay, -1)

    %{
      player
      | shipping_delay: shipping_delay,
        stock: player.stock + latest_received_delivery,
        latest_received_delivery: latest_received_delivery,
        state: "received_delivery"
    }
  end

  def receive_order(player, latest_received_order) do
    %{
      player
      | backlog: player.backlog + latest_received_order,
        latest_received_order: latest_received_order,
        state: "received_order"
    }
  end

  def send_delivery(player) do
    latest_sent_delivery = min(player.stock, player.backlog)
    stock = player.stock - latest_sent_delivery
    backlog = player.backlog - latest_sent_delivery

    %{
      player
      | latest_sent_delivery: latest_sent_delivery,
        backlog: backlog,
        stock: stock,
        state: "sent_delivery"
    }
  end

  # backlog 4 + order 2 = 6, stock 8 -> backlog = 0, stock = 2, delivery = 6
  # backlog 4 + order 2 = 6, stock 4 -> backlog = 2, stock = 0, delivery = 4

  def add_to_shipping_delay(player, delivery) do
    %{player | shipping_delay: [delivery | player.shipping_delay]}
  end

  def send_order(%{role: "manufacturer"} = player, units) do
    %{
      player
      | shipping_delay: [units | player.shipping_delay],
        latest_received_delivery: 0,
        latest_received_order: 0,
        latest_sent_delivery: 0,
        state: "ready"
    }
  end

  def send_order(player, units) do
    %{
      player
      | orders: [units | player.orders],
        latest_received_delivery: 0,
        latest_received_order: 0,
        latest_sent_delivery: 0,
        state: "ready"
    }
  end
end
