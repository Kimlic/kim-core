defmodule MobileApi.PushControllerTest do
  @moduledoc false

  use MobileApi.ConnCase, async: false
  import Mox

  @moduletag :account_address

  describe "send push" do
    setup %{conn: conn} do
      node_id = generate(:node_id)
      expect(QuorumClientMock, :request, fn _method, _params, _opts -> {:ok, [%{"id" => node_id}]} end)

      {:ok, conn: put_req_header(conn, "node-id", node_id)}
    end

    test "success", %{conn: conn} do
      assert %{"data" => %{}} =
               conn
               |> post(push_path(conn, :send_push), %{message: "Test message", device_os: "ios", device_token: "1234"})
               |> json_response(200)
    end

    test "invalid device os", %{conn: conn} do
      assert conn
             |> post(push_path(conn, :send_push), %{message: "Test message", device_os: "linux", device_token: "1234"})
             |> json_response(422)
    end
  end
end
