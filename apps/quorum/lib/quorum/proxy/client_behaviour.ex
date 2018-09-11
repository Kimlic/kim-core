defmodule Quorum.Proxy.ClientBehaviour do
  @moduledoc """
  Behaviour for mocking Proxy Client
  """
  @callback call_rpc(map) :: {:ok, map} | {:error, map}
end
