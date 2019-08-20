defmodule Racing.Domain.Race do
  require Logger
  alias Racing.Domain.{Lap, Race}
  defstruct [:position, :pilot_id, :pilot_name, :completed_laps, :total_timing]

  @moduledoc """
    Represents a Race information by its struct

    Use Laps to build a Race ranking the pilots
  """

  @type t :: %__MODULE__{
          position: integer(),
          pilot_id: String.t(),
          pilot_name: String.t(),
          completed_laps: integer(),
          total_timing: Time.t()
        }

  @doc """
  Builds a race using the lap informed accumulating
  laps on a new map() when anyone is informed or appending
  on a existent one

  Returns a map() of Races identified by pilot's ID
  """
  @spec build_race(Lap.t(), map()) :: %{required(String.t()) => Race.t()}
  def build_race(lap, race \\ %{}) do
    aggregate(lap, race)
  end

  @doc """
    Assembly a ranking when all laps were processed

    Returns a ranked Race by laps completed and smaller timing
  """
  @spec build_ranking(map()) :: list({String.t(), Race.t()})
  def build_ranking(race) do
    Logger.debug("Building Race ranking #{Map.keys(race)}")

    race
    |> Enum.sort(fn {_k1, v1}, {_k2, v2} ->
      v1.completed_laps >= v2.completed_laps and
        Time.compare(v1.total_timing, v2.total_timing) == :lt
    end)
    |> Stream.transform(1, fn item, acc ->
      {key, value} = item
      new_value = Map.put(value, :position, acc)
      {%{key => new_value}, acc + 1}
    end)
    |> Enum.to_list()
  end

  defp aggregate(lap, race) when is_nil(lap), do: race
  defp aggregate(lap, race) when map_size(lap) == 0, do: race

  defp aggregate(lap, race) when map_size(race) == 0 do
    Logger.debug("Building race from lap: #{lap.number}|#{lap.pilot_id}")

    %{
      lap.pilot_id => %Race{
        position: 1,
        pilot_id: lap.pilot_id,
        pilot_name: lap.pilot_name,
        completed_laps: lap.number,
        total_timing: lap.timing
      }
    }
  end

  defp aggregate(lap, race) when is_nil(race) do
    Logger.debug("Building race from lap: #{lap.number}|#{lap.pilot_id}")

    %{
      lap.pilot_id => %Race{
        position: 1,
        pilot_id: lap.pilot_id,
        pilot_name: lap.pilot_name,
        completed_laps: lap.number,
        total_timing: lap.timing
      }
    }
  end

  defp aggregate(lap, race) do
    Logger.debug("Building race from lap: #{lap.number}|#{lap.pilot_id}")

    race_aggregated =
      case Map.get(race, lap.pilot_id) do
        nil ->
          Map.put(race, lap.pilot_id, %Race{
            position: 1,
            pilot_id: lap.pilot_id,
            pilot_name: lap.pilot_name,
            completed_laps: lap.number,
            total_timing: lap.timing
          })

        _ ->
          Map.update!(race, lap.pilot_id, fn pilot_race ->
            %{
              pilot_race
              | completed_laps: lap.number,
                total_timing: sum_time(pilot_race.total_timing, lap.timing)
            }
          end)
      end

    race_aggregated
  end

  @doc """
    This function was added due lack of a simple time additon on Time or Timex libs
    A good approach would be t0 + t1 wich will consider all time units H, M, S, µs
  """
  @spec sum_time(Time.t(), Time.t()) :: Time.t()
  defp sum_time(cur_time, time2add) do
    seconds_from_lap = time2add.minute * 60 + time2add.second
    {microsends_from_lap, _} = time2add.microsecond

    cur_time
    |> Time.add(seconds_from_lap, :second)
    |> Time.add(microsends_from_lap, :microsecond)
  end
end
