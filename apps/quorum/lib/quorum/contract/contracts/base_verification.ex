defmodule Quorum.Contract.BaseVerification do
  @moduledoc """
  BaseVerification with generated functions via macros
  """

  @contract :base_verification
  @contract_client Application.get_env(:quorum, :contract_client)

  use Quorum.Contract, :base_verification

  alias Quorum.ABI.TypeDecoder

  call_function("finalizeVerification", [status])

  call_function("withdraw", [])

  @doc """
  Returns BaseVerification.tokens_unlock_at in unix timestamp format
  """
  @spec tokens_unlock_at(map) :: {:ok, integer} | {:error, term}
  def tokens_unlock_at(options) do
    case @contract_client.eth_call(@contract, "tokensUnlockAt", [], options) do
      {:ok, "0x" <> time} ->
        time =
          time
          |> Base.decode16!(case: :lower)
          |> TypeDecoder.decode_raw([{:tuple, [{:uint, 256}]}])
          |> to_timestamp()

        {:ok, time}

      err ->
        err
    end
  end

  @spec to_timestamp(integer) :: integer
  defp to_timestamp([{timestamp}]), do: round(timestamp / 1_000_000_000)
end
