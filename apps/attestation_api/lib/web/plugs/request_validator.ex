defmodule AttestationApi.Plugs.RequestValidator do
  @moduledoc """
  Validates request data using Ecto.Changeset
  Requires particular validator (module that uses Ecto.Schema) and optinal fallback handler
  Returns 422 error in case of invalid data
  """

  use Phoenix.Controller

  import Plug.Conn

  alias AttestationApi.FallbackController
  alias Ecto.Changeset
  alias Plug.Conn

  @doc """
  Runs plug
  """
  @spec call(Conn.t(), Plug.opts()) :: Conn.t()
  def call(%Conn{params: params} = conn, [{:validator, validator} | _] = opts) do
    case validator.changeset(params) do
      %Changeset{valid?: true} = changeset ->
        assign(conn, :validated_params, Changeset.apply_changes(changeset))

      %Changeset{valid?: false} = changeset ->
        err_handler = opts[:error_handler] || FallbackController

        conn
        |> err_handler.call(changeset)
        |> halt()
    end
  end
end
