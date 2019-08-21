defmodule Racing.Helper.OutputFormatter do
  @moduledoc """
    Provide some helpful functions to format the console output
  """

  def align_column(value, size, pad_char, :left) do
    value_str = convert_to_str(value)
    String.pad_leading(value_str, size, pad_char)
  end

  def align_column(value, size, pad_char, :right) do
    value_str = convert_to_str(value)
    String.pad_trailing(value_str, size, pad_char)
  end

  def convert_to_str(value) do
    cond do
      is_integer(value) -> Integer.to_string(value)
      is_float(value) -> Float.to_string(value)
      # workaround for times %Time{}
      is_map(value) -> Time.to_string(value)
      true -> value
    end
  end
end
