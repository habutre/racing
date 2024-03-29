defmodule Racing do
  import Racing.Helper.OutputFormatter

  alias Racing.Domain.{Lap, Race}
  alias Racing.Infrastructure.LogReader

  @moduledoc """
    Handles a log of Race's laps returning a ranked list of pilots

    Print the results out informing the user about the result of Race
  """

  @doc """
    Orchestrate the function's invocation to parse laps log, build and raking the Race
  """
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
      "|Posição Chegada|Código Piloto|Nome Piloto    |Qtde Voltas Completadas|Tempo Total de Prova|Melhor Volta|Média Velocidade|"
    )

    Enum.each(ranking, fn {_pilot_id, pilot} ->
      "|#{align_column(pilot.position, 15, " ", :left)}"
      |> (fn str -> str <> "|#{align_column(pilot.pilot_id, 13, " ", :left)}" end).()
      |> (fn str -> str <> "|#{align_column(pilot.pilot_name, 15, " ", :right)}" end).()
      |> (fn str -> str <> "|#{align_column(pilot.completed_laps, 23, " ", :left)}" end).()
      |> (fn str -> str <> "| #{align_column(pilot.total_timing, 19, " ", :left)}" end).()
      |> (fn str -> str <> "|#{pilot.best_lap}" end).()
      |> (fn str ->
            str <>
              "|#{
                align_column(
                  align_column(Float.round(pilot.speed_avg, 3), 6, "0", :right),
                  16,
                  " ",
                  :left
                )
              }|"
          end).()
      |> IO.puts()

    end)
  end

  @doc """
    Main function responsible to be the entrypoint of App
  """
  def main(_args) do
    process_race("/app/racing.log")
  end

end
