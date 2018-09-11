defmodule Quorum.Ethereumex.HttpClient do
  @moduledoc false

  import Ethereumex.Config

  @type error :: {:error, map | binary | atom}

  @spec eth_get_transaction_receipt(binary, keyword) :: {:ok, map} | error
  def eth_get_transaction_receipt(hash, opts \\ []) do
    request("eth_getTransactionReceipt", [hash], opts)
  end

  @spec eth_send_transaction(map, keyword) :: {:ok, binary} | error
  def eth_send_transaction(transaction, opts \\ []) do
    request("eth_sendTransaction", [transaction], opts)
  end

  @spec eth_send_raw_transaction(binary, keyword) :: {:ok, binary} | error
  def eth_send_raw_transaction(data, opts \\ []) do
    request("eth_sendRawTransaction", [data], opts)
  end

  @spec eth_call(map, binary, keyword) :: {:ok, binary} | error
  def eth_call(transaction, block \\ "latest", opts \\ []) do
    request("eth_call", [transaction, block], opts)
  end

  @spec request(binary, map, any) :: {:ok, term} | {:error, term}
  def request(method_name, params, _) do
    %{}
    |> Map.put("method", method_name)
    |> Map.put("jsonrpc", "2.0")
    |> Map.put("params", params)
    |> Map.put("id", UUID.uuid4())
    |> Poison.encode!()
    |> post_request()
  end

  @spec post_request(binary) :: {:ok | :error, term}
  defp post_request(payload) do
    headers = [{"Content-Type", "application/json"}]

    with {:ok, response} <- HTTPoison.post(rpc_url(), payload, headers, http_options()),
         %HTTPoison.Response{body: body, status_code: code} = response do
      decode_body(body, code)
    else
      {:error, %HTTPoison.Error{reason: reason}} -> {:error, reason}
      e -> {:error, e}
    end
  end

  @spec decode_body(binary, integer) :: {:ok | :error, term}
  defp decode_body(body, code) do
    with {:ok, decoded_body} <- Poison.decode(body) do
      case {code, decoded_body} do
        {200, %{"error" => error}} -> {:error, error}
        {200, result = [%{} | _]} -> {:ok, format_batch(result)}
        {200, %{"result" => result}} -> {:ok, result}
        _ -> {:error, decoded_body}
      end
    else
      {:error, error} -> {:error, {:invalid_json, error}}
    end
  end

  @spec format_batch([map]) :: [map | nil | binary]
  defp format_batch(list) do
    list
    |> Enum.sort(fn %{"id" => id1}, %{"id" => id2} ->
      id1 <= id2
    end)
    |> Enum.map(fn %{"result" => result} ->
      result
    end)
  end
end
