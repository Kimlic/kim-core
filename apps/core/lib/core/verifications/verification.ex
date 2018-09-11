defmodule Core.Verifications.Verification do
  @moduledoc """
  Verification entity for email and phone
  """

  use Ecto.Schema
  import Ecto.Changeset
  alias Ecto.Changeset

  @entity_type_phone "PHONE"
  @entity_type_email "EMAIL"
  @entity_types [@entity_type_phone, @entity_type_email]

  @status_new "NEW"
  @status_passed "PASSED"
  @status_expired "EXPIRED"

  @required_fields ~w(account_address entity_type token status)a
  @optional_fileds ~w(contract_address)a

  @doc """
  Returns entity type as string
  """
  @spec entity_type(atom) :: binary
  def entity_type(:phone), do: @entity_type_phone
  def entity_type(:email), do: @entity_type_email

  @doc """
  Returns entity status as string
  """
  @spec status(atom) :: binary
  def status(:new), do: @status_new
  def status(:passed), do: @status_passed
  def status(:expired), do: @status_expired

  defguard allowed_type_atom(type) when type in ~w(phone email)a

  @primary_key false
  embedded_schema do
    field(:redis_key, :string, virtual: true)
    field(:account_address, :string)
    field(:entity_type, :string)
    field(:token, :string)
    field(:status, :string)
    field(:contract_address, :string)
  end

  @doc """
  Makes entity changeset
  """
  @spec changeset(map) :: Ecto.Changeset.t()
  def changeset(params) do
    %__MODULE__{}
    |> cast(params, @required_fields ++ @optional_fileds)
    |> validate_required(@required_fields)
    |> validate_inclusion(:entity_type, @entity_types)
    |> put_redis_key()
  end

  @doc """
  Sets redis key to entity changeset
  """
  @spec put_redis_key(Ecto.Changeset.t()) :: Ecto.Changeset.t()
  def put_redis_key(%Changeset{valid?: true} = changeset) do
    {_, type} = fetch_field(changeset, :entity_type)
    {_, account_address} = fetch_field(changeset, :account_address)
    put_change(changeset, :redis_key, redis_key(type, account_address))
  end

  def put_redis_key(changeset), do: changeset

  @doc """
  Returns redis key formed by entity_type and account_address
  """
  @spec redis_key(binary, binary) :: binary
  def redis_key(type, account_address) when is_binary(type) do
    type
    |> String.downcase()
    |> String.to_atom()
    |> redis_key(account_address)
  end

  @spec redis_key(atom, binary) :: binary
  def redis_key(type, account_address) when allowed_type_atom(type),
    do: "verification:#{Atom.to_string(type)}:#{account_address}"
end
