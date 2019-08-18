# lib/racing/infrastructure/log_reader.ex
defmodule Racing.Infrastructure.LogReader do
  alias __MODULE__

  def read(filename) do
    filename
    |> Path.expand(__DIR__)
    |> File.stream!
    |> Stream.map(fn line -> cleanup(line) 
      #line 
      #|> String.replace(~r/[\s\t]+/, " ", global: true)
      #|> String.replace("\u2013 ", "", global: true) # dash char + space
      #|> String.replace(" ", ";", global: true)
    end)
    |> CSV.decode!(separator: ?;, header: true, validate_row_length: false, strip_fields: true)
    |> Stream.drop(1)
    |> Stream.map(fn line -> List.delete(line, "") 
      #line
      #|> Stream.filter(fn col -> col != "" end)
      #|> Enum.to_list()
    end)
    |> Enum.to_list() 
  end

  defp cleanup(line) do
    line
    |> String.replace(~r/[\s\t]+/, " ", global: true)
    |> String.replace("\u2013 ", "", global: true) # dash char + space
    |> String.replace(" ", ";", global: true)
  end
end
