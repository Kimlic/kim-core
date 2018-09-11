defmodule Core.TestHelper do
  @moduledoc false

  @spec get_account_address(Plug.Conn.t()) :: binary
  def get_account_address(%{assigns: %{account_address: account_address}}), do: account_address
end
