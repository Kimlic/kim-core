defmodule AttestationApi.DigitalVerificationController do
  @moduledoc """
  Defines endpoints related to digital verification
  """

  use AttestationApi, :controller

  alias AttestationApi.DigitalVerifications
  alias AttestationApi.DigitalVerifications.Operations.UploadMedia
  alias AttestationApi.Plugs.RequestValidator
  alias AttestationApi.Validators.CreateSessionValidator
  alias AttestationApi.Validators.UploadMediaValidator
  alias AttestationApi.VendorDocuments
  alias Plug.Conn

  action_fallback(AttestationApi.FallbackController)

  plug(RequestValidator, [validator: CreateSessionValidator] when action in [:create_session])
  plug(RequestValidator, [validator: UploadMediaValidator] when action in [:upload_media])

  @doc """
  Creates session on Veriff
  """
  @spec create_session(Conn.t(), map) :: Conn.t()
  def create_session(conn, params) do
    with {:ok, session_id} <- DigitalVerifications.create_session(conn.assigns.account_address, params) do
      json(conn, %{session_id: session_id})
    end
  end

  @doc """
  Uploads media to Veriff and closes session after all media provided
  """
  @spec upload_media(Conn.t(), map) :: Conn.t()
  def upload_media(conn, %{"session_id" => _} = params) do
    with :ok <- UploadMedia.handle(params) do
      json(conn, %{status: "ok"})
    end
  end

  @doc """
  Handles first webhook from Veriff, which shows that Veriff has accepted verification
  """
  @spec verification_submission_webhook(Conn.t(), map) :: Conn.t()
  def verification_submission_webhook(conn, params) do
    with :ok <- DigitalVerifications.handle_verification_submission(params) do
      json(conn, %{})
    end
  end

  @doc """
  Handles second Veriff webook, which finalize verification and notify user
  """
  @spec verification_result_webhook(Conn.t(), map) :: Conn.t()
  def verification_result_webhook(conn, params) do
    with :ok <- DigitalVerifications.handle_verification_result(params) do
      json(conn, %{})
    end
  end

  @doc """
  Returns Veriff available documents, their countries and contexts
  """
  @spec get_vendors(Conn.t(), map) :: Conn.t()
  def get_vendors(conn, _params) do
    json(conn, VendorDocuments.all())
  end

  def verification_info(conn, %{"session_tag" => session_tag}) do
    with {:ok, verifications} <- DigitalVerifications.verification_info(session_tag) do
      res = %{
        person: verifications.veriffme_person,
        document: verifications.veriffme_document
      }
      json(conn, res)
    else
      {:error, :not_found} -> json(conn, %{status: "not_found"})
    end
  end
end
