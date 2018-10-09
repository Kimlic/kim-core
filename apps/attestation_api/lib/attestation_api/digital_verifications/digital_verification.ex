defmodule AttestationApi.DigitalVerifications.DigitalVerification do
  @moduledoc """
  DigitalVerification entity
  Represents Veriff.me verification
  """

  use Ecto.Schema
  import Ecto.Changeset
  alias AttestationApi.DigitalVerifications.DigitalVerificationDocument

  @required_fields ~w(account_address session_id document_type)a
  @optional_fileds ~w(
    contract_address
    status
    device_os
    device_token
    veriffme_code
    veriffme_status
    veriffme_reason
    veriffme_document
    veriffme_person
  )a

  @status_new "NEW"
  @status_pending "PENDING"
  @status_passed "PASSED"
  @status_failed "FAILED"
  @status_resubmission_requested "RESUBMISSION_REQUESTED"

  @doc """
  Returns one of avaiable statuses as string
  """
  @spec status(atom) :: binary
  def status(:new), do: @status_new
  def status(:pending), do: @status_pending
  def status(:passed), do: @status_passed
  def status(:failed), do: @status_failed
  def status(:resubmission_requested), do: @status_resubmission_requested

  @primary_key {:id, :binary_id, autogenerate: true}
  schema "digital_verifications" do
    field(:account_address, :string)
    field(:session_id, :string)
    field(:document_type, :string)
    field(:contract_address, :string)
    field(:device_os, :string)
    field(:device_token, :string)
    field(:status, :string, default: @status_new)
    field(:veriffme_code, :integer)
    field(:veriffme_status, :string)
    field(:veriffme_reason, :string)
    field(:veriffme_document, :map)
    field(:veriffme_person, :map)
    timestamps()

    has_many(:documents, DigitalVerificationDocument, foreign_key: :verification_id)
  end

  @doc """
  Makes entity changeset
  """
  @spec changeset(map) :: Ecto.Changeset.t()
  def changeset(params) when is_map(params), do: changeset(%__MODULE__{}, params)

  @spec changeset(__MODULE__, map) :: Ecto.Changeset.t()
  def changeset(%__MODULE__{} = entity, params) do
    entity
    |> cast(params, @required_fields ++ @optional_fileds)
    |> validate_required(@required_fields)
  end
end
