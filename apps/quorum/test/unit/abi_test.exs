defmodule Quorum.Unit.ABITest do
  @moduledoc false

  use ExUnit.Case

  alias Quorum.Contract
  alias Quorum.ABI.{TypeDecoder, TypeEncoder}

  test "encode string" do
    email = String.duplicate("1234567890", 6) <> "@example.com"
    hash = Contract.hash_data(:account_storage_adapter, "setFieldMainData", [{"email", email}])

    # setFieldMainData decoded signature
    assert "0x849b177e" <> File.read!("test/data/setFieldMainData.txt") == hash
  end

  test "decode string" do
    email = String.duplicate("1234567890", 6) <> "@example.com"

    decoded =
      "test/data/setFieldMainData.txt"
      |> File.read!()
      |> Base.decode16!(case: :lower)
      |> TypeDecoder.decode_raw([{:tuple, [:string, :string]}])

    assert [{"email", email}] == decoded
  end

  test "decode uint256" do
    time = 1_533_645_780_738_957_010

    decoded =
      "00000000000000000000000000000000000000000000000015489ab64438ded2"
      |> Base.decode16!(case: :lower)
      |> TypeDecoder.decode_raw([{:tuple, [{:uint, 256}]}])

    assert [{time}] == decoded
  end

  test "encode and decode string" do
    long_string = String.duplicate("1234567890", 20) <> "@example.com"
    input = [{"awesome", 99, long_string, true}]
    types = [{:tuple, [:string, {:uint, 32}, :string, :bool]}]

    encoded = TypeEncoder.encode_raw(input, types)
    assert is_binary(encoded)

    assert input == TypeDecoder.decode_raw(encoded, types)
  end

  test "hash method without input params" do
    assert "0x009aa2aa" == Contract.hash_data(:base_verification, "tokensUnlockAt", [])
  end
end
