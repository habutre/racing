defmodule Racing do
  alias Racing.Domain.{Lap, Race}
  alias Racing.Infrastructure.LogReader

  def process_race(log_full_filename) do
    LogReader.read(log_full_filename)
    |> Enum.map(&Lap.build_lap/1)
    |> Enum.reduce(%{}, fn lap, race -> Race.build_race(lap, race) end)
    |> Enum.into(%{})
    |> Race.build_ranking()
    |> print_result()
  end

  defp print_result(ranking) do
    IO.puts(
      "|Posição Chegada | Código Piloto |  Nome Piloto | Qtde Voltas Completadas |  Tempo Total de Prova |"
    )

    Enum.each(ranking, fn {_pilot_id, pilot} ->
      IO.puts(
        "#{pilot.position} | #{pilot.pilot_id} | #{String.pad_trailing(pilot.pilot_name, 15, " ")} | #{
          pilot.completed_laps
        } | #{pilot.total_timing} |"
      )
    end)
  end

  def main(_args) do
    process_race("/app/racing.log")
  end
end
