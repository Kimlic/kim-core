defmodule AttestationApi.Factories do
  @moduledoc false

  use ExMachina.Ecto, repo: AttestationApi.Repo

  alias AttestationApi.DigitalVerifications.DigitalVerification
  alias AttestationApi.DigitalVerifications.DigitalVerificationDocument
  alias Ecto.UUID

  ### Factories

  @spec digital_verification_factory :: %DigitalVerification{}
  def digital_verification_factory do
    %DigitalVerification{
      account_address: generate(:account_address),
      session_id: UUID.generate(),
      contract_address: nil,
      status: DigitalVerification.status(:new),
      document_type: "ID_CARD",
      veriffme_code: nil,
      veriffme_status: nil,
      veriffme_reason: nil,
      device_os: sequence(:devise_os, ["ios", "android"]),
      device_token: UUID.generate(),
      inserted_at: NaiveDateTime.utc_now(),
      updated_at: NaiveDateTime.utc_now()
    }
  end

  @spec digital_verification_document_factory :: %DigitalVerificationDocument{}
  def digital_verification_document_factory do
    %DigitalVerificationDocument{
      verification_id: nil,
      context: sequence(:context, ["face", "document-front", "document-back"]),
      content: "data:image/gif;base64,R0lGODlhAQABAIAAAAUEBAAAACwAAAAAAQABAAACAkQBADs=",
      timestamp: generate(:unix_timestamp)
    }
  end

  ### Generators

  @spec generate(atom) :: binary
  def generate(:phone), do: "+38097#{Enum.random(1_000_000..9_999_999)}"

  @spec generate(atom) :: binary
  def generate(:account_address) do
    account_address =
      :sha256
      |> :crypto.hash(to_string(:rand.uniform()))
      |> Base.encode16(case: :lower)
      |> String.slice(0..39)

    "0x" <> account_address
  end

  @spec generate(atom) :: integer
  def generate(:unix_timestamp), do: DateTime.utc_now() |> DateTime.to_unix()
end
