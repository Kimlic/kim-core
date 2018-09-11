defmodule MobileApi.Plugs.AccountAddressTest do
  @moduledoc false

  use MobileApi.ConnCase, async: true
  use Quixir

  import Plug.Conn
  import Pollution.VG

  alias Core.Factory
  alias MobileApi.Plugs.AccountAddress

  describe "testing account address plug" do
    test "success", %{conn: conn} do
      account_address = Factory.generate(:account_address)

      assert %{assigns: %{account_address: ^account_address}} =
               conn
               |> put_req_header("account-address", account_address)
               |> AccountAddress.call([])
    end

    test "account address is missing", %{conn: conn} do
      assert %{status: 400, assigns: %{message: _}} = AccountAddress.call(conn, [])
    end

    test "account address is invalid", %{conn: conn} do
      invalid_addresses = [
        _address_invalid_length1 = "0x123456789012345678901234567890123456789077777777",
        _address_invalid_length2 = "0x12345678901234567890123456789012345",
        _address_invalid_starts_with = "001234567890123456789012345678901234567890",
        _address_invalid_chars = "0xRRR4567890123456789012345678901234567YYY"
      ]

      ptest [address: string(min: 40, max: 45, chars: :utf, must_have: invalid_addresses)], repeat_for: 1_000 do
        %{status: 400, assigns: %{message: _}} =
          conn
          |> put_req_header("account-address", "0x" <> address)
          |> AccountAddress.call([])
      end
    end

    test "plug init" do
      assert [] == AccountAddress.init([])
    end
  end
end
