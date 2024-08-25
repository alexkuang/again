defmodule AgainTest do
  use ExUnit.Case

  alias Again.{Policy, Backoff, Termination, MockAPI, MockClock}

  setup do
    Mox.verify_on_exit!()
  end

  describe "retry/2" do
    test "passes on the results if it succeeds without retrying" do
      # Given some retry policy with 3 attempts
      policy = %Policy{
        clock: MockClock,
        backoff: Backoff.constant_backoff(100),
        termination: Termination.limit_attempts(3)
      }

      # When the operation succeeds on the first try
      Mox.expect(MockAPI, :foo, 1, fn 1 -> {:ok, 1} end)
      Mox.stub(MockClock, :tick, fn -> 1 end)

      # Then the results are passed on
      assert Again.retry(policy, fn -> MockAPI.foo(1) end) == {:ok, 1}
    end

    test "stops retrying when the operation succeeds" do
      # Given some retry policy with 3 attempts
      policy = %Policy{
        clock: MockClock,
        backoff: Backoff.constant_backoff(100),
        termination: Termination.limit_attempts(3)
      }

      # When we have a call that fails the first time + succeeds the second time
      Mox.expect(MockAPI, :foo, 1, fn 1 -> {:error, :some_error} end)
      Mox.expect(MockAPI, :foo, 1, fn 1 -> {:ok, 1} end)

      # Then we expect to have waited just once with the configured backoff duration
      Mox.stub(MockClock, :tick, fn -> 1 end)
      Mox.expect(MockClock, :wait, fn 100 -> :ok end)

      # And the results are passed on
      assert Again.retry(policy, fn -> MockAPI.foo(1) end) == {:ok, 1}
    end

    test "passes on the error when retries run out based on max attempts" do
      # Given some retry policy with 3 attempts
      policy = %Policy{
        clock: MockClock,
        backoff: Backoff.constant_backoff(100),
        termination: Termination.limit_attempts(3)
      }

      # When we have a call that keeps failing
      Mox.expect(MockAPI, :foo, 3, fn 1 -> {:error, :some_error} end)

      # Then we expect to have waited with backoff according to the policy
      Mox.stub(MockClock, :tick, fn -> 1 end)
      Mox.expect(MockClock, :wait, 2, fn 100 -> :ok end)

      # And the error is passed to the caller
      assert Again.retry(policy, fn -> MockAPI.foo(1) end) == {:error, :some_error}
    end
  end
end
