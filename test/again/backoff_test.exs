defmodule Again.BackoffTest do
  use ExUnit.Case

  alias Again.Backoff

  describe "constant_backoff" do
    test "returns the same backoff duration across invocations" do
      backoff = Backoff.constant_backoff(100)

      b1 = backoff.(nil)
      assert b1 == 100

      b2 = backoff.(b1)
      assert b2 == 100

      b3 = backoff.(b2)
      assert b3 == 100
    end
  end

  describe "exponential_backoff" do
    test "starts with the provided value" do
      backoff = Backoff.exponential_backoff(100)

      b1 = backoff.(nil)
      assert b1 == 100
    end

    test "doubles exponentially across invocations" do
      backoff = Backoff.exponential_backoff(100)

      b1 = backoff.(nil)
      assert b1 == 100

      b2 = backoff.(b1)
      assert b2 == 200

      b3 = backoff.(b2)
      assert b3 == 400
    end
  end
end
