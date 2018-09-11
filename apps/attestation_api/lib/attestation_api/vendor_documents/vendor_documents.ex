defmodule AttestationApi.VendorDocuments do
  @moduledoc """
  Manages digital verification documents
  """

  alias AttestationApi.DigitalVerifications.DigitalVerification
  alias AttestationApi.VendorDocuments.Store, as: VendorDocumentsStore

  @doc """
  Returns all vendor documents
  """
  @spec all :: map
  def all, do: VendorDocumentsStore.all()

  @doc """
  Validates DigitalVerification country and context
  """
  @spec check_context_items(DigitalVerification, map) :: :ok | {:error, binary}
  def check_context_items(%DigitalVerification{document_type: document_type}, %{
        "country" => country,
        "context" => context
      }) do
    with {:ok, %{"countries" => countries, "contexts" => contexts}} <- get_document_type_data(document_type),
         :ok <- validate_country(countries, country),
         :ok <- validate_context(contexts, context) do
      :ok
    end
  end

  @spec validate_country(list, binary) :: :ok | {:error, binary}
  defp validate_country(countries, country) do
    case country in countries do
      true -> :ok
      false -> {:error, {:not_found, "Country doesn't exist"}}
    end
  end

  @spec validate_context(list, binary) :: :ok | {:error, binary}
  defp validate_context(contexts, context) do
    case context in contexts do
      true -> :ok
      false -> {:error, {:not_found, "Context doesn't exist in scope of country"}}
    end
  end

  @doc """
  Finds vendor contexts and countries by document type
  """
  @spec get_document_type_data(binary) :: {:ok, list} | {:error, :not_found}
  def get_document_type_data(document_type) do
    case VendorDocumentsStore.get_by_document_type(document_type) do
      nil -> {:error, {:not_found, "Document type with such context not found"}}
      %{"contexts" => _, "countries" => _} = data -> {:ok, data}
    end
  end
end
