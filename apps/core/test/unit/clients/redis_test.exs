defmodule Core.Unit.Clients.RedisTest do
  @moduledoc false

  use ExUnit.Case, async: true

  import Core.Factory

  alias Core.Clients.Redis
  alias Core.Factory
  alias Core.Verifications.Verification

  @verification_status_new Verification.status(:new)
  @verification_status_passed Verification.status(:passed)

  test "get/set" do
    assert {:error, :not_found} = Redis.get("unknown_key")

    entity = %{value: 123}
    assert :ok = Redis.set("entity_key", entity)

    updated_entity = Map.put(entity, :redis_key, "entity_key")
    assert {:ok, ^updated_entity} = Redis.get("entity_key")
  end

  test "set with ttl" do
    assert :ok = Redis.set("key_with_ttl", %{}, 1)

    :timer.sleep(500)
    assert {:ok, _} = Redis.get("key_with_ttl")

    :timer.sleep(600)
    assert {:error, :not_found} = Redis.get("key_with_ttl")
  end

  test "upsert" do
    account_address = generate(:account_address)

    verification_data =
      Factory.verification(%{
        status: @verification_status_new,
        redis_key: "verification:email:#{account_address}",
        account_address: account_address
      })

    verification = struct(Verification, verification_data)
    assert {:ok, ^verification} = verification_data |> Verification.changeset() |> Redis.upsert()

    verification_data_updated = %{verification_data | status: @verification_status_passed}
    verification_updated = struct(Verification, verification_data_updated)

    assert {:ok, ^verification_updated} = verification_data_updated |> Verification.changeset() |> Redis.upsert()
  end

  test "update" do
    account_address = generate(:account_address)
    redis_key = "verification:email:#{account_address}"
    verification_data = Factory.verification(%{redis_key: redis_key, account_address: account_address})
    verification = struct(Verification, verification_data)

    assert :ok = Redis.set("redis_key", verification)

    assert {:ok, %{status: @verification_status_passed}} =
             Redis.update(verification, %{status: @verification_status_passed})
  end

  test "delete" do
    assert :ok = Redis.set("key", "some_value")
    assert {:ok, 1} = Redis.delete("key")
    assert {:error, :not_found} = Redis.delete("unknown_key")

    verification = insert(:verification)
    assert {:ok, 1} = Redis.delete(verification)
    assert {:error, :not_found} = Redis.delete(verification)
  end

  test "flush" do
    assert :ok = Redis.set("key", "some_value")
    assert :ok = Redis.flush()
    assert {:error, :not_found} = Redis.get("key")
  end
end
