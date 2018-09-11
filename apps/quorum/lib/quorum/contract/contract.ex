defmodule Quorum.Contract do
  @moduledoc """
  Defines a contracts. Hash contract data

  Macros generates two basic functions for Quorum calls:
   - `eth_call` - direct call to Quorum
   - `call_function` - create transaction via TaskBunny jobs (RabbitMQ queues)

  """

  alias Quorum.ABI
  alias Quorum.Contract.Store, as: ContractStore

  @behaviour Quorum.Contract.Behaviour

  @quorum_client Application.get_env(:quorum, :client)

  defmacro __using__(contract_name) do
    quote do
      import Quorum.Contract
      @contract unquote(contract_name)
      @contract_client Application.get_env(:quorum, :contract_client)
    end
  end

  @spec call_function(binary, list) :: :ok
  defmacro call_function(name, args) do
    contract_args = Macro.escape(args)

    function_name = name |> Macro.underscore() |> String.to_atom()
    contract_function = Macro.escape(name)

    quote bind_quoted: [
            generated_function_name: function_name,
            contract_function: contract_function,
            contract_args: contract_args
          ] do
      def unquote(generated_function_name)(unquote_splicing(contract_args), options) do
        @contract_client.call_function(
          @contract,
          unquote(contract_function),
          [{unquote_splicing(contract_args)}],
          options
        )
      end
    end
  end

  @spec eth_call(binary, list) :: :ok
  defmacro eth_call(name, args) do
    contract_args = Macro.escape(args)

    function_name = name |> Macro.underscore() |> String.to_atom()
    contract_function = Macro.escape(name)

    quote bind_quoted: [
            generated_function_name: function_name,
            contract_function: contract_function,
            contract_args: contract_args
          ] do
      def unquote(generated_function_name)(unquote_splicing(contract_args), options) do
        @contract_client.eth_call(@contract, unquote(contract_function), [{unquote_splicing(contract_args)}], options)
      end
    end
  end

  @spec call_function(atom, binary, list, map) :: :ok
  def call_function(contract, function, args, options \\ %{}) do
    meta = Map.get(options, :meta, %{})

    options
    |> Map.delete(:meta)
    |> Map.put(:data, hash_data(contract, function, args))
    |> Quorum.create_transaction(meta)
  end

  @spec eth_call(atom, binary, list, map) :: {:ok, binary}
  def eth_call(contract, function, args, options \\ %{}) do
    options
    |> Map.put(:data, hash_data(contract, function, args))
    |> @quorum_client.eth_call("latest", [])
  end

  @spec hash_data(atom, binary, list) :: binary
  def hash_data(contract, function, params) when is_atom(contract) do
    contract
    |> ContractStore.get()
    |> ABI.parse_specification()
    |> Enum.find(&(&1.function == function))
    |> ABI.encode(params)
    |> Base.encode16(case: :lower)
    |> add_prefix("0x")
  end

  @spec add_prefix(binary, binary) :: binary
  defp add_prefix(string, prefix), do: prefix <> string
end
