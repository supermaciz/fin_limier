defmodule FinLimier.Storage.Postgres.Repo do
  use Ecto.Repo,
    otp_app: :fin_limier,
    adapter: Ecto.Adapters.Postgres
end
