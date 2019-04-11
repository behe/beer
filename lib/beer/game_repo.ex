defmodule Beer.GameRepo do
  use Agent

  @topic inspect(__MODULE__)

  def start_link(_) do
    Agent.start_link(fn -> [] end, name: __MODULE__)
  end

  def all do
    Agent.get(__MODULE__, & &1)
  end

  def create(game) do
    Agent.update(__MODULE__, fn games ->
      games = [game | games]
      notify_subscribers({:games, games})
      games
    end)
  end

  def subscribe do
    Phoenix.PubSub.subscribe(Beer.PubSub, @topic)
  end

  defp notify_subscribers(event) do
    Phoenix.PubSub.broadcast(Beer.PubSub, @topic, event)
  end
end
