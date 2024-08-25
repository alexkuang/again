defmodule Again.SystemClock do
  @behaviour Again.Clock

  def tick(), do: System.monotonic_time(:millisecond)

  def wait(millis), do: Process.sleep(millis)
end
