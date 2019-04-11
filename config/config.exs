# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

# Configures the endpoint
config :beer, BeerWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "9g0PhfRHhF0U4vWhQpBeQZpSsFJznhXn1AqbG5I6H9HdHIaXC1VR4YwbUb3f69Ik",
  render_errors: [view: BeerWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Beer.PubSub, adapter: Phoenix.PubSub.PG2],
  live_view: [signing_salt: "3JiBBwTf4MvRCMzlVCXOf6Z2QFCGuY6U"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
