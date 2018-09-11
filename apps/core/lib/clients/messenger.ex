defmodule Core.Clients.Messenger do
  @moduledoc """
  Sends sms using Twillio library
  """

  alias Core.Clients.MessengerBehaviour
  alias ExTwilio.Message

  @behaviour MessengerBehaviour

  @type send_response_t :: {:ok, %ExTwilio.Message{}} | {:error, {:internal_error, binary}}

  @spec send(binary, binary) :: send_response_t
  def send(to, message), do: send(message_from(), to, message)

  @doc """
  Sends sms
  """
  @spec send(binary, binary, binary) :: send_response_t
  def send(from, to, message) do
    case Message.create(from: from, to: to, body: message) do
      {:ok, %ExTwilio.Message{} = entity} ->
        {:ok, entity}

      {:error, message, status_code} ->
        Log.error("[#{__MODULE__}] Fail to send sms. Error: #{inspect(message)}, status: #{inspect(status_code)}")
        {:error, {:internal_error, "Fail to send sms"}}
    end
  end

  @spec message_from :: binary
  defp message_from, do: Confex.fetch_env!(:core, :messenger_message_from)
end
