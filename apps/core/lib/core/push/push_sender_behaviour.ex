defmodule Core.Push.PushSenderBehaviour do
  @moduledoc false

  @type notification_t :: %Pigeon.APNS.Notification{} | %Pigeon.FCM.Notification{}

  @callback send(binary, binary, binary) :: notification_t
end
