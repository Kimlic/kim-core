defmodule AttestationApi.DigitalVerifications.DigitalVerificationDocument do
  @moduledoc false

  use Ecto.Schema

  import Ecto.Changeset

  ##### Schema #####

  @primary_key {:id, :binary_id, autogenerate: true}
  schema "digital_verification_documents" do
    field :verification_id, Ecto.UUID
    field :context, :string
    field :content, :string
    field :timestamp, :integer
  end

  @fields ~w(verification_id context content timestamp)a

  ##### Public #####

  @spec changeset(map) :: Ecto.Changeset.t()
  def changeset(params) when is_map(params), do: changeset(%__MODULE__{}, params)

  @spec changeset(__MODULE__, map) :: Ecto.Changeset.t()
  def changeset(%__MODULE__{} = entity, params) do
    entity
    |> cast(params, @fields)
    |> unique_constraint(:context, name: "digital_verification_documents_verification_id_context_index")
  end
end
