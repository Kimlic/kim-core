defmodule Core.Factory do
  @moduledoc false

  alias Core.Clients.Redis
  alias Core.Verifications.Verification

  @spec build(atom, map) :: %Verification{} | term
  def build(entity_atom, params \\ %{}), do: :erlang.apply(__MODULE__, entity_atom, [params])

  @spec insert(atom, map) :: {:ok, term} | {:error, binary}
  def insert(atom, params \\ %{})

  def insert(:verification, params) do
    params
    |> verification()
    |> changeset(Verification)
    |> redis_insert()
  end

  @spec redis_insert(Ecto.Changeset.t()) :: term
  defp redis_insert(changeset) do
    with {:ok, entity} <- Redis.upsert(changeset) do
      entity
    else
      _ -> raise "[Core.Factory]: Can't set data in redis"
    end
  end

  ### Factories

  @spec verification(map) :: map
  def verification(params \\ %{}) do
    %{
      entity_type: Verification.entity_type(:email),
      account_address: generate(:account_address),
      token: "123456",
      contract_address: generate(:account_address),
      status: Verification.status(:new)
    }
    |> Map.merge(params)
  end

  @spec changeset(map, module) :: Ecto.Changeset.t()
  defp changeset(data, entity_module) do
    case entity_module.changeset(data) do
      %{valid?: true} = changeset -> changeset
      _ -> raise "Changeset of #{entity_module} is not valid in `Core.Factory`"
    end
  end

  # ToDo: use Faker instead
  @spec generate(atom) :: binary
  def generate(:phone), do: "+38097#{random_string()}"

  # ToDo: use Faker instead
  @spec generate(atom) :: binary
  def generate(:email), do: "test#{random_string()}@email.local"

  @spec generate(atom) :: binary
  def generate(:node_id),
    do: 128 |> :crypto.strong_rand_bytes() |> Base.encode16() |> String.slice(0, 128) |> String.downcase()

  @spec generate(atom) :: binary
  def generate(:account_address) do
    account_address =
      :sha256
      |> :crypto.hash(random_string())
      |> Base.encode16(case: :lower)
      |> String.slice(0..39)

    "0x" <> account_address
  end

  @spec generate(atom) :: binary
  def generate(:unix_timestamp), do: DateTime.utc_now() |> DateTime.to_unix()

  @spec random_string :: binary
  def random_string, do: "#{Enum.random(100_000..999_999)}"
end
