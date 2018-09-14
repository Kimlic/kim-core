defmodule AttestationApi.Clients.Veriffme do
  @moduledoc """
  Interacts with Veriff.me API
  """

  alias __MODULE__

  @behaviour AttestationApi.Clients.VeriffmeBehaviour

  @typep api_response :: {:ok, HTTPoison.Response.t() | HTTPoison.AsyncResponse.t()} | {:error, HTTPoison.Error.t()}

  @contexts ["face", "document-front", "document-back"]
  @request_options [ssl: [{:versions, [:"tlsv1.2"]}]]

  @doc """
  Creates session.
  API Response example:

      {
        "status": "success",
        "verification": {
          "id": "53c072c9-73f0-41d9-bc7c-763bea81d904",
          "url": "https://magic.veriff.me/v/eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzZXNzaW9uX2lkIjoiNTNjMDcyYzktNzNmMC00MWQ5LWJjN2MtNzYzYmVhODFkOTA0IiwiaWF0IjoxNTI4OTYyMTU3LCJleHAiOjE1Mjk1NjY5NTd9.c2bFWGCVJrXHnSW4owCsvkXP7a5JcNuRWCGHZVSliyc",
          "host": "https://magic.veriff.me",
          "status": "created",
          "sessionToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzZXNzaW9uX2lkIjoiNTNjMDcyYzktNzNmMC00MWQ5LWJjN2MtNzYzYmVhODFkOTA0IiwiaWF0IjoxNTI4OTYyMTU3LCJleHAiOjE1Mjk1NjY5NTd9.c2bFWGCVJrXHnSW4owCsvkXP7a5JcNuRWCGHZVSliyc"
        }
      }

  Success status code: 201
  """
  @spec create_session(binary, binary, binary, binary, binary) :: api_response
  def create_session(first_name, last_name, lang, document_type, unix_timestamp) do
    request_data = %{
      "verification" => %{
        "person" => %{
          "firstName" => first_name,
          "lastName" => last_name
        },
        "document" => %{
          "type" => document_type
        },
        "lang" => lang,
        "features" => ["selfid"],
        "timestamp" => timestamp(unix_timestamp)
      }
    }
    do_request("/sessions", request_data)
  end

  @doc """
  Uploads media.
  API Response example:

      {
        "status": "success",
        "image": {
          "id": "14380b99-e8df-4c1b-b33e-5d4994790148",
          "name": "face",
          "timestamp": {
            "url": "https://api.veriff.me/v1/timestamps/undefined"
          },
          "size": 70,
          "mimetype": "image/png",
          "url": "https://api.veriff.me/v1/media/14380b99-e8df-4c1b-b33e-5d4994790148"
        }
      }

  Success status code: 200
  """
  @spec upload_media(binary, binary, binary, binary) :: api_response
  def upload_media(session_id, context, image_base64, unix_timestamp) when context in @contexts do
    request_data = %{
      "image" => %{
        "context" => context,
        "content" => image_base64,
        "timestamp" => timestamp(unix_timestamp)
      }
    }

    do_request("/sessions/#{session_id}/media", request_data)
  end

  @doc """
  Updates session status.
  API Response example:

      {
        "status": "success",
        "verification": {
          "id": "53c072c9-73f0-41d9-bc7c-763bea81d904",
          "url": "https://magic.veriff.me/v/eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzZXNzaW9uX2lkIjoiNTNjMDcyYzktNzNmMC00MWQ5LWJjN2MtNzYzYmVhODFkOTA0IiwiaWF0IjoxNTI4OTYyMTU3LCJleHAiOjE1Mjk1NjY5NTd9.c2bFWGCVJrXHnSW4owCsvkXP7a5JcNuRWCGHZVSliyc",
          "host": "https://magic.veriff.me",
          "status": "submitted",
          "sessionToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzZXNzaW9uX2lkIjoiNTNjMDcyYzktNzNmMC00MWQ5LWJjN2MtNzYzYmVhODFkOTA0IiwiaWF0IjoxNTI4OTYyMTU3LCJleHAiOjE1Mjk1NjY5NTd9.c2bFWGCVJrXHnSW4owCsvkXP7a5JcNuRWCGHZVSliyc"
        }
      }

  Success status code: 200
  """
  @spec close_session(binary) :: api_response
  def close_session(session_id) do
    request_data = %{
      "verification" => %{
        "frontState" => "done",
        "status" => "submitted",
        "timestamp" => timestamp()
      }
    }

    do_request(:patch, "/sessions/#{session_id}", request_data)
  end

  @spec do_request(atom, binary, map) :: api_response
  defp do_request(method \\ :post, url, request_data) do
    req_url = base_url() <> url
    IO.puts "URL: #{inspect req_url}"
    req_headers = headers(request_data)
    IO.puts "HEADERS: #{inspect req_headers}"
    req_data = Jason.encode!(request_data)
    IO.puts "DATA: #{inspect req_data}"
    
    HTTPoison.request(method, req_url, req_data, req_headers, @request_options)
  end

  @doc """
  Returns available contexts
  """
  @spec contexts :: list
  def contexts, do: @contexts

  @spec base_url :: binary
  defp base_url, do: Application.get_env(:attestation_api, :veriff_api_url)

  @spec headers(map) :: list
  defp headers(request_data) do
    auth_client = Application.get_env(:attestation_api, :veriff_auth_client)
    api_secret = Application.get_env(:attestation_api, :veriff_api_secret)

    signature =
      :sha256
      |> :crypto.hash(Jason.encode!(request_data) <> api_secret)
      |> Base.encode16(case: :lower)

    [
      "X-AUTH-CLIENT": auth_client,
      "X-SIGNATURE": signature,
      "Content-Type": "application/json"
    ]
  end

  @spec timestamp(binary | nil) :: binary
  defp timestamp(unix_timestamp \\ nil) do
    unix_timestamp
    |> case do
      nil -> DateTime.utc_now()
      time when is_binary(time) -> time |> String.to_integer() |> DateTime.from_unix!()
      time when is_integer(time) -> DateTime.from_unix!(time)
    end
    |> DateTime.truncate(:millisecond)
    |> DateTime.to_string()
    |> String.replace(" ", "T")
  end
end
