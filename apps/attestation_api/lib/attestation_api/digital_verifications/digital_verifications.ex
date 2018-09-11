defmodule AttestationApi.DigitalVerifications do
  @moduledoc """
  Defines business logic and DB operations with DigitalVerification entity
  """

  import Ecto.Query, except: [update: 2]

  alias __MODULE__
  alias AttestationApi.DigitalVerifications.DigitalVerification
  alias AttestationApi.DigitalVerifications.DigitalVerificationDocument
  alias AttestationApi.Repo

  @veriffme_client Application.get_env(:attestation_api, :dependencies)[:veriffme]
  @push_client Application.get_env(:attestation_api, :dependencies)[:push]

  @verification_status_passed DigitalVerification.status(:passed)
  @verification_status_pending DigitalVerification.status(:pending)

  @verification_code_success 9001
  @verification_code_resubmission 9103

  @doc """
  Creates session on Veriff.me and stores verification entity in database
  """
  @spec create_session(binary, map) :: {:ok, binary} | {:error, binary}
  def create_session(account_address, params) do
    with {:ok, session_id} <- create_session_on_veriffme(params),
         {:ok, _verification} <-
           insert(%{
             account_address: account_address,
             session_id: session_id,
             contract_address: params["contract_address"],
             document_type: params["document_type"],
             device_os: params["device_os"],
             device_token: params["device_token"]
           }) do
      {:ok, session_id}
    end
  end

  @spec create_session_on_veriffme(map) :: {:ok, binary} | {:error, {atom, binary}}
  defp create_session_on_veriffme(%{
         "first_name" => first_name,
         "last_name" => last_name,
         "document_type" => document_type,
         "lang" => lang,
         "timestamp" => timestamp
       }) do
    with {:ok, %{body: body, status_code: 201}} <-
           @veriffme_client.create_session(first_name, last_name, lang, document_type, timestamp),
         {:ok, %{"status" => "success", "verification" => %{"id" => session_id}}} <- Jason.decode(body) do
      {:ok, session_id}
    else
      err ->
        Log.error("[#{__MODULE__}] Veriffme session creation failed: #{inspect(err)}")
        {:error, {:getaway_timeout, "Fail to create verification session"}}
    end
  end

  @doc """
  Handles webhook from Veriff.me with verification result
  Updates verification status, sends push notification, removes verification documents and set verification result in Quorum
  """
  @spec handle_verification_result(map) :: :ok | {:error, atom}
  def handle_verification_result(params) do
    with %{"verification" => %{"id" => _} = verification_result} <- params,
         {:ok, verification} <- update_status(verification_result),
         :ok <- send_push_notification(verification),
         {_deleted_count, nil} <- remove_verification_documents(verification),
         :ok <- set_quorum_verification_result(verification) do
      log_data = Map.take(verification_result, ["id", "status", "code", "acceptanceTime"])

      Log.info("[#{__MODULE__}] Success on Veriff decision webhook, params: #{inspect(log_data)}")
      :ok
    else
      err ->
        log_data =
          params
          |> pop_in(["verification", "person"])
          |> elem(1)

        Log.error(
          "[#{__MODULE__}] Fail to handle Veriff decision webhook with error: #{inspect(err)} and params: #{
            inspect(log_data)
          }"
        )

        err
    end
  end

  @spec update_status(map) :: :ok | {:error, atom}
  defp update_status(%{"id" => session_id} = verification_result) do
    with %DigitalVerification{} = verification <-
           DigitalVerifications.get_by(%{session_id: session_id, status: @verification_status_pending}),
         {:ok, verification} <- update(verification, get_verification_data_from_result(verification_result)) do
      {:ok, verification}
    else
      _ -> {:error, :not_found}
    end
  end

  @spec remove_verification_documents(%DigitalVerification{}) :: {integer, nil} | {:error, binary}
  defp remove_verification_documents(%DigitalVerification{id: verification_id}) do
    DigitalVerificationDocument
    |> where([dv_d], dv_d.verification_id == ^verification_id)
    |> Repo.delete_all()
  end

  @spec send_push_notification(%DigitalVerification{}) :: :ok
  defp send_push_notification(%DigitalVerification{device_os: device_os, device_token: device_token, status: status}) do
    status_message =
      case status do
        @verification_status_passed -> "passed"
        _ -> "failed"
      end

    @push_client.send("Video verification of your document has #{status_message}", device_os, device_token)
  end

  @spec get_verification_data_from_result(map) :: map
  defp get_verification_data_from_result(%{"code" => code, "status" => veriffme_status})
       when code == @verification_code_success do
    %{
      status: DigitalVerification.status(:passed),
      veriffme_code: code,
      veriffme_status: veriffme_status
    }
  end

  @spec get_verification_data_from_result(map) :: map
  defp get_verification_data_from_result(verification_result) do
    status =
      case verification_result["code"] do
        @verification_code_resubmission -> DigitalVerification.status(:resubmission_requested)
        _ -> DigitalVerification.status(:failed)
      end

    %{
      status: status,
      veriffme_code: verification_result["code"],
      veriffme_status: verification_result["status"],
      veriffme_reason: verification_result["reason"],
      veriffme_comments: verification_result["comments"]
    }
  end

  @spec set_quorum_verification_result(%DigitalVerification{}) :: :ok
  defp set_quorum_verification_result(%DigitalVerification{contract_address: contract_address, status: status}) do
    verification_passed? = status == @verification_status_passed

    Quorum.set_digital_verification_result_transaction(contract_address, verification_passed?)
  end

  @doc """
  Handles Veriff.me webhook that notifies about verification submission, updates verification veriffme_code
  """
  @spec handle_verification_submission(map) :: :ok
  def handle_verification_submission(params) do
    with %{"id" => session_id, "code" => code} = log_data <- params,
         %DigitalVerification{} = verification <- get_by(%{session_id: session_id}),
         {:ok, _verification} = update(verification, %{veriffme_code: code}) do
      Log.info("[#{__MODULE__}] Success on Veriff submission webhook, params: #{inspect(log_data)}")
    else
      err ->
        Log.error("[#{__MODULE__}] Fail to handle Veriff submission webhook with params: #{inspect(params)}")
        err
    end

    :ok
  end

  ### Quering

  @doc """
  Finds single DigitalVerification entity by parameters
  """
  @spec get_by(map) :: %DigitalVerification{} | nil
  def get_by(params), do: Repo.get_by(DigitalVerification, params)

  @doc """
  Inserts DigitalVerification with parameters
  """
  @spec insert(map) :: {:ok, %DigitalVerification{}} | {:error, binary}
  def insert(params) when is_map(params) do
    params
    |> DigitalVerification.changeset()
    |> Repo.insert()
  end

  @doc """
  Updates DigitalVerification entity with parameters
  """
  @spec update(%DigitalVerification{}, map) :: {:ok, %DigitalVerification{}} | {:error, binary}
  def update(%DigitalVerification{} = entity, params) do
    entity
    |> DigitalVerification.changeset(params)
    |> Repo.update()
  end
end
