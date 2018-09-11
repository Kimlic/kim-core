defmodule MobileApi.Plugs.NodeId do
  @moduledoc """
  Validates request with required header `node-id`
  """

  import Plug.Conn

  alias MobileApi.FallbackController
  alias Plug.Conn

  @quorum_client Application.get_env(:quorum, :client)

  @header "node-id"

  @spec init(Plug.opts()) :: Plug.opts()
  def init(opts), do: opts

  @doc """
  Validate request header
  """
  @spec call(Conn.t(), Plug.opts()) :: Conn.t()
  def call(%Conn{} = conn, _opts) do
    with {:ok, node_id} <- validate_node_id_header(conn),
         :ok <- validate_node_id_exists(node_id) do
      conn
    else
      err ->
        conn
        |> FallbackController.call(err)
        |> halt()
    end
  end

  @spec validate_node_id_header(Conn.t()) :: {:ok, binary} | {:error, binary}
  defp validate_node_id_header(conn) do
    case Conn.get_req_header(conn, @header) do
      [header] -> {:ok, header}
      _ -> {:error, {:unprocessable_entity, "Node-id header is required"}}
    end
  end

  @spec validate_node_id_exists(binary) :: :ok | {:error, tuple} | {:error, :atom}
  defp validate_node_id_exists(node_id) do
    with {:ok, nodes_id} <- get_all_nodes_id(),
         true <- node_id in nodes_id do
      :ok
    else
      false -> {:error, :access_denied}
      err -> err
    end
  end

  @spec get_all_nodes_id :: [binary] | {:error, tuple}
  defp get_all_nodes_id do
    with {:ok, nodes_info} <- @quorum_client.request("admin_peers", %{"id" => 1}, []) do
      nodes_id = Enum.map(nodes_info, & &1["id"])

      {:ok, nodes_id}
    else
      _ ->
        message = "Fail to get quorum admin peers"
        Log.error("[#{__MODULE__}] #{message}")

        {:error, {:internal_error, message}}
    end
  end
end
