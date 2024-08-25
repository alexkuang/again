defmodule Again.ExecTest do
  use ExUnit.Case

  alias Again.{Exec, Policy, Backoff, Termination, MockClock}

  setup do
    Mox.verify_on_exit!()
  end

  describe "init/1" do
    test "initializes the execution" do
      exec = Exec.init(Policy.default())

      assert exec.attempts == 1
      assert exec.last_backoff == nil
      assert exec.next == nil
    end
  end

  describe "advance/1" do
    test "advances the execution state + provides the next op" do
      backoff = 100

      policy = %Policy{
        clock: MockClock,
        backoff: Backoff.constant_backoff(backoff),
        termination: Termination.limit_attempts(3)
      }

      Mox.stub(MockClock, :tick, fn -> 1 end)
      exec = Exec.init(policy)

      advanced = Exec.advance(exec)
      assert exec.attempts + 1 == advanced.attempts
      assert backoff == advanced.last_backoff
      assert {:continue, backoff} == advanced.next
    end

    test "errors when over-advancing" do
      policy = %Policy{
        clock: MockClock,
        backoff: Backoff.constant_backoff(100),
        termination: Termination.limit_attempts(1)
      }

      Mox.stub(MockClock, :tick, fn -> 1 end)
      exec = Exec.init(policy)
      # First advance is ok, because 1 attempt is allowed
      exec = Exec.advance(exec)

      # Second advance should throw, since it's already halted
      assert_raise ArgumentError, fn ->
        Exec.advance(exec)
      end
    end
  end
end
