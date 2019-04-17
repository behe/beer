defmodule Beer.GameRepo do
  use Agent

  def start_link(_) do
    Agent.start_link(fn -> [] end, name: __MODULE__)
  end

  def all do
    Agent.get(__MODULE__, & &1)
  end

  def create(game) do
    Agent.get_and_update(__MODULE__, fn games ->
      games = [game | games]
      {games, games}
    end)
  end

  def get(name) do
    Agent.get(__MODULE__, fn games ->
      Enum.find(games, fn game -> game.name == name end)
    end)
  end

  def update(name, fun) do
    Agent.get_and_update(__MODULE__, fn games ->
      games =
        Enum.reduce(games, [], fn
          %{name: ^name} = game, acc ->
            [fun.(game) | acc]

          game, acc ->
            [game | acc]
        end)

      {games, games}
    end)
  end
end
