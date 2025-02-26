defmodule EFE.Repo do
  use Ecto.Repo,
    otp_app: :efe,
    adapter: Ecto.Adapters.Postgres
end
