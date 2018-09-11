defmodule Core.Clients.Redis do
  @moduledoc """
  Provides convenient access to Redis using Redix under the hood
  Serializes and stores data using Erlang `term_to_binary`
  """

  import Ecto.Changeset

  alias Ecto.Changeset
  alias Log

  @doc """
  Returns value by key
  """
  @spec get(binary) :: {:ok, term} | {:error, binary}
  def get(key) when is_binary(key) do
    with {:ok, encoded_value} <- Redix.command(:redix, ["GET", key]) do
      if encoded_value == nil do
        {:error, :not_found}
      else
        entity =
          encoded_value
          |> decode()
          |> Map.put(:redis_key, key)

        {:ok, entity}
      end
    else
      {:error, reason} = err ->
        Log.error("[#{__MODULE__}] Fail to get value by key (#{key}) with error #{inspect(reason)}")
        err
    end
  end

  @doc """
  Updates or inserts changeset which contains redis_key
  """
  @spec upsert(Changeset.t(), pos_integer | nil) :: {:ok, term} | {:error, binary}
  def upsert(%Changeset{} = changeset, ttl_seconds \\ nil) do
    {_, key} = fetch_field(changeset, :redis_key)
    entity = Changeset.apply_changes(changeset)

    case set(key, entity, ttl_seconds) do
      :ok -> {:ok, entity}
      err -> err
    end
  end

  @doc """
  Updates entity as struct with params
  """
  @spec update(struct, map | %{}, pos_integer | nil) :: {:ok, term} | {:error, binary}
  def update(entity, params \\ %{}, ttl_seconds \\ nil) when is_map(entity) and is_map(params) do
    entity
    |> Map.from_struct()
    |> Map.merge(params)
    |> entity.__struct__.changeset()
    |> upsert(ttl_seconds)
  end

  @doc """
  Sets key-value pair
  """
  @spec set(binary, term, pos_integer | nil) :: :ok | {:error, atom}
  def set(key, value, ttl_seconds \\ nil)

  def set(key, value, nil) when is_binary(key) and value != nil,
    do: do_set(["SET", key, encode(value)])

  def set(key, value, ttl_seconds) when is_binary(key) and value != nil,
    do: do_set(["SET", key, encode(value), "EX", ttl_seconds])

  @spec do_set(list) :: :ok | {:error, binary}
  defp do_set(params) do
    case Redix.command(:redix, params) do
      {:ok, _} ->
        :ok

      {:error, reason} = err ->
        Log.error("[#{__MODULE__}] Fail to set with params #{inspect(params)} with error #{inspect(reason)}")
        err
    end
  end

  @doc """
  Removes key-value pair by key as:
    - map that contains redis_key
    - string
  """
  @spec delete(map) :: {:ok, non_neg_integer} | {:error, binary}
  def delete(%{redis_key: key}), do: delete(key)

  @spec delete(binary) :: {:ok, non_neg_integer} | {:error, binary}
  def delete(key) when is_binary(key) do
    case Redix.command(:redix, ["DEL", key]) do
      {:ok, n} when n >= 1 -> {:ok, n}
      {:ok, 0} -> {:error, :not_found}
      err -> err
    end
  end

  @doc """
  Removes all data
  """
  @spec flush :: :ok | {:error, binary}
  def flush do
    case Redix.command(:redix, ["FLUSHDB"]) do
      {:ok, _} -> :ok
      err -> err
    end
  end

  @spec encode(term) :: term
  defp encode(value), do: :erlang.term_to_binary(value)

  @spec decode(term) :: term
  defp decode(value), do: :erlang.binary_to_term(value)
end
