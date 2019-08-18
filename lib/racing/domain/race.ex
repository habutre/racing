defmodule Racing.Domain.Race do
  require Logger
  alias Racing.Domain.{Lap, Race}
  defstruct [:position, :pilot_id, :pilot_name, :completed_laps, :total_timing]

  @type t :: %__MODULE__{
          position: integer(),
          pilot_id: String.t(),
          pilot_name: String.t(),
          completed_laps: integer(),
          total_timing: Time.t()
        }

  @spec build_race(Lap.t(), map()) :: %{required(String.t()) => Race.t()}
  def build_race(lap, race \\ %{}) do
    Logger.debug("Building race from available laps")
    aggregate(lap, race)
  end

  @spec build_ranking(Race.t()) :: list({String.t(), Race.t()})
  def build_ranking(race) do
    Logger.debug("Building Race ranking")
    race
    |> Enum.sort(fn {_k1, v1}, {_k2, v2} ->
      v1.completed_laps > v2.completed_laps and
        Time.compare(v1.total_timing, v2.total_timing) == :gt
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