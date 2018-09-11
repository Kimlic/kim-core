defmodule Core.ConfigKeeper do
  @moduledoc """
  Provides data for config endpoint
  """

  alias Quorum.Contract.Context

  @doc """
  Returnes data for config endpoint
  """
  @spec all :: map
  def all do
    %{
      "context_contract" => Context.get_context_address(),
      "attestation_parties" => attestation_parties()
    }
  end

  @spec attestation_parties :: list
  defp attestation_parties do
    [
      %{"name" => "Veriff.me", "address" => Confex.fetch_env!(:quorum, :veriff_ap_address)}
    ]
  end
end
