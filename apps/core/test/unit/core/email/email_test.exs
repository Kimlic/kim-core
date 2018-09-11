defmodule Core.EmailTest do
  @moduledoc false

  use ExUnit.Case, async: true
  import Core.Factory
  alias Core.Email

  test "send verification" do
    assert :ok = Email.send_verification(generate(:email), "token")
  end
end
