defmodule AttestationApi.Plugs.AccountAddress do
  @moduledoc """
  Parses account-address header and assings it to phoenix `conn` struct
  """

  import Plug.Conn
  import Phoenix.Controller, only: [render: 4]

  alias EView.Views.Error
  alias Plug.Conn

  @header "account-address"
  @address_regex ~r/^0x[0-9a-f]{40}$/

  @spec init(Plug.opts()) :: Plug.opts()
  def init(opts), do: opts

  @doc """
  Runs plug
  """
  @spec call(Conn.t(), Plug.opts()) :: Conn.t()
  def call(%Conn{} = conn, _opts) do
    with {:ok, header} <- validate_required_header(conn),
         :ok <- validate_format(header) do
      assign(conn, :account_address, header)
    else
      {:error, err} ->
        conn
        |> put_status(400)
        |> render(Error, "400.json", %{message: err})
        |> halt()
    end
  end

  @spec validate_required_header(Conn.t()) :: {:ok, binary} | {:error, binary}
  defp validate_required_header(conn) do
    case Conn.get_req_header(conn, @header) do
      [header] -> {:ok, header}
      _ -> {:error, "account-address header required"}
    end
  end

  @spec validate_format(binary) :: :ok | {:error, binary}
  defp validate_format(header) do
    case Regex.match?(@address_regex, header) do
      true -> :ok
      false -> {:error, "Invalid account-address header format"}
    end
  end
end
