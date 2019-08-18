defmodule Racing.Domain.Lap do
  alias __MODULE__
  defstruct [:start_time, :pilot_id, :pilot_name, :number, :timing, :speed_avg]

  @type t :: %__MODULE__{
          start_time: DateTime.t(),
          pilot_id: String.t(),
          pilot_name: String.t(),
          number: integer(),
          timing: Time.t(),
          speed_avg: float()
        }

  def build_lap([] = _log_line), do: %__MODULE__{}
  def build_lap(log_line) when is_nil(log_line), do: %__MODULE__{}

  def build_lap(log_line) when length(log_line) < 6,
    do: {:error, "The line #{log_line} is missing columns or corrupted"}

  @spec build_lap(list()) :: Lap.t() | {:error, String.t()}
  def build_lap(log_line) do
    {start_time, pilot_id, pilot_name, number, timing, speed_avg} = List.to_tuple(log_line)

    %__MODULE__{
      start_time: Time.from_iso8601!(start_time),
      pilot_id: pilot_id,
      pilot_name: pilot_name,
      number: String.to_integer(number),
      timing: Time.from_iso8601!("00:" <> String.pad_leading(timing, 9, "0")),
      speed_avg: String.to_float(speed_avg)
    }
  end
end
