defmodule Quorum.Proxy do
  @moduledoc """
  Proxy module for /api/quorum proxy endpoint
  """
  @quorum_proxy_client Application.get_env(:quorum, :proxy_client)

  alias HTTPoison.Response

  @doc """
  Proxied batch request to quorum
  """
  @spec proxy(map) :: {:ok, map} | {:error, map}
  def proxy(%{"_json" => batch_methods}) when is_list(batch_methods) do
    with :ok <- validate_rpc_method(batch_methods) do
      @quorum_proxy_client.call_rpc(batch_methods)
    end
  end

  @doc """
  Proxied request to quorum
  """
  def proxy(%{"method" => method, "id" => id} = payload) do
    with :ok <- validate_rpc_method(method, id) do
      @quorum_proxy_client.call_rpc(payload)
    end
  end

  @spec validate_rpc_method(list) :: :ok | {:error, map}
  defp validate_rpc_method(batch_payloads) do
    Enum.reduce_while(batch_payloads, :ok, fn %{"method" => method, "id" => id}, acc ->
      case validate_rpc_method(method, id) do
        :ok -> {:cont, acc}
        err -> {:halt, err}
      end
    end)
  end

  @spec validate_rpc_method(binary, integer) :: :ok | {:error, map}
  defp validate_rpc_method(method, id) do
    case method in Application.get_env(:quorum, :allowed_rpc_methods) do
      true ->
        :ok

      false ->
        body = %{
          id: id,
          jsonrpc: "2.0",
          error: %{code: -32_601, message: "Method not found", data: "Method `#{method}` not allowed for RPC"}
        }

        {:ok, %Response{status_code: 404, body: Jason.encode!(body)}}
    end
  end
end
