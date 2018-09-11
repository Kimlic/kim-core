defmodule MobileApi.Validators.Verification.EmailValidator do
  @moduledoc """
  Changeset for email
  """

  use Ecto.Schema

  import Ecto.Changeset

  alias EView.Changeset.Validators.Email

  @required ~w(email)a

  @primary_key false
  embedded_schema do
    field(:email, :string)
  end

  @doc """
  Validate email schema
  """
  @spec changeset(map) :: Changeset.t()
  def changeset(attrs) do
    %__MODULE__{}
    |> cast(attrs, @required)
    |> validate_required(@required)
    |> Email.validate_email(:email)
  end
end
