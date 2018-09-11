defmodule AttestationApi.Validators.CreateSessionValidator do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset

  alias AttestationApi.Validators.VeriffValidator

  @primary_key false
  embedded_schema do
    field(:first_name, :string)
    field(:last_name, :string)
    field(:document_type, :string)
    field(:lang, :string)
    field(:timestamp, :integer)
    field(:device_os, :string)
    field(:device_token, :string)
  end

  @spec changeset(map) :: Ecto.Changeset.t()
  def changeset(params) do
    fields = __MODULE__.__schema__(:fields)

    %__MODULE__{}
    |> cast(params, fields)
    |> validate_required(fields)
    |> validate_format(:lang, ~r/^\w{2}$/)
    |> validate_inclusion(:device_os, ~w(ios android))
    |> validate_inclusion(:document_type, ~w(PASSPORT ID_CARD DRIVERS_LICENSE RESIDENCE_PERMIT_CARD))
    |> VeriffValidator.validate_timestamp(:timestamp)
  end
end
