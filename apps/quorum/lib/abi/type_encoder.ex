defmodule Quorum.ABI.TypeEncoder do
  @moduledoc """
  `ABI.TypeEncoder` is responsible for encoding types to the format
  expected by Solidity. We generally take a function selector and an
  array of data and encode that array according to the specification.
  """

  alias Quorum.ABI.FunctionSelector

  @doc """
  Encodes the given data based on the function selector.

  ## Examples

      iex> [69, true]
      ...> |> ABI.TypeEncoder.encode(
      ...>      %FunctionSelector{
      ...>        function: "baz",
      ...>        types: [
      ...>          {:uint, 32},
      ...>          :bool
      ...>        ],
      ...>        returns: :bool
      ...>      }
      ...>    )
      ...> |> Base.encode16(case: :lower)
      "cdcd77c000000000000000000000000000000000000000000000000000000000000000450000000000000000000000000000000000000000000000000000000000000001"

      iex> ["hello world"]
      ...> |> ABI.TypeEncoder.encode(
      ...>      %FunctionSelector{
      ...>        function: nil,
      ...>        types: [
      ...>          :string,
      ...>        ]
      ...>      }
      ...>    )
      ...> |> Base.encode16(case: :lower)
      "000000000000000000000000000000000000000000000000000000000000000b68656c6c6f20776f726c64000000000000000000000000000000000000000000"

      iex> [{"awesome", true}]
      ...> |> ABI.TypeEncoder.encode(
      ...>      %FunctionSelector{
      ...>        function: nil,
      ...>        types: [
      ...>          {:tuple, [:string, :bool]}
      ...>        ]
      ...>      }
      ...>    )
      ...> |> Base.encode16(case: :lower)
      "000000000000000000000000000000000000000000000000000000000000004000000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000007617765736f6d6500000000000000000000000000000000000000000000000000"

      iex> [{17, true, <<32, 64>>}]
      ...> |> ABI.TypeEncoder.encode(
      ...>      %FunctionSelector{
      ...>        function: nil,
      ...>        types: [
      ...>          {:tuple, [{:uint, 32}, :bool, {:bytes, 2}]}
      ...>        ]
      ...>      }
      ...>    )
      ...> |> Base.encode16(case: :lower)
      "000000000000000000000000000000000000000000000000000000000000001100000000000000000000000000000000000000000000000000000000000000012040000000000000000000000000000000000000000000000000000000000000"

      iex> [[17, 1]]
      ...> |> ABI.TypeEncoder.encode(
      ...>      %FunctionSelector{
      ...>        function: "baz",
      ...>        types: [
      ...>          {:array, {:uint, 32}, 2}
      ...>        ]
      ...>      }
      ...>    )
      ...> |> Base.encode16(case: :lower)
      "3d0ec53300000000000000000000000000000000000000000000000000000000000000110000000000000000000000000000000000000000000000000000000000000001"

      iex> [[17, 1], true]
      ...> |> ABI.TypeEncoder.encode(
      ...>      %FunctionSelector{
      ...>        function: nil,
      ...>        types: [
      ...>          {:array, {:uint, 32}, 2},
      ...>          :bool
      ...>        ]
      ...>      }
      ...>    )
      ...> |> Base.encode16(case: :lower)
      "000000000000000000000000000000000000000000000000000000000000001100000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000001"

      iex> [[17, 1]]
      ...> |> ABI.TypeEncoder.encode(
      ...>      %FunctionSelector{
      ...>        function: nil,
      ...>        types: [
      ...>          {:array, {:uint, 32}}
      ...>        ]
      ...>      }
      ...>    )
      ...> |> Base.encode16(case: :lower)
      "000000000000000000000000000000000000000000000000000000000000000200000000000000000000000000000000000000000000000000000000000000110000000000000000000000000000000000000000000000000000000000000001"
  """
  @spec encode(list, FunctionSelector.t()) :: binary
  def encode(_data, %FunctionSelector{types: []} = function_selector) do
    encode_method_id(function_selector)
  end

  @spec encode(list, FunctionSelector.t()) :: binary
  def encode(data, function_selector) do
    # crooked nail
    types = [tuple: function_selector.types]
    encode_method_id(function_selector) <> encode_raw(data, types)
  end

  @doc """
  Simiar to `ABI.TypeEncoder.encode/2` except we accept
  an array of types instead of a function selector. We also
  do not pre-pend the method id.

  ## Examples

      iex> [{"awesome", true}]
      ...> |> ABI.TypeEncoder.encode_raw([{:tuple, [:string, :bool]}])
      ...> |> Base.encode16(case: :lower)
      "000000000000000000000000000000000000000000000000000000000000004000000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000007617765736f6d6500000000000000000000000000000000000000000000000000"
  """
  @spec encode_raw(list, list) :: binary
  def encode_raw(data, types) do
    do_encode(types, data, [])
  end

  @spec encode_method_id(%FunctionSelector{}) :: binary()
  defp encode_method_id(%FunctionSelector{function: nil}), do: ""

  defp encode_method_id(function_selector) do
    # Encode selector e.g. "baz(uint32,bool)" and take keccak
    kec =
      function_selector
      |> FunctionSelector.encode()
      |> :keccakf1600.sha3_256()

    # Take first four bytes
    <<init::binary-size(4), _rest::binary>> = kec

    # That's our method id
    init
  end

  @spec do_encode([FunctionSelector.type()], [any()], [binary()]) :: binary()
  defp do_encode([], _, acc), do: :erlang.iolist_to_binary(Enum.reverse(acc))

  defp do_encode([type | remaining_types], data, acc) do
    {encoded, remaining_data} = encode_type(type, data)

    do_encode(remaining_types, remaining_data, [encoded | acc])
  end

  @spec encode_type(FunctionSelector.type(), [any()]) :: {binary(), [any()]}
  defp encode_type({:uint, size}, [data | rest]) do
    {encode_uint(data, size), rest}
  end

  defp encode_type(:address, ["0x" <> address | rest]) do
    {address, _} = Integer.parse(address, 16)
    encode_type({:uint, 160}, [address] ++ rest)
  end

  defp encode_type(:address, data), do: encode_type({:uint, 160}, data)

  defp encode_type(:bool, [data | rest]) do
    value =
      case data do
        true -> encode_uint(1, 8)
        false -> encode_uint(0, 8)
        _ -> raise "Invalid data for bool: #{data}"
      end

    {value, rest}
  end

  defp encode_type(:string, [data | rest]) do
    {encode_uint(byte_size(data), 256) <> encode_bytes(data), rest}
  end

  defp encode_type(:bytes, [data | rest]) do
    {encode_uint(byte_size(data), 256) <> encode_bytes(data), rest}
  end

  defp encode_type({:bytes, size}, [data | rest]) when is_binary(data) and byte_size(data) <= size do
    {encode_bytes(data), rest}
  end

  defp encode_type({:bytes, size}, [data | _]) when is_binary(data) do
    raise "size mismatch for bytes#{size}: #{inspect(data)}"
  end

  defp encode_type({:bytes, size}, [data | _]) do
    raise "wrong datatype for bytes#{size}: #{inspect(data)}"
  end

  defp encode_type({:tuple, types}, [data | rest]) do
    # all head items are 32 bytes in length and there will be exactly
    # `count(types)` of them, so the tail starts at `32 * count(types)`.
    tail_start = (types |> Enum.count()) * 32

    {head, tail, [], _} =
      Enum.reduce(types, {<<>>, <<>>, data |> Tuple.to_list(), tail_start}, fn type,
                                                                               {head, tail, data, tail_position} ->
        {el, rest} = encode_type(type, data)

        if FunctionSelector.is_dynamic?(type) do
          # If we're a dynamic type, just encoded the length to head and the element to body
          {head <> encode_uint(tail_position, 256), tail <> el, rest, tail_position + byte_size(el)}
        else
          # If we're a static type, simply encode the el to the head
          {head <> el, tail, rest, tail_position}
        end
      end)

    {head <> tail, rest}
  end

  defp encode_type({:array, type, element_count}, [data | rest]) do
    repeated_type = Enum.map(1..element_count, fn _ -> type end)

    encode_type({:tuple, repeated_type}, [data |> List.to_tuple() | rest])
  end

  defp encode_type({:array, type}, [data | _rest] = all_data) do
    element_count = Enum.count(data)

    encoded_uint = encode_uint(element_count, 256)
    {encoded_array, rest} = encode_type({:array, type, element_count}, all_data)

    {encoded_uint <> encoded_array, rest}
  end

  defp encode_type(els, _) do
    raise "Unsupported encoding type: #{inspect(els)}"
  end

  @spec encode_bytes(term) :: binary
  def encode_bytes(bytes), do: pad(bytes, byte_size(bytes), :right)

  # Note, we'll accept a binary or an integer here, so long as the
  # binary is not longer than our allowed data size
  @spec encode_uint(binary | integer, integer) :: binary
  defp encode_uint(data, size_in_bits) when rem(size_in_bits, 8) == 0 do
    size_in_bytes = round(size_in_bits / 8)
    bin = maybe_encode_unsigned(data)

    if byte_size(bin) > size_in_bytes,
      do: raise("Data overflow encoding uint, data `#{data}` cannot fit in #{size_in_bytes * 8} bits")

    pad(bin, size_in_bytes, :left)
  end

  @spec pad(binary, integer, atom) :: binary
  defp pad(bin, size_in_bytes, direction) do
    total_size = size_in_bytes + mod(32 - mod(size_in_bytes, 32), 32)
    padding_size_bits = (total_size - byte_size(bin)) * 8
    padding = <<0::size(padding_size_bits)>>

    case direction do
      :left -> padding <> bin
      :right -> bin <> padding
    end
  end

  @spec mod(integer, integer) :: integer
  defp mod(x, n) when x > 0, do: rem(x, n)
  defp mod(x, n) when x < 0, do: rem(n + x, n)
  defp mod(0, _n), do: 0

  @spec maybe_encode_unsigned(binary() | integer()) :: binary()
  defp maybe_encode_unsigned(bin) when is_binary(bin), do: bin
  defp maybe_encode_unsigned(int) when is_integer(int), do: :binary.encode_unsigned(int)
end
