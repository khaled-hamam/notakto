import Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :notakto, NotaktoWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "009rBXqQb40qxAcyVkuo51a3oti7/t+eSFRHW+9N+zWYYP0qTZv50JO+Wh0C2W1+",
  server: false

# In test we don't send emails.
config :notakto, Notakto.Mailer,
  adapter: Swoosh.Adapters.Test

# Disable swoosh api client as it is only required for production adapters.
config :swoosh, :api_client, false

# Print only warnings and errors during test
config :logger, level: :warning

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime
