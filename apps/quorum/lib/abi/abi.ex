defmodule Quorum.ABI do
  @moduledoc false

  alias Quorum.ABI.{FunctionSelector, Parser, TypeDecoder, TypeEncoder}

  @spec encode(binary, list) :: binary
  def encode(function_signature, data) when is_binary(function_signature) do
    function_signature
    |> Parser.parse!()
    |> encode(data)
  end

  @spec encode(FunctionSelector.t(), list) :: binary
  def encode(%FunctionSelector{} = function_selector, data) do
    TypeEncoder.encode(data, function_selector)
  end

  @spec decode(binary, term) :: list
  def decode(function_signature, data) when is_binary(function_signature) do
    decode(Parser.parse!(function_signature), data)
  end

  @spec decode(FunctionSelector, term) :: list
  def decode(%FunctionSelector{} = function_selector, data) do
    TypeDecoder.decode(data, function_selector)
  end

  @spec parse_specification(integer) :: integer
  def parse_specification(doc) do
    doc
    |> Enum.map(&FunctionSelector.parse_specification_item/1)
    |> Enum.filter(& &1)
  end
end
