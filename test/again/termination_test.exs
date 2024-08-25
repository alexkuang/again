defmodule Again.TerminationTest do
  use ExUnit.Case

  alias Again.Termination

  describe "limit_attempts" do
    test "returns false when # of attempts < defined limit" do
      termination = Termination.limit_attempts(5)
      assert termination.(3, 100) == false
    end

    test "returns true when # of attempts > defined limit" do
      termination = Termination.limit_attempts(5)
      assert termination.(10, 100) == true
    end
  end

  describe "limit_duration" do
    test "returns false when time elapsed @ next attempt < defined limit" do
      termination = Termination.limit_duration(500)
      assert termination.(1, 100) == false
    end

    test "returns true when time elapsed @ next attempt > defined limit" do
      termination = Termination.limit_duration(500)
      assert termination.(1, 600) == true
    end
  end
end
