defmodule Again.Clock do
  @type t() :: module()

  @callback tick() :: integer

  @callback wait(millis :: pos_integer) :: :ok
end
