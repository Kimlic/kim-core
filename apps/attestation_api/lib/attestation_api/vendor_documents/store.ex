defmodule AttestationApi.VendorDocuments.Store do
  @moduledoc """
  Stores vendor documents in memory
  """

  use Agent

  @doc """
  Starts agent and caches vendor documents
  """
  @spec start_link :: :ok
  def start_link do
    verification_providers_data =
      :attestation_api
      |> Application.app_dir("priv/vendor_documents.json")
      |> File.read!()
      |> Jason.decode!()

    Agent.start_link(fn -> verification_providers_data end, name: __MODULE__)
  end

  @doc """
  Returns all vendor documents
  """
  @spec all :: map
  def all, do: Agent.get(__MODULE__, & &1)

  @doc """
  Finds vendor contexts and countries by document type
  """
  @spec get_by_document_type(binary) :: map | nil
  def get_by_document_type(document_type) when is_binary(document_type) do
    document_type = String.upcase(document_type)

    all()
    |> Map.get("documents", [])
    |> Enum.find(&(&1["type"] == document_type))
  end
end
