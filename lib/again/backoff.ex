defmodule Again.Backoff do
  @moduledoc """
  Describes backoff algorithms for how long to wait between retry attempts.

  Time unit is milliseconds unless otherwose noted.
  """

  import Bitwise

  @type policy :: (last_backoff :: pos_integer -> next_backoff :: pos_integer)

  @doc "Use the same `backoff` duration after every retry.  e.g. 100, 100, 100, 100, ..."
  @spec constant_backoff(backoff :: pos_integer) :: policy
  def constant_backoff(backoff) do
    fn _ -> backoff end
  end

  @doc "Use an exponential backoff for each retry, starting with `start_with`.  e.g. 100, 200, 400, 800, ..."
  @spec exponential_backoff(start_with :: pos_integer) :: policy
  def exponential_backoff(start_with) do
    fn last_backoff ->
      if !last_backoff, do: start_with, else: last_backoff <<< 1
    end
  end

  @doc """
  Given an existing backoff policy, add jitter by introducing a randomness factor of `percentage` to its output.

  For example, if the original policy produces 100 and we have `percentage` of 10, then we produce 90 < backoff < 110
  """
  @spec jitter(policy :: policy, percentage :: float) :: policy
  def jitter(policy, percentage) do
    fn last_backoff ->
      original = policy.(last_backoff)
      diff = round(original * percentage)
      original + :rand.uniform(2 * diff) - diff
    end
  end
end
