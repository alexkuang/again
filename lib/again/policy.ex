defmodule Again.Policy do
  @moduledoc """
  Describes conditions and mechanics for retry logic.  e.g. "retry up to 3 times, waiting 100ms each time"
  """
  alias Again.{Backoff, Clock, SystemClock, Termination}

  defstruct clock: nil,
            backoff: nil,
            termination: nil

  @type t :: %__MODULE__{
          clock: Clock.t(),
          backoff: Again.Backoff.policy(),
          termination: Again.Termination.policy()
        }

  @spec default :: t()
  def default do
    %__MODULE__{
      clock: SystemClock,
      backoff: Backoff.exponential_backoff(100),
      termination: Termination.limit_attempts(5)
    }
  end
end
