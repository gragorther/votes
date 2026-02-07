defmodule Votes.Repo do
  use Ecto.Repo,
    otp_app: :votes,
    adapter: Ecto.Adapters.Postgres
end
