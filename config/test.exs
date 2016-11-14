use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :postcode_huisnummer, PostcodeHuisnummer.Endpoint,
  http: [port: 4001],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# Configure your database
config :postcode_huisnummer, PostcodeHuisnummer.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "postgres",
  password: "postgres",
  database: "postcode_huisnummer_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox
