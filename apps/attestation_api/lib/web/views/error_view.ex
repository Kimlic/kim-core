defmodule AttestationApi.ErrorView do
  use AttestationApi, :view

  @spec template_not_found(binary, map) :: map
  def template_not_found(template, _assigns) do
    %{errors: %{detail: Phoenix.Controller.status_message_from_template(template)}}
  end
end
