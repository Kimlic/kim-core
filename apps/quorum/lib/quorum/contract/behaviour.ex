defmodule Quorum.Contract.Behaviour do
  @moduledoc """
  Behaviour for mocking Contracts
  """

  @callback call_function(atom, binary, keyword, map) :: {:ok, binary}
  @callback eth_call(atom, binary, keyword, map) :: {:ok, binary}
end
