# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :fly_kv,
  generators: [timestamp_type: :utc_datetime]

# Configures the endpoint
config :fly_kv, FlyKvWeb.Endpoint,
  url: [host: "localhost"],
  adapter: Bandit.PhoenixAdapter,
  render_errors: [
    formats: [json: FlyKvWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: FlyKv.PubSub,
  live_view: [signing_salt: "JzW9bXnM"]

# Configures Elixir's Logger
config :logger, :default_formatter,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Use priv/data to bootstrap machines
config :fly_kv, FlyKv.Machine, data_path: "priv/data/machine.csv"

# Use priv/data to bootstrap regions
config :fly_kv, FlyKv.Region, data_path: "priv/data/fly_io_regions.csv"

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
