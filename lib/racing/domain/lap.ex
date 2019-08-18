defmodule Racing.Domain.Lap do
  defstruct [:start_time, :pilot_id, :pilot_name, :number, :timing, :speed_avg]

  @type t :: %__MODULE__{
          start_time: DateTime.t(),
          pilot_id: String.t(),
          pilot_name: String.t(),
          number: integer(),
          timing: Time.t(),
          speed_avg: float()
        }
end
