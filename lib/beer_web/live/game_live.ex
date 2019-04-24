defmodule BeerWeb.GameLive do
  use Phoenix.LiveView
  alias Beer.{Games, Player}

  def render(%{player: %Player{state: "new"}} = assigns) do
    ~L"""
    <h1><%= @game.name %></h1>
    <h2><%= @player.role %></h2>
    <h3>Round: <%= @game.round %>/50</h3>
    <p><%= inspect(@player) %></p>
    <div>Received delivery: </div>
    <div>Received order: </div>
    <div>Sent delivery: </div>
    <div>Stock: <%= @player.stock %></div>
    <div>Backlog: <%= @player.backlog %></div>
    <div>Waiting for players…</div>
    """
  end

  def render(%{player: %Player{state: "ready"}} = assigns) do
    ~L"""
    <h1><%= @game.name %></h1>
    <h2><%= @player.role %></h2>
    <h3>Round: <%= @game.round %>/50</h3>
    <p><%= inspect(@player) %></p>
    <div>Received delivery: </div>
    <div>Received order: </div>
    <div>Sent delivery: </div>
    <div>Stock: <%= @player.stock %></div>
    <div>Backlog: <%= @player.backlog %></div>
    <button phx-click="receive_delivery">Receive delivery</button>
    """
  end

  def render(%{player: %Player{state: "received_delivery"}} = assigns) do
    ~L"""
    <h1><%= @game.name %></h1>
    <h2><%= @player.role %></h2>
    <h3>Round: <%= @game.round %>/50</h3>
    <p><%= inspect(@player) %></p>
    <div>Received delivery: <%= @player.latest_received_delivery %></div>
    <div>Received order: </div>
    <div>Sent delivery: </div>
    <div>Stock: <%= @player.stock %></div>
    <div>Backlog: <%= @player.backlog %></div>
    <button phx-click="receive_order">Receive order</button>
    """
  end

  def render(%{player: %Player{state: "received_order"}} = assigns) do
    ~L"""
    <h1><%= @game.name %></h1>
    <h2><%= @player.role %></h2>
    <h3>Round: <%= @game.round %>/50</h3>
    <p><%= inspect(@player) %></p>
    <div>Received delivery: <%= @player.latest_received_delivery %></div>
    <div>Received order: <%= @player.latest_received_order %></div>
    <div>Sent delivery: </div>
    <div>Stock: <%= @player.stock %></div>
    <div>Backlog: <%= @player.backlog %></div>
    <button phx-click="send_delivery">Send delivery</button>
    """
  end

  def render(%{player: %Player{state: "send_delivery"}} = assigns) do
    ~L"""
    <h1><%= @game.name %></h1>
    <h2><%= @player.role %></h2>
    <h3>Round: <%= @game.round %>/50</h3>
    <p><%= inspect(@player) %></p>
    <div>Received delivery: <%= @player.latest_received_delivery %></div>
    <div>Received order: <%= @player.latest_received_order %></div>
    <div>Sent delivery: <%= @player.latest_sent_delivery %></div>
    <div>Stock: <%= @player.stock %></div>
    <div>Backlog: <%= @player.backlog %></div>
    <form phx-submit="order">
      <input name="units" type="text" placeholder="Units of beer to order">
      <button type="submit">Send order</button>
    </form>
    """
  end

  def render(assigns) do
    ~L"""
    <h1><%= @game.name %></h1>
    <h2><%= @player.role %></h2>
    <h3>Round: <%= @game.round %>/50</h3>
    <p><%= inspect(@player) %></p>
    <div>Stock: <%= @player.stock %></div>
    <div>Backlog: <%= @player.backlog %></div>
    <div><%= inspect(assigns) %></div>
    <ol>
      <li>✅Pick role of Retailer or Manufacturer</li>
      <li>✅Start game when roles are filled</li>
      <li>✅Start round 1 with stock 12 and backlog 0</li>
      <li>✅See arrival of ordered beer add to stock</li>
      <li>✅See arrival of incoming order</li>
      <li>✅See departure of upstream order</li>
      <li>✅See update of stock and backlog</li>
      <li>✅Place order</li>
      <li>Start round 2</li>
      <li>…</li>
      <li>Show results after finishing round 50</li>
    </ol>
    """
  end

  def mount(%{name: name, role: role}, socket) do
    if connected?(socket), do: Games.subscribe(name)

    game = Games.get(name)
    socket = assign(socket, %{game: game, player: game.players[role]})

    {:ok, socket}
  end

  def handle_info({:game, game}, %{assigns: %{player: player}} = socket) do
    socket = assign(socket, %{game: game, player: game.players[player.role]})

    {:noreply, socket}
  end

  def handle_event("receive_delivery", _, socket) do
    %{assigns: %{game: game, player: player}} = socket

    Games.receive_delivery(game, player)

    # <li>See arrival of ordered beer add to stock</li>

    {:noreply, socket}
  end

  def handle_event("receive_order", _, socket) do
    %{assigns: %{game: game, player: player}} = socket

    Games.receive_order(game, player)

    # <li>See arrival of incoming order</li>

    {:noreply, socket}
  end

  def handle_event("send_delivery", _, socket) do
    %{assigns: %{game: game, player: player}} = socket

    Games.send_delivery(game, player)

    # <li>See departure of upstream order</li>
    # <li>See update of stock and backlog</li>

    {:noreply, socket}
  end

  def handle_event("order", %{"units" => units}, socket) do
    %{assigns: %{game: game, player: player}} = socket
    Games.send_order(game, player, String.to_integer(units))

    {:noreply, socket}
  end
end
