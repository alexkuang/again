defmodule Again.FakeAPI do
  @callback(foo(input :: any) :: {:ok, any}, {:error, any})
end
