defmodule AttestationApi.DigitalVerifications.Operations.UploadMedia do
  @moduledoc """
  Uploads media to Veriff, changes Veriff.me session status
  """

  import Ecto.Query, except: [update: 2]

  alias AttestationApi.DigitalVerifications
  alias AttestationApi.DigitalVerifications.DigitalVerification
  alias AttestationApi.DigitalVerifications.DigitalVerificationDocument
  alias AttestationApi.Repo
  alias AttestationApi.VendorDocuments

  @veriffme_client Application.get_env(:attestation_api, :dependencies)[:veriffme]

  @doc """
  Upload media proccess:
  - Validates verification contexts, documents and country
  - Creates DigitalVerificationDocument entity
  - Checks that all documents are loaded
  - Uploads media to Veriff.me
  - Changes Veriff.me session status
  """
  @spec handle(map) :: :ok | {:error, atom | binary}
  def handle(%{"session_id" => session_id} = params) do
    with %DigitalVerification{documents: documents} = verification <- get_verification_and_documents(session_id),
         :ok <- VendorDocuments.check_context_items(verification, params),
         {:ok, new_document} <- create_digital_verification_document(params, verification),
         documents <- [new_document] ++ documents,
         :ok <- check_all_documents_are_loaded(documents, verification),
         :ok <- veriffme_upload_media(session_id, documents),
         :ok <- veriffme_close_session(session_id),
         {:ok, _verification} <- set_pending_status(verification) do
      :ok
    else
      {:error, :wait_more_documents} -> :ok
      err -> err
    end
  end

  @spec check_all_documents_are_loaded([DigitalVerificationDocument], DigitalVerification) :: :ok | {:error, atom}
  defp check_all_documents_are_loaded(documents, %DigitalVerification{document_type: document_type}) do
    document_contexts = Enum.map(documents, & &1.context)

    with {:ok, %{"contexts" => vendor_contexts}} = VendorDocuments.get_document_type_data(document_type),
         [] <- vendor_contexts -- document_contexts do
      :ok
    else
      _ -> {:error, :wait_more_documents}
    end
  end

  @spec create_digital_verification_document(map, %DigitalVerification{}) ::
          {:ok, DigitalVerificationDocument} | {:error, binary}
  defp create_digital_verification_document(params, %DigitalVerification{id: verification_id}) do
    %{
      verification_id: verification_id,
      context: params["context"],
      content: params["content"],
      timestamp: params["timestamp"]
    }
    |> DigitalVerificationDocument.changeset()
    |> Repo.insert()
  end

  @spec get_verification_and_documents(binary) :: DigitalVerification | {:error, :not_found}
  defp get_verification_and_documents(session_id) do
    DigitalVerification
    |> where([dv], dv.session_id == ^session_id)
    |> join(:left, [dv], d in assoc(dv, :documents))
    |> preload([dv, d], documents: d)
    |> Repo.one()
    |> case do
      %DigitalVerification{} = verification -> verification
      _ -> {:error, {:not_found, "Verification not found"}}
    end
  end

  @spec veriffme_upload_media(binary, list) :: :ok | {:error, {:internal_error, binary}}
  defp veriffme_upload_media(session_id, documents) do
    documents
    |> Task.async_stream(
      fn %{context: context, content: image_base64, timestamp: timestamp} ->
        with {:ok, %{body: body}} <- @veriffme_client.upload_media(session_id, context, image_base64, timestamp),
             {:ok, %{"status" => "success"}} <- Jason.decode(body) do
          :ok
        end
      end,
      timeout: 30_000
    )
    |> Enum.reduce_while(:ok, fn
      {:ok, :ok}, acc -> {:cont, acc}
      item, _ -> {:halt, item}
    end)
    |> case do
      :ok ->
        :ok

      err ->
        Log.error("[#{__MODULE__}] Fail to upload media on veriffme. Error: #{inspect(err)}")
        {:error, {:internal_error, "Fail to upload media on verification"}}
    end
  end

  @spec veriffme_close_session(binary) :: :ok | {:error, {:internal_error, binary}}
  defp veriffme_close_session(session_id) do
    with {:ok, %HTTPoison.Response{body: body, status_code: 200}} <- @veriffme_client.close_session(session_id),
         {:ok, %{"status" => "success", "verification" => %{"status" => "submitted"}}} <- Jason.decode(body) do
      :ok
    else
      err ->
        Log.error("[#{__MODULE__}] Fail to sumbit veriffme session. Error: #{inspect(err)}")
        {:error, {:internal_error, "Fail to close session"}}
    end
  end

  @spec set_pending_status(%DigitalVerification{}) :: {:ok, %DigitalVerification{}} | {:error, binary}
  defp set_pending_status(%DigitalVerification{} = verification) do
    DigitalVerifications.update(verification, %{status: DigitalVerification.status(:pending)})
  end
end
