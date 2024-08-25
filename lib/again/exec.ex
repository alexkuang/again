defmodule Again.Exec do
  @moduledoc """
  Describes the metadata + state of a single execution of a retry operation.

  This is a low level API that is mostly useful for custom work + testing.  You probably want `Again.retry`.
  """

  alias Again.Policy

  defstruct policy: nil,
            started_at: nil,
            attempts: 1,
            last_backoff: nil,
            next: nil

  @type t :: %__MODULE__{
          policy: Policy.t(),
          started_at: pos_integer,
          attempts: pos_integer,
          last_backoff: pos_integer | nil,
          next: {:continue, backoff_millis :: pos_integer} | :halt | nil
        }

  @doc """
  Start an operation execution using the given policy.
  """
  @spec init(policy :: Policy.t()) :: t()
  def init(%Policy{} = policy) do
    started = policy.clock.tick()

    %__MODULE__{
      policy: policy,
      started_at: started
    }
  end

  @doc """
  Advance the execution of the policy + update the state for "one more retry"
  """
  @spec advance(t()) :: t()
  def advance(%__MODULE__{next: :halt}) do
    raise ArgumentError, "Tried to advance a halted execution"
  end

  def advance(%__MODULE__{} = exec) do
    %{policy: policy, attempts: attempts, last_backoff: last_backoff, started_at: started_at} =
      exec

    backoff = policy.backoff.(last_backoff)
    will_elapse = policy.clock.tick() - started_at + backoff

    if policy.termination.(attempts, will_elapse) do
      %{exec | next: :halt}
    else
      %{exec | attempts: attempts + 1, last_backoff: backoff, next: {:continue, backoff}}
    end
  end
end
