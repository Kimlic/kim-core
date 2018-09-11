defmodule Quorum.Jobs.TransactionStatus do
  @moduledoc """
  TaskBunny Job for validation transaction status in Quorum.
  Data stored in RabbitMQ queue
  Read more https://github.com/shinyscorpion/task_bunny#workers
  """

  use TaskBunny.Job
  alias Log
  alias Quorum.Contract

  @quorum_client Application.get_env(:quorum, :client)

  @doc """
  Takes data from queue and check quorum transaction status
  """
  @spec perform(map) :: :ok | :retry | {:error, term}
  def perform(%{"transaction_hash" => transaction_hash, "meta" => meta}) do
    case @quorum_client.eth_get_transaction_receipt(transaction_hash, []) do
      {:ok, %{"status" => "0x1"} = status} ->
        Log.info("[#{__MODULE__}]#perform status 0x1 response #{transaction_hash}}: #{inspect(status)}}")

        maybe_callback(meta, status, transaction_hash)

      {:ok, %{"status" => status} = resp} ->
        msg =
          "[#{__MODULE__}]#perform transaction status is `#{status}}`" <>
            "for tx `#{transaction_hash}`. Response: #{inspect(resp)}"

        Log.error(msg)
        {:reject, msg}

      {:ok, _} ->
        :retry

      err ->
        Log.error(
          "[#{__MODULE__}]#perform eth_get_transaction_receipt failed for tx `#{transaction_hash}` with: #{inspect(err)}"
        )

        err
    end
  end

  @spec maybe_callback(map, map, binary) :: :ok
  defp maybe_callback(%{"callback" => %{"m" => module, "f" => function, "a" => args}} = meta, status, transaction_hash) do
    merged_args =
      args
      |> Kernel.++([status])
      |> put_verification_contract_address(transaction_hash, meta)

    Kernel.apply(String.to_atom(module), String.to_atom(function), merged_args)

    :ok
  end

  @spec maybe_callback(map, map, binary) :: :ok
  defp maybe_callback(_meta, _, _), do: :ok

  @spec put_verification_contract_address(list, binary, map) :: list
  defp put_verification_contract_address(args, transaction_hash, %{
         "verification_contract_return_key" => return_key,
         "verification_contract_factory_address" => contract_factory_address
       }) do
    data = Contract.hash_data(:verification_contract_factory, "getVerificationContract", [{return_key}])
    params = %{data: data, to: contract_factory_address}

    case fetch_verification_contract_address(params) do
      {:ok, _} = resp ->
        Kernel.++(args, [resp])

      {:error, err} = resp ->
        msg =
          "[#{__MODULE__}]#put_verification_contract_address " <>
            "Cannot get Verification Contract address for transaction `#{transaction_hash}`. Error: #{inspect(err)}"

        Log.error(msg)
        Kernel.++(args, [resp])
    end
  end

  @spec put_verification_contract_address(list, term, term) :: list
  defp put_verification_contract_address(args, _, _), do: args

  @spec fetch_verification_contract_address(map, integer) :: {:ok, binary} | {:error, map}
  defp fetch_verification_contract_address(params, attempt \\ 1) do
    case @quorum_client.eth_call(params, "latest", []) do
      {:ok, response} ->
        {:ok, String.replace(response, String.duplicate("0", 24), "")}

      {:error, err} ->
        case attempt do
          3 ->
            {:error, err}

          _ ->
            :timer.sleep(50)
            fetch_verification_contract_address(params, attempt + 1)
        end
    end
  end

  @doc """
  If a job fails more than max_retry times, the payload is sent to jobs.[job_name].rejected queue.
  Read more https://github.com/shinyscorpion/task_bunny#control-job-execution
  """
  @spec max_retry :: integer
  def max_retry, do: 5

  @doc """
  TaskBunny retries the job automatically if the job has failed.
  Read more https://github.com/shinyscorpion/task_bunny#control-job-execution
  """
  @spec retry_interval(integer) :: integer
  def retry_interval(failed_count) do
    [1, 10, 20, 40, 60]
    |> Enum.map(&(&1 * 1000))
    |> Enum.at(failed_count - 1, 1000)
  end
end
