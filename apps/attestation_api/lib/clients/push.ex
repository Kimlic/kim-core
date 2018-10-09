defmodule AttestationApi.Clients.Push do
  @moduledoc """
  Sends push notifications
  """

  @behaviour AttestationApi.Clients.PushBehaviour

  @quorum_client Application.get_env(:quorum, :client)

  @available_device_os ["ios", "android"]
  @request_options [ssl: [{:versions, [:"tlsv1.2"]}]]

  @doc """
  Sends push notifications via HTTP call to Mobile API push endpoint with Quorum node_id info
  """
  @spec send(binary, binary, binary) :: :ok
  def send(message, device_os, device_token) when device_os in @available_device_os do
	  with {:ok, node_id} <- get_node_id(),
    {:ok, _} <- HTTPoison.post(push_url(), Jason.encode!(%{"message" => message, "device_os" => device_os, "device_token" => device_token}), headers(node_id), @request_options) do
      :ok
    else
      err ->
        Log.error("[#{__MODULE__}] Fail to send request for push notification. Reason: #{inspect(err)}")
        :ok
    end
  end

  @spec get_node_id :: {:ok, binary} | {:error, binary}
  defp get_node_id do
    with {:ok, %{"id" => node_id}} <- @quorum_client.request("admin_nodeInfo", %{"id" => 1}, []) do
      {:ok, node_id}
    end
  end

  @spec push_url :: binary
  defp push_url, do: Application.get_env(:attestation_api, :push_url)

  @spec headers(binary) :: list
  defp headers(node_id),
    do: [
      "Content-Type": "application/json",
      "account-address": "0x4aabc1c45ff64c562209d2207617f632184649a1",
      "node-id": node_id
    ]
end
