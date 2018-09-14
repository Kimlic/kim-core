defmodule Core.Email.Views.EmailVerification do
  @moduledoc false

  import Swoosh.Email

  require EEx

  @template __DIR__ <> "/../templates/email_verification.html.eex"

  EEx.function_from_file(:def, :create_profile_email, @template, [:code])

  @spec render(binary, binary) :: Swoosh.Email.t()
  def render(email, code) do
    email_data = Application.get_env(:core, :create_profile_email)
    mail_html = __MODULE__.create_profile_email(code)

    new()
    |> to(email)
    |> from({email_data.from_name, email_data.from_email})
    |> subject(email_data.subject)
    |> html_body(mail_html)
  end
end
