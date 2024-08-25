defmodule Again do
  @moduledoc """
  A library for retrying work again... and again... and again...
  """

  alias Again.{Exec, Policy}

  @spec retry(policy :: Policy.t(), fun :: (-> any)) :: any
  def retry(policy, fun) do
    do_retry(Exec.init(policy), fun)
  end

  defp do_retry(exec, fun) do
    case fun.() do
      {:error, err} ->
        exec = Exec.advance(exec)

        case exec.next do
          :halt ->
            {:error, err}

          {:continue, backoff_duration} ->
            exec.policy.clock.wait(backoff_duration)
            do_retry(exec, fun)
        end

      {:ok, res} ->
        {:ok, res}
    end
  end
end
