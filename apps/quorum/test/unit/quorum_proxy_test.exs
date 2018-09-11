defmodule Quorum.Unit.QuorumProxyTest do
  use ExUnit.Case
  import Mox
  alias Quorum.Proxy

  setup :verify_on_exit!

  describe "proxy" do
    test "success" do
      expect(QuorumClientProxyMock, :call_rpc, fn _params ->
        body = %{
          jsonrpc: "2.0",
          result: "Geth/v1.7.2-stable-52f137c8/linux-amd64/go1.10.2",
          id: 1
        }

        {:ok, %HTTPoison.Response{status_code: 200, body: Jason.encode!(body)}}
      end)

      params = %{
        "jsonrpc" => "2.0",
        "method" => "web3_clientVersion",
        "params" => [],
        "id" => 1
      }

      assert {:ok, %HTTPoison.Response{status_code: 200, body: body}} = Proxy.proxy(params)
      resp = Jason.decode!(body)

      Enum.each(~w(jsonrpc result id), fn key ->
        assert Map.has_key?(resp, key), "RPC call response must contain `#{key}`"
      end)
    end

    test "success batch request" do
      expect(QuorumClientProxyMock, :call_rpc, fn params ->
        assert is_list(params)

        body = [
          %{
            jsonrpc: "2.0",
            result: "Geth/v1.7.2-stable-52f137c8/linux-amd64/go1.10.2",
            id: 1
          }
        ]

        {:ok, %HTTPoison.Response{status_code: 200, body: Jason.encode!(body)}}
      end)

      params = %{
        "_json" => [
          %{
            "jsonrpc" => "2.0",
            "method" => "web3_clientVersion",
            "params" => [],
            "id" => 1
          }
        ]
      }

      assert {:ok, %HTTPoison.Response{status_code: 200, body: body}} = Proxy.proxy(params)
      resp = Jason.decode!(body)
      assert is_list(resp)

      Enum.each(~w(jsonrpc result id), fn key ->
        assert Map.has_key?(hd(resp), key), "RPC call response must contain `#{key}`"
      end)
    end

    test "failed validation on quorum" do
      expect(QuorumClientProxyMock, :call_rpc, fn _params ->
        body = %{
          jsonrpc: "2.0",
          error: %{
            code: -32602,
            message: "invalid argument 0"
          },
          id: 1
        }

        {:ok, %HTTPoison.Response{status_code: 200, body: Jason.encode!(body)}}
      end)

      params = %{
        "jsonrpc" => "2.0",
        "method" => "eth_sendTransaction",
        "params" => [%{"from" => "invalid"}],
        "id" => 1
      }

      assert {:ok, %HTTPoison.Response{status_code: 200, body: body}} = Proxy.proxy(params)
      resp = Jason.decode!(body)

      Enum.each(~w(jsonrpc error id), fn key ->
        assert Map.has_key?(resp, key), "RPC call response must contain `#{key}`"
      end)

      assert -32602 == resp["error"]["code"]
    end

    test "method not allowed" do
      params = %{
        "jsonrpc" => "2.0",
        "method" => "not_allowed",
        "params" => [],
        "id" => 1
      }

      assert {:ok, %HTTPoison.Response{status_code: 404, body: body}} = Proxy.proxy(params)
      resp = Jason.decode!(body)

      Enum.each(~w(jsonrpc error id), fn key ->
        assert Map.has_key?(resp, key), "RPC call response must contain `#{key}`"
      end)

      assert -32601 == resp["error"]["code"]
    end
  end
end
