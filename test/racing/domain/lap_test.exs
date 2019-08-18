defmodule Racing.Domain.LapTest do
  use ExUnit.Case
  alias Racing.Domain.Lap
  doctest Racing.Domain.Lap

  describe "build_lap/1" do
    test "nil log_line returns empty %Lap{}" do
      lap = Lap.build_lap(nil)
      assert lap == %Lap{}
    end

    test "empty log_line returns empty %Lap{}" do
      lap = Lap.build_lap([])
      assert lap == %Lap{}
    end

    test "log_line with less than 6 elems returns error" do
      lap = Lap.build_lap([1, 2, 3, 4, 5])
      assert {:error, message} = lap
    end

    test "log_line should be translated to a Lap struct" do
      line = ["23:49:08.277", "038", "F.MASSA","1", "1:02.852","44,275"]

      lap = Lap.build_lap(line)
      expected_lap = %Lap{
        start_time: ~T[23:49:08.277],
        pilot_id: "038",
        pilot_name: "F.MASSA",
        number: 1,
        timing: ~T[00:01:02.852],
        speed_avg: 44.275
      }

      assert lap == expected_lap
    end
  end
end
