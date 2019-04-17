defmodule BeerWeb.Router do
  use BeerWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  scope "/", BeerWeb do
    pipe_through :browser

    # redirect("/", to: "/game")
    get "/game", GameController, :index
    get "/game/:game/role/:role", GameController, :show
  end
end
