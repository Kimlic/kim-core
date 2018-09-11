defmodule Core.Clients.MessengerBehaviour do
  @moduledoc false

  @type send_response_t :: {:ok, %ExTwilio.Message{}} | {:error, {:internal_error, binary}}

  @callback send(binary, binary) :: send_response_t
  @callback send(binary, binary, binary) :: send_response_t
end
