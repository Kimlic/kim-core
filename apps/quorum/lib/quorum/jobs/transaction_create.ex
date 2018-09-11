defmodule Quorum.Jobs.TransactionCreate do
  @moduledoc """
  TaskBunny Job for transaction creation in Quorum.
  Data stored in RabbitMQ queue
  Read more https://github.com/shinyscorpion/task_bunny#workers
  """

  use TaskBunny.Job
  alias Log
  alias Quorum.Jobs.TransactionStatus

  @quorum_client Application.get_env(:quorum, :client)

  @doc """
  Takes data from queue and create quorum transaction
  """
  @spec perform(map) :: :ok | {:error, term}
  def perform(%{"transaction_data" => transaction_data, "meta" => meta}) do
    Log.info("Quorum.eth_send_transaction data #{inspect(transaction_data)}}")

    case @quorum_client.eth_send_transaction(transaction_data, []) do
      {:ok, transaction_hash} ->
        TransactionStatus.enqueue!(%{meta: meta, transaction_hash: transaction_hash}, delay: 200)

      err ->
        Log.error("Quorum.sendTransaction failed: #{inspect(err)}")
        err
    end
  end

  @spec max_retry :: integer
  def max_retry, do: 5

  @spec retry_interval(integer) :: integer
  def retry_interval(failed_count) do
    [1, 10, 20, 40, 60]
    |> Enum.map(&(&1 * 1000))
    |> Enum.at(failed_count - 1, 1000)
  end
end
