defmodule BeerWeb.LobbyLive do
  use Phoenix.LiveView
  alias Beer.{Game, GameRepo}

  def render(%{view: "lobby"} = assigns) do
    ~L"""
    <button phx-click="new">New Game</button>

    <%= if @games != [] do %>
      <ol>
        <%= for game <- @games do %>
          <li><a href="/join/<%= game.name %>"><%= game.name %></a></li>
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
      <label for="name">Game Name</label>
      <input id="name" type="text" name="name">
      <input type="submit" value="Create">
    </form>
    """
  end

  def mount(_session, socket) do
    if connected?(socket), do: GameRepo.subscribe()

    {:ok, assign(socket, %{games: GameRepo.all(), view: "lobby"})}
  end

  def handle_info({:games, games}, socket) do
    {:noreply, assign(socket, :games, games)}
  end

  def handle_event("new", _, socket) do
    {:noreply, assign(socket, :view, "new")}
  end

  def handle_event("create", %{"name" => name}, socket) do
    GameRepo.create(%Game{name: name})
    {:noreply, assign(socket, :view, "lobby")}
  end
end
