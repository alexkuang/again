# Again

[![hex package](https://img.shields.io/hexpm/v/again.svg)](https://hex.pm/packages/again)
[![hex docs](https://img.shields.io/badge/hex-docs-blue.svg)](https://hexdocs.pm/again/readme.html)
[![ci](https://github.com/alexkuang/again/actions/workflows/ci.yml/badge.svg)](https://github.com/alexkuang/again/actions/)

A library for retrying work again... and again... and again...

## Installation

```elixir
def deps do
  [
    {:again, "~> 0.1.0"}
  ]
end
```


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
- More docs + ergonomics

## Documentation

[Latest HexDocs](https://hexdocs.pm/again/)
