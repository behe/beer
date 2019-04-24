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
            latest_delivery: 0,
            latest_order: 0,
            latest_fulfilled_order: 0

  def receive_delivery(player) do
    {latest_delivery, shipping_delay} = List.pop_at(player.shipping_delay, -1)

    %{
      player
      | shipping_delay: shipping_delay,
        stock: player.stock + latest_delivery,
        latest_delivery: latest_delivery,
        state: "delivered"
    }
  end

  def receive_incoming_order(player, latest_order) do
    %{
      player
      | backlog: player.backlog + latest_order,
        latest_order: latest_order,
        state: "incoming_order"
    }
  end

  def fulfill_order(player) do
    latest_fulfilled_order = min(player.stock, player.backlog)
    stock = player.stock - latest_fulfilled_order
    backlog = player.backlog - latest_fulfilled_order

    %{
      player
      | latest_fulfilled_order: latest_fulfilled_order,
        backlog: backlog,
        stock: stock,
        state: "fulfill_order"
    }
  end

  # backlog 4 + order 2 = 6, stock 8 -> backlog = 0, stock = 2, delivery = 6
  # backlog 4 + order 2 = 6, stock 4 -> backlog = 2, stock = 0, delivery = 4

  def add_to_shipping_delay(player, delivery) do
    %{player | shipping_delay: [delivery | player.shipping_delay]}
  end

  def order(%{role: "manufacturer"} = player, units) do
    %{
      player
      | shipping_delay: [units | player.shipping_delay],
        latest_delivery: 0,
        latest_order: 0,
        latest_fulfilled_order: 0,
        state: "ready"
    }
  end

  def order(player, units) do
    %{
      player
      | orders: [units | player.orders],
        latest_delivery: 0,
        latest_order: 0,
        latest_fulfilled_order: 0,
        state: "ready"
    }
  end
end
