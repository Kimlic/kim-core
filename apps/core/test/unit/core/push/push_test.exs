defmodule Core.PushTest do
  @moduledoc false

  use ExUnit.Case, async: true

  alias Core.Push

  test "enqueue" do
    assert :ok = Push.enqueue("message", "ios", "token")
  end
end
