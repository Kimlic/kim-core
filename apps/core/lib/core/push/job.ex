defmodule Core.Push.Job do
  @moduledoc """
  Sends push notification from queue job
  """

  use TaskBunny.Job

  alias Pigeon.APNS.Notification, as: IOSNotification
  alias Pigeon.FCM.Notification, as: AndroidNotification

  @push_sender Application.get_env(:core, :dependencies)[:push_sender]

  @doc """
  Handles run job event from queue
  """
  @spec perform(map) :: :ok
  def perform(%{"message" => message, "device_os" => device_os, "device_token" => device_token}) do
    message
    |> @push_sender.send(device_os, device_token)
    |> case do
      %IOSNotification{response: :success} -> :ok
      %AndroidNotification{status: :success} -> :ok
      notification -> {:error, notification}
    end
  end

  @doc """
  Handles reject event from queue
  """
  @spec on_reject(binary) :: :ok
  def on_reject(body) do
    Log.error(%{
      "message" => "[#{__MODULE__}] Fail to send push notification. Report #{inspect(body)}",
      "push_notification" => true
    })

    :ok
  end

  @doc false
  @spec max_retry :: integer
  def max_retry, do: 5

  @doc false
  @spec retry_interval(integer) :: integer
  def retry_interval(failed_count) do
    retry_interval_minutes = [1, 2, 5, 10, 15]

    retry_interval_minutes
    |> Enum.map(&(&1 * 1000 * 60))
    |> Enum.at(failed_count - 1)
  end
end
