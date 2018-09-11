defmodule MobileApi.Plugs.NodeIdTest do
  @moduledoc false

  use MobileApi.ConnCase, async: false

  import Mox
  import Plug.Conn

  alias MobileApi.Plugs.NodeId

  describe "testing node-id header" do
    setup %{conn: conn} do
      {:ok, conn: Map.put(conn, :params, %{"_format" => "json"})}
    end

    test "success", %{conn: conn} do
      node_id = generate(:node_id)
      expect(QuorumClientMock, :request, fn _method, _params, _opts -> {:ok, [%{"id" => node_id}]} end)

      assert %Plug.Conn{status: nil} =
               conn
               |> put_req_header("node-id", node_id)
               |> NodeId.call([])
    end

    test "node-id header is not sent", %{conn: conn} do
      assert %Plug.Conn{status: 422, assigns: %{message: _}} = NodeId.call(conn, [])
    end

    test "node-id header is invalid", %{conn: conn} do
      expect(QuorumClientMock, :request, fn _method, _params, _opts -> {:ok, []} end)

      assert %Plug.Conn{status: 401} =
               conn
               |> put_req_header("node-id", generate(:node_id))
               |> NodeId.call([])
    end

    test "quorum fail to respond", %{conn: conn} do
      expect(QuorumClientMock, :request, fn _method, _params, _opts -> {:error, :econnrefused} end)

      assert %Plug.Conn{status: 500, assigns: %{message: _}} =
               conn
               |> put_req_header("node-id", generate(:node_id))
               |> NodeId.call([])
    end

    test "plug init" do
      assert [] == NodeId.init([])
    end
  end
end
