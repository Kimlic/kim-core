defmodule Core.Email do
  @moduledoc """
  Defines functions for email sending
  """

  alias Core.Clients.Mailer
  alias Core.Email.Views.EmailVerification

  @doc """
  Sends email verification
  """
  @spec send_verification(binary, binary) :: :ok | {:error, binary}
  def send_verification(email, token) do
    email
    |> EmailVerification.render(token)
    |> Mailer.deliver()
    |> case do
      {:ok, _} ->
        :ok

      {:error, error_data} ->
        Log.error("[#{__MODULE__}] Fail to send email. Error: #{inspect(error_data)}")
        {:error, {:internal_error, "Fail to send email"}}
    end
  end
end
