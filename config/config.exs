# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :fin_limier,
  ecto_repos: [FinLimier.Storage.Postgres.Repo],
  generators: [timestamp_type: :utc_datetime]

# Configure Oban for background discovery
config :fin_limier, Oban,
  engine: Oban.Engines.Basic,
  repo: FinLimier.Storage.Postgres.Repo,
  queues: [discovery: 5],
  plugins: [
    {Oban.Plugins.Pruner, max_age: 60 * 60 * 24 * 7},
    {Oban.Plugins.Cron,
     crontab: [
       {"0 * * * *", FinLimier.Workers.DiscoverJobsWorker}
     ]}
  ]

# Job discovery defaults
config :fin_limier, FinLimier.JobDiscovery,
  source: FinLimier.Adapters.FranceTravail.Source,
  extractor: FinLimier.Adapters.InstructorLiteExtractor,
  job_offer_store: FinLimier.Storage.Postgres.JobOfferStore,
  ets_job_offer_table: :fin_limier_job_offers,
  france_travail_query: "Elixir"

# Configure the endpoint
config :fin_limier, FinLimierWeb.Endpoint,
  url: [host: "localhost"],
  adapter: Bandit.PhoenixAdapter,
  render_errors: [
    formats: [html: FinLimierWeb.ErrorHTML, json: FinLimierWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: FinLimier.PubSub,
  live_view: [signing_salt: "BNMwyLUX"]

# Configure LiveView
config :phoenix_live_view,
  # the attribute set on all root tags. Used for Phoenix.LiveView.ColocatedCSS.
  root_tag_attribute: "phx-r"

# Configure the mailer
#
# By default it uses the "Local" adapter which stores the emails
# locally. You can see the emails in your browser, at "/dev/mailbox".
#
# For production it's recommended to configure a different adapter
# at the `config/runtime.exs`.
config :fin_limier, FinLimier.Mailer, adapter: Swoosh.Adapters.Local

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.25.4",
  fin_limier: [
    args:
      ~w(js/app.js --bundle --target=es2022 --outdir=../priv/static/assets/js --external:/fonts/* --external:/images/* --alias:@=.),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => [Path.expand("../deps", __DIR__), Mix.Project.build_path()]}
  ]

# Configure tailwind (the version is required)
config :tailwind,
  version: "4.3.0",
  fin_limier: [
    args: ~w(
      --input=assets/css/app.css
      --output=priv/static/assets/css/app.css
    ),
    cd: Path.expand("..", __DIR__),
    env: %{"NODE_PATH" => [Path.expand("../deps", __DIR__), Mix.Project.build_path()]}
  ]

# Configure Elixir's Logger
config :logger, :default_formatter,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
