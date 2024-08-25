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

    test "uses clock output when interacting with termination policy" do
      backoff = 250
      max_duration = 300

      policy = %Policy{
        clock: MockClock,
        backoff: Backoff.constant_backoff(backoff),
        termination: Termination.limit_duration(max_duration)
      }

      # Given a policy with 250ms backoff + max duration of 300ms, and t = 1 when we start execution
      Mox.expect(MockClock, :tick, fn -> 1 end)
      exec = Exec.init(policy)

      # When we advance the first time @ t = 2
      Mox.expect(MockClock, :tick, fn -> 2 end)
      advanced = Exec.advance(exec)

      # Then the advance succeeds because next attempt would be under threshold, i.e. (2ms tick + 250ms backoff) < 300
      assert exec.attempts + 1 == advanced.attempts
      assert backoff == advanced.last_backoff
      assert {:continue, backoff} == advanced.next

      # And when we advance the second time @ t=252
      Mox.expect(MockClock, :tick, fn -> 252 end)
      advanced = Exec.advance(exec)

      # Then we halt because the next attempt would be over threshold, i.e. (252 + 250) > 300
      assert exec.attempts == advanced.attempts
      assert :halt == advanced.next
    end

    test "errors when advancing above configured attempt limit" do
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
