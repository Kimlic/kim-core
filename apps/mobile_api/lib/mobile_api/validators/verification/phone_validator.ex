defmodule MobileApi.Validators.Verification.PhoneValidator do
  @moduledoc """
  Changeset for phone
  """

  use Ecto.Schema

  import Ecto.Changeset

  alias EView.Changeset.Validators.PhoneNumber

  @required ~w(phone)a

  @primary_key false
  embedded_schema do
    field(:phone, :string)
  end

  @doc """
  Validate phone schema
  """
  @spec changeset(map) :: Changeset.t()
  def changeset(attrs) do
    %__MODULE__{}
    |> cast(attrs, @required)
    |> validate_required(@required)
    |> PhoneNumber.validate_phone_number(:phone)
  end
end
