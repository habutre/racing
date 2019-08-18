defmodule RacingTest do
  use ExUnit.Case
  import ExUnit.CaptureIO
  alias Racing.Domain.Race
  doctest Racing

  test "process racing log" do
    io_output = capture_io(fn -> Racing.process_race("../../../racing.log") end)

    assert String.contains?(io_output, "Posição")
    assert String.contains?(io_output, "038")
    assert String.contains?(io_output, "F.MASSA")
  end
end
