defmodule AttestationApi.Plugs.AccountAddressTest do
  @moduledoc false

  use AttestationApi.ConnCase, async: true
  alias AttestationApi.Plugs.AccountAddress

  describe "testing account address plug" do
    test "success", %{conn: conn} do
      account_address = generate(:account_address)

      assert %{assigns: %{account_address: ^account_address}} =
               conn
               |> put_req_header("account-address", account_address)
               |> AccountAddress.call([])
    end

    test "account address is missing", %{conn: conn} do
      assert %{status: 400, assigns: %{message: _}} = AccountAddress.call(conn, [])
    end

    test "plug init" do
      assert [] == AccountAddress.init([])
    end
  end
end
