defmodule MobileApi.QuorumControllerTest do
  @moduledoc false

  use MobileApi.ConnCase, async: true
  import Mox

  @moduletag :authorized
  @moduletag :account_address

  describe "proxy request to Quorum" do
    test "success", %{conn: conn} do
      expect(QuorumClientProxyMock, :call_rpc, fn params ->
        body = %{
          jsonrpc: "2.0",
          result: "Geth/v1.7.2-stable-52f137c8/linux-amd64/go1.10.2",
          id: params["id"]
        }

        {:ok, %HTTPoison.Response{status_code: 200, body: Jason.encode!(body)}}
      end)

      rpc_data = %{
        "jsonrpc" => "2.0",
        "method" => "web3_clientVersion",
        "params" => [],
        "id" => 100
      }

      assert 100 ==
               conn
               |> post(quorum_path(conn, :proxy), rpc_data)
               |> json_response(200)
               |> Map.get("id")
    end

    test "batch success", %{conn: conn} do
      expect(QuorumClientProxyMock, :call_rpc, fn params ->
        {:ok, %HTTPoison.Response{status_code: 200, body: Jason.encode!(params)}}
      end)

      rpc_data = %{
        "_json" => [
          %{
            "jsonrpc" => "2.0",
            "method" => "web3_clientVersion",
            "params" => [],
            "id" => 100
          }
        ]
      }

      conn
      |> post(quorum_path(conn, :proxy), rpc_data)
      |> json_response(200)
    end

    test "invalid request", %{conn: conn} do
      rpc_data = %{
        "method" => "eth_sendTransaction",
        "params" => [%{"from" => "invalid"}]
      }

      conn
      |> post(quorum_path(conn, :proxy), rpc_data)
      |> json_response(422)
    end

    test "failed validation on quorum", %{conn: conn} do
      expect(QuorumClientProxyMock, :call_rpc, fn params ->
        body = %{
          jsonrpc: "2.0",
          error: %{
            code: -32602,
            message: "invalid argument 0"
          },
          id: params["id"]
        }

        {:ok, %HTTPoison.Response{status_code: 200, body: Jason.encode!(body)}}
      end)

      rpc_data = %{
        "jsonrpc" => "2.0",
        "method" => "eth_sendTransaction",
        "params" => [%{"from" => "invalid"}],
        "id" => 199
      }

      assert -32602 ==
               conn
               |> post(quorum_path(conn, :proxy), rpc_data)
               |> json_response(200)
               |> get_in(~w(error code))
    end

    test "method not allowed", %{conn: conn} do
      rpc_data = %{
        "jsonrpc" => "2.0",
        "method" => "not_allowed",
        "params" => [],
        "id" => 200
      }

      assert -32601 ==
               conn
               |> post(quorum_path(conn, :proxy), rpc_data)
               |> json_response(404)
               |> get_in(~w(error code))
    end
  end
end
