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

  describe "jitter" do
    test "introduces proportional jitter to an existing backoff" do
      backoff = Backoff.constant_backoff(100) |> Backoff.jitter(0.10)

      # At some point, may want to bring in a props-based testing framework
      Enum.each(0..500, fn _ ->
        b = backoff.(nil)
        assert b >= 90
        assert b <= 110
      end)
    end
  end
end
