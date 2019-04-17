defmodule Beer.Games do
  alias Beer.{Game, GameRepo}

  @topic inspect(__MODULE__)

  def create(name) do
    games = GameRepo.create(%Game{name: name})
    notify_subscribers({:games, games})
  end

  def all(), do: GameRepo.all()
  def get(name), do: GameRepo.get(name)

  def join(name, role), do: update(name, &Game.join(&1, role))

  def order(game, player, units) do
    update(game.name, &Game.order(&1, player.role, units))
  end

  def receive_delivery(game, player) do
    update(game.name, &Game.receive_delivery(&1, player.role))
  end

  def receive_incoming_order(game, player) do
    update(game.name, &Game.receive_incoming_order(&1, player.role))
  end

  def fulfill_order(game, player) do
    update(game.name, &Game.fulfill_order(&1, player.role))
  end

  def subscribe do
    Phoenix.PubSub.subscribe(Beer.PubSub, @topic)
  end

  def subscribe(name) do
    Phoenix.PubSub.subscribe(Beer.PubSub, "#{@topic}:#{name}")
  end

  defp notify_subscribers({:games, _games} = event) do
    Phoenix.PubSub.broadcast(Beer.PubSub, @topic, event)
  end

  defp notify_subscribers({:game, game} = event) do
    Phoenix.PubSub.broadcast(Beer.PubSub, "#{@topic}:#{game.name}", event)
  end

  defp update(name, fun) do
    games =
      GameRepo.update(name, fn game ->
        game = fun.(game)
        notify_subscribers({:game, game})
        game
      end)

    notify_subscribers({:games, games})
  end
end
