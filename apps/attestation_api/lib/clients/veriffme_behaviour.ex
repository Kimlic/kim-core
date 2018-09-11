defmodule AttestationApi.Clients.VeriffmeBehaviour do
  @moduledoc false

  @typep api_response :: {:ok, HTTPoison.Response.t() | HTTPoison.AsyncResponse.t()} | {:error, HTTPoison.Error.t()}

  @callback create_session(binary, binary, binary, binary, binary) :: api_response
  @callback upload_media(binary, binary, binary, binary) :: api_response
  @callback close_session(binary) :: api_response
end
