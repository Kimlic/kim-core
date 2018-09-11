defmodule MobileApi.ConfigControllerTest do
  @moduledoc false

  use MobileApi.ConnCase, async: true
  import Mox

  @moduletag :account_address

  describe "get config" do
    test "success", %{conn: conn} do
      address = generate(:account_address)

      expect(QuorumContractMock, :eth_call, fn :kimlic_context_storage, function, _args, _opts ->
        assert "getContext" == function
        {:ok, address}
      end)

      assert %{"data" => %{"context_contract" => ^address}} =
               conn
               |> get(config_path(conn, :get_config))
               |> json_response(200)
    end
  end
end
