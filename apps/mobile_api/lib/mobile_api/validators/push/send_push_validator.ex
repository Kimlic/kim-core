defmodule MobileApi.Validators.Push.SendPushValidator do
  @moduledoc """
  Changeset for send push request
  """

  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  embedded_schema do
    field(:message, :string)
    field(:device_os, :string)
    field(:device_token, :string)
  end

  @doc """
  Validate push schema
  """
  @spec changeset(map) :: Ecto.Changeset.t()
  def changeset(params) do
    fields = __MODULE__.__schema__(:fields)

    %__MODULE__{}
    |> cast(params, fields)
    |> validate_required(fields)
    |> validate_length(:message, max: 4096)
    |> validate_inclusion(:device_os, ~w(ios android))
  end
end
