defmodule Core.Push do
  @moduledoc """
  Registres push notifications in queue via PushJob
  """

  alias Core.Push.Job, as: PushJob

  @available_device_os ["ios", "android"]

  @doc """
  Registres push notification in queue via PushJob
  """
  @spec enqueue(binary, binary, binary) :: :ok
  def enqueue(message, device_os, device_token) when device_os in @available_device_os do
    PushJob.enqueue!(%{"message" => message, "device_os" => device_os, "device_token" => device_token})
  end
end
