import Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :fly_global, FlyGlobalWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "ndZrH7Y8Pf/3jk1hsMRw45w1cmZoI9IsIBrOOcB9MMD8LwkUUrCmVqVPBhD0LrDM",
  server: false

# Print only warnings and errors during test
config :logger, level: :warning

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime
