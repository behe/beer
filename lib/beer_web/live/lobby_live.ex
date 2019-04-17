defmodule BeerWeb.LobbyLive do
  use Phoenix.LiveView
  alias Beer.{Game, Games}

  def render(%{view: "lobby"} = assigns) do
    ~L"""
    <button phx-click="new">New Game</button>

    <%= if @games != [] do %>
      <ol>
        <%= for game <- @games do %>
          <li><a href="#" phx-click="join" phx-value="<%= game.name %>"><%= game.name %></a></li>
        <% end %>
      </ol>
    <% else %>
      <p>There are currently no active games. <a href="#" phx-click="new">Create a new one?</a></p>
    <% end %>
    """
  end

  def render(%{view: "new"} = assigns) do
    ~L"""
    <form phx-submit="create">
      <label for="name">Name this game:</label>
      <input id="name" type="text" name="game">
      <input type="submit" value="Create">
    </form>
    """
  end

  def render(%{view: "join"} = assigns) do
    ~L"""
    <h1><%= @game.name %></h1>
    <h2>Pick a role:</h2>
    <%= for role <- (["retailer", "manufacturer"] -- Map.keys(@game.players)) do %>
      <a href="/game/<%= @game.name %>/role/<%= role %>"><%= role %></a>
    <% end %>
    """
  end

  def mount(_session, socket) do
    if connected?(socket), do: Games.subscribe()

    {:ok, assign(socket, %{games: Games.all(), view: "lobby"})}
  end

  def handle_info({:games, games}, socket) do
    {:noreply, assign(socket, :games, games)}
  end

  def handle_event("new", _, socket) do
    {:noreply, assign(socket, :view, "new")}
  end

  def handle_event("create", %{"game" => name}, socket) do
    Games.create(name)
    {:noreply, assign(socket, :view, "lobby")}
  end

  def handle_event("join", name, socket) do
    {:noreply, assign(socket, %{view: "join", game: Games.get(name)})}
  end
end
