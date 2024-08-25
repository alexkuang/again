defmodule Again.Termination do
  @moduledoc """
  Describes when to continue retrying and when to stop based on policy execution.

  Time unit is milliseconds unless otherwose noted.
  """

  @type policy :: (attempts :: pos_integer, elapsed_at_next :: pos_integer ->
                     should_terminate :: boolean)

  @doc "Retry up to `max_attempts` attempts."
  @spec limit_attempts(max_attempts :: pos_integer) :: policy
  def limit_attempts(max_attempts) do
    fn attempts, _elapsed_at_next -> attempts >= max_attempts end
  end

  @doc "Retry for no more than `max_duration`."
  @spec limit_duration(max_duration :: pos_integer) :: policy
  def limit_duration(max_duration) do
    fn _attempts, elapsed_at_next -> elapsed_at_next >= max_duration end
  end
end
