defmodule Bugzero.Repo do
  use Ecto.Repo,
    otp_app: :bugzero,
    adapter: Ecto.Adapters.SQLite3
end
