defmodule AttestationApi.Validators.VeriffValidator do
  @moduledoc """
  Defines functions to validate data during Verriff verification proccess
  """

  import Ecto.Changeset
  alias AttestationApi.DigitalVerifications

  @doc """
  Validates timestamp not to be older than hour
  """
  @spec validate_timestamp(Ecto.Changeset.t(), atom) :: Ecto.Changeset.t()
  def validate_timestamp(changeset, field) do
    hour = 60 * 60
    now = DateTime.utc_now() |> DateTime.to_unix()

    validate_change(changeset, field, fn _, unix_timestamp ->
      case unix_timestamp > now - hour do
        true -> []
        false -> [timestamp: "Timestamp should not be older than hour"]
      end
    end)
  end

  @doc """
  Validate Veriff.me session_id exists in database
  """
  @spec validate_session_id_exists(Ecto.Changeset.t(), atom) :: Ecto.Changeset.t()
  def validate_session_id_exists(changeset, field) do
    validate_change(changeset, field, fn _, session_id ->
      case DigitalVerifications.get_by(%{session_id: session_id}) do
        nil -> [session_id: "Session_id is invalid"]
        _ -> []
      end
    end)
  end

  @doc """
  Validate image size provided as base64. Actual image size should be less than 3.7 mb
  """
  @spec validate_base64_size(Ecto.Changeset.t(), atom) :: Ecto.Changeset.t()
  def validate_base64_size(changeset, field) do
    validate_change(changeset, field, fn _, image_base64 ->
      five_mb_raw_in_bytes = 5_000_000
      base64_ratio = 1.28
      image_bytes = byte_size(image_base64) * base64_ratio

      case five_mb_raw_in_bytes > image_bytes do
        true -> []
        false -> [content: "Media content size is more than max allowed by attestation party"]
      end
    end)
  end
end
