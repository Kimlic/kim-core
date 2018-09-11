defmodule Quorum.ABI.FunctionSelector do
  @moduledoc """
  Module to help parse the ABI function signatures, e.g.
  `my_function(uint64, string[])`.
  """

  alias Quorum.ABI.{FunctionSelector, Parser}

  require Integer

  @type type ::
          {:uint, integer()}
          | :bool
          | :bytes
          | :string
          | :address
          | {:array, type}
          | {:array, type, non_neg_integer}
          | {:tuple, [type]}

  @type t :: %__MODULE__{
          function: String.t(),
          types: [type],
          returns: type
        }

  defstruct [:function, :types, :returns]

  @doc """
  Decodes a function selector to a struct.

  ## Examples

      iex> FunctionSelector.decode("bark(uint256,bool)")
      %FunctionSelector{
        function: "bark",
        types: [
          {:uint, 256},
          :bool
        ]
      }

      iex> FunctionSelector.decode("growl(uint,address,string[])")
      %FunctionSelector{
        function: "growl",
        types: [
          {:uint, 256},
          :address,
          {:array, :string}
        ]
      }

      iex> FunctionSelector.decode("rollover()")
      %FunctionSelector{
        function: "rollover",
        types: []
      }

      iex> FunctionSelector.decode("do_playDead3()")
      %FunctionSelector{
        function: "do_playDead3",
        types: []
      }

      iex> FunctionSelector.decode("pet(address[])")
      %FunctionSelector{
        function: "pet",
        types: [
          {:array, :address}
        ]
      }

      iex> FunctionSelector.decode("paw(string[2])")
      %FunctionSelector{
        function: "paw",
        types: [
          {:array, :string, 2}
        ]
      }

      iex> FunctionSelector.decode("scram(uint256[])")
      %FunctionSelector{
        function: "scram",
        types: [
          {:array, {:uint, 256}}
        ]
      }

      iex> FunctionSelector.decode("shake((string))")
      %FunctionSelector{
        function: "shake",
        types: [
          {:tuple, [:string]}
        ]
      }
  """
  @spec decode(binary) :: term
  def decode(signature) do
    Parser.parse!(signature, as: :selector)
  end

  @doc """
  Decodes the given type-string as a simple array of types.

  ## Examples

      iex> FunctionSelector.decode_raw("string,uint256")
      [:string, {:uint, 256}]

      iex> FunctionSelector.decode_raw("")
      []
  """
  @spec decode_raw(binary) :: list
  def decode_raw(type_string) do
    {:tuple, types} = decode_type("(#{type_string})")
    types
  end

  @doc false
  @spec parse_specification_item(map) :: FunctionSelector.t() | nil
  def parse_specification_item(%{"type" => "function"} = item) do
    %{
      "name" => function_name,
      "inputs" => named_inputs,
      "outputs" => named_outputs
    } = item

    input_types = Enum.map(named_inputs, &parse_specification_type/1)
    output_types = Enum.map(named_outputs, &parse_specification_type/1)

    %FunctionSelector{
      function: function_name,
      types: input_types,
      returns: List.first(output_types)
    }
  end

  def parse_specification_item(%{"type" => "fallback"}) do
    %FunctionSelector{
      function: nil,
      types: [],
      returns: nil
    }
  end

  def parse_specification_item(_), do: nil

  @spec parse_specification_type(map) :: tuple
  defp parse_specification_type(%{"type" => type}), do: decode_type(type)

  @doc """
  Decodes the given type-string as a single type.

  ## Examples

      iex> FunctionSelector.decode_type("uint256")
      {:uint, 256}

      iex> FunctionSelector.decode_type("(bool,address)")
      {:tuple, [:bool, :address]}

      iex> FunctionSelector.decode_type("address[][3]")
      {:array, {:array, :address}, 3}
  """
  @spec decode_type(binary) :: tuple
  def decode_type(single_type) do
    Parser.parse!(single_type, as: :type)
  end

  @doc """
  Encodes a function call signature.

  ## Examples

      iex> FunctionSelector.encode(%FunctionSelector{
      ...>   function: "bark",
      ...>   types: [
      ...>     {:uint, 256},
      ...>     :bool,
      ...>     {:array, :string},
      ...>     {:array, :string, 3},
      ...>     {:tuple, [{:uint, 256}, :bool]}
      ...>   ]
      ...> })
      "bark(uint256,bool,string[],string[3],(uint256,bool))"
  """
  @spec encode(FunctionSelector.t()) :: binary
  def encode(function_selector) do
    types = function_selector |> get_types() |> Enum.join(",")

    "#{function_selector.function}(#{types})"
  end

  @spec encode(FunctionSelector.t()) :: binary | nil
  defp get_types(function_selector) do
    for type <- function_selector.types do
      get_type(type)
    end
  end

  @spec get_type(FunctionSelector.type() | term) :: binary | nil
  defp get_type(nil), do: nil
  defp get_type({:int, size}), do: "int#{size}"
  defp get_type({:uint, size}), do: "uint#{size}"
  defp get_type(:address), do: "address"
  defp get_type(:bool), do: "bool"
  defp get_type({:fixed, element_count, precision}), do: "fixed#{element_count}x#{precision}"
  defp get_type({:ufixed, element_count, precision}), do: "ufixed#{element_count}x#{precision}"
  defp get_type({:bytes, size}), do: "bytes#{size}"
  defp get_type(:function), do: "function"

  defp get_type({:array, type, element_count}), do: "#{get_type(type)}[#{element_count}]"

  defp get_type(:bytes), do: "bytes"
  defp get_type(:string), do: "string"
  defp get_type({:array, type}), do: "#{get_type(type)}[]"

  defp get_type({:tuple, types}) do
    encoded_types = Enum.map(types, &get_type/1)
    "(#{Enum.join(encoded_types, ",")})"
  end

  defp get_type(els), do: raise("Unsupported type: #{inspect(els)}")

  @doc false
  @spec is_dynamic?(FunctionSelector.type()) :: boolean
  def is_dynamic?(:bytes), do: true
  def is_dynamic?(:string), do: true
  def is_dynamic?({:array, _type}), do: true
  def is_dynamic?({:array, type, len}) when len > 0, do: is_dynamic?(type)
  def is_dynamic?({:tuple, types}), do: Enum.any?(types, &is_dynamic?/1)
  def is_dynamic?(_), do: false
end
