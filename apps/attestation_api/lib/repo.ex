defmodule AttestationApi.Repo do
  @moduledoc false

  use Ecto.Repo, otp_app: :attestation_api, adapter: Ecto.Adapters.Postgres
end
