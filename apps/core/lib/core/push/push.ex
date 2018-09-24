defmodule Core.Push do
  @moduledoc """
  Registres push notifications in queue via PushJob
  """

  @push_sender Application.get_env(:core, :dependencies)[:push_sender]

  alias Pigeon.APNS.Notification, as: IOSNotification
  alias Pigeon.FCM.Notification, as: AndroidNotification

  @available_device_os ["ios", "android"]

  @doc """
  Registres push notification in queue via PushJob
  """
  @spec enqueue(binary, binary, binary) :: :ok
  def enqueue(message, device_os, device_token) when device_os in @available_device_os do
    IO.inspect "MESSAGE: #{inspect message}"
    IO.inspect "DEVICE: #{inspect device_os}"
    IO.inspect "TOKEN: #{inspect device_token}"
    
    message
    |> @push_sender.send(device_os, device_token)
    |> case do
      %IOSNotification{response: :success} -> :ok
      %AndroidNotification{status: :success} -> :ok
      notification -> {:error, notification}
    end
  end
end
