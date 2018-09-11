defmodule Quorum.Contract.KimlicContextStorage do
  @moduledoc """
  KimlicContextStorage with generated functions via macros
  """

  use Quorum.Contract, :kimlic_context_storage

  eth_call("getContext", [])
end
