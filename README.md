# Again

A library for retrying work again... and again... and again...

## Usage

```elixir
# Create a retry policy
alias Again.{Backoff, Clock, SystemClock, Termination}

policy =
  %Again.Policy{
    clock: SystemClock,
    backoff: Backoff.exponential_backoff(100),
    termination: Termination.limit_attempts(5)
  }

# Use it
Again.retry(policy, fn ->
  do_something_that_might_fail()
end)
```

## TODO
A couple of things before this library is ready for primetime:
- Better classification for error + success results
- Observability into execution state / `Logger` integration
