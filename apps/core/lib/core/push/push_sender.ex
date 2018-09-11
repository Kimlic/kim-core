defmodule Core.Push.PushSender do
  @moduledoc """
  Sends push notifications for IOs and Android devices
  """

  alias Core.Push.PushSenderBehaviour
  alias Pigeon.APNS, as: IOSPush
  alias Pigeon.APNS.Notification, as: IOSNotification
  alias Pigeon.FCM, as: AndroidPush
  alias Pigeon.FCM.Notification, as: AndroidNotification

  @behaviour PushSenderBehaviour

  @type notification_t :: PushSenderBehaviour.notification_t()

  @doc """
  Sends push notification for IOs and Android devices
  """
  @spec send(binary, binary, binary) :: notification_t
  def send(message, device_os, device_token) do
    device_os
    |> create_notification(device_token, message)
    |> do_send(device_os)
  end

  @spec create_notification(atom, binary, binary) :: notification_t
  defp create_notification("ios", device_token, message), do: IOSNotification.new(message, device_token)

  defp create_notification("android", device_token, message),
    do: AndroidNotification.new(device_token, %{"body" => message})

  @spec do_send(atom, notification_t) :: notification_t
  defp do_send(notification, "ios"), do: IOSPush.push(notification)
  defp do_send(notification, "android"), do: AndroidPush.push(notification)
end
