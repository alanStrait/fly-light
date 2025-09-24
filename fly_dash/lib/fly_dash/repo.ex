defmodule FlyDash.Repo do
  use Ecto.Repo,
    otp_app: :fly_dash,
    adapter: Ecto.Adapters.Postgres
end
