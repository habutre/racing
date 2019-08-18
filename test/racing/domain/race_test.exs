defmodule Racing.Domain.RaceTest do
  use ExUnit.Case
  alias Racing.Domain.{Lap, Race}
  doctest Racing.Domain.Race

  describe "build_race/1" do
    test "build ranking when race is empty" do
      lap = %Lap{
        start_time: "no-time",
        pilot_id: "pilot-x",
        pilot_name: "X Pilot",
        number: 4,
        timing: Time.from_iso8601!("00:01:37.500000"),
        speed_avg: "total-time"
      }

      expected_race = %Race{
        position: 1,
        pilot_id: "pilot-x",
        pilot_name: "X Pilot",
        completed_laps: 4,
        total_timing: Time.from_iso8601!("00:01:37.500000")
      }

      race_of_pilot_x = Map.get(Race.build_race(lap, %{}), "pilot-x")

      assert race_of_pilot_x == expected_race
    end

    test "build ranking when race is nil" do
      lap = %Lap{
        start_time: "no-time",
        pilot_id: "pilot-x",
        pilot_name: "X Pilot",
        number: 4,
        timing: Time.from_iso8601!("00:01:11.500000"),
        speed_avg: "total-time"
      }

      expected_race = %Race{
        position: 1,
        pilot_id: "pilot-x",
        pilot_name: "X Pilot",
        completed_laps: 4,
        total_timing: Time.from_iso8601!("00:01:11.500000")
      }

      race_of_pilot_x = Map.get(Race.build_race(lap, nil), "pilot-x")

      assert race_of_pilot_x == expected_race
    end

    test "build ranking when race parameter is missing" do
      lap = %Lap{
        start_time: "no-time",
        pilot_id: "pilot-x",
        pilot_name: "X Pilot",
        number: 2,
        timing: Time.from_iso8601!("00:01:01.500000"),
        speed_avg: "total-time"
      }

      expected_race = %Race{
        position: 1,
        pilot_id: "pilot-x",
        pilot_name: "X Pilot",
        completed_laps: 2,
        total_timing: Time.from_iso8601!("00:01:01.500000")
      }

      race_of_pilot_x = Map.get(Race.build_race(lap), "pilot-x")

      assert race_of_pilot_x == expected_race
    end

    test "keeps ranking intact when lap is empty" do
      lap = %Lap{
        start_time: "no-time",
        pilot_id: "pilot-x",
        pilot_name: "X Pilot",
        number: 1,
        timing: Time.from_iso8601!("00:01:08.500000"),
        speed_avg: "total-time"
      }

      expected_race = %Race{
        position: 1,
        pilot_id: "pilot-x",
        pilot_name: "X Pilot",
        completed_laps: 1,
        total_timing: Time.from_iso8601!("00:01:08.500000")
      }

      race = Race.build_race(lap)
      race_of_pilot_x = Map.get(race, "pilot-x")

      assert race_of_pilot_x == expected_race

      intact_race = Map.get(Race.build_race(%{}, race), "pilot-x")

      assert intact_race == expected_race
    end

    test "keeps ranking intact when lap is nil" do
      lap = %Lap{
        start_time: "no-time",
        pilot_id: "pilot-x",
        pilot_name: "X Pilot",
        number: 1,
        timing: Time.from_iso8601!("00:01:58.500000"),
        speed_avg: "total-time"
      }

      expected_race = %Race{
        position: 1,
        pilot_id: "pilot-x",
        pilot_name: "X Pilot",
        completed_laps: 1,
        total_timing: Time.from_iso8601!("00:01:58.500000")
      }

      race = Race.build_race(lap)
      race_of_pilot_x = Map.get(race, "pilot-x")

      assert race_of_pilot_x == expected_race

      intact_race = Map.get(Race.build_race(nil, race), "pilot-x")

      assert intact_race == expected_race
    end

    test "expect potential winner had completed 4 laps" do
      laps = [
        %Lap{
          start_time: "no-time",
          pilot_id: "pilot-x",
          pilot_name: "X Pilot",
          number: 1,
          timing: Time.from_iso8601!("00:01:17.500000"),
          speed_avg: "total-time"
        },
        %Lap{
          start_time: "no-time",
          pilot_id: "pilot-y",
          pilot_name: "Y Pilot",
          number: 1,
          timing: Time.from_iso8601!("00:01:05.500000"),
          speed_avg: "total-time"
        },
        %Lap{
          start_time: "no-time",
          pilot_id: "pilot-x",
          pilot_name: "X Pilot",
          number: 2,
          timing: Time.from_iso8601!("00:01:21.500000"),
          speed_avg: "total-time"
        },
        %Lap{
          start_time: "no-time",
          pilot_id: "pilot-y",
          pilot_name: "Y Pilot",
          number: 2,
          timing: Time.from_iso8601!("00:01:57.500000"),
          speed_avg: "total-time"
        },
        %Lap{
          start_time: "no-time",
          pilot_id: "pilot-x",
          pilot_name: "X Pilot",
          number: 3,
          timing: Time.from_iso8601!("00:01:38.500000"),
          speed_avg: "total-time"
        },
        %Lap{
          start_time: "no-time",
          pilot_id: "pilot-x",
          pilot_name: "X Pilot",
          number: 4,
          timing: Time.from_iso8601!("00:01:51.500000"),
          speed_avg: "total-time"
        }
      ]

      expected_pilot_x_race = %Race{
        position: 1,
        pilot_id: "pilot-x",
        pilot_name: "X Pilot",
        completed_laps: 4,
        total_timing: Time.from_iso8601!("00:06:09.000000")
      }

      expected_pilot_y_race = %Race{
        position: 1,
        pilot_id: "pilot-y",
        pilot_name: "Y Pilot",
        completed_laps: 2,
        total_timing: Time.from_iso8601!("00:03:03.000000")
      }

      race_final =
        Enum.reduce(laps, %{}, fn lap, race ->
          Race.build_race(lap, race)
        end)

      pilot_x_race = Map.get(race_final, "pilot-x")
      pilot_y_race = Map.get(race_final, "pilot-y")

      {"pilot-x", winner} = List.first(Race.build_ranking(race_final))

      assert map_size(race_final) == 2
      assert pilot_x_race == expected_pilot_x_race
      assert pilot_y_race == expected_pilot_y_race
      assert winner == pilot_x_race
    end
  end

  describe "build_ranking/1" do
    test "build race ranking" do
      laps = [
        %Lap{
          start_time: "no-time",
          pilot_id: "pilot-x",
          pilot_name: "X Pilot",
          number: 1,
          timing: Time.from_iso8601!("00:01:17.500000"),
          speed_avg: "total-time"
        },
        %Lap{
          start_time: "no-time",
          pilot_id: "pilot-y",
          pilot_name: "Y Pilot",
          number: 1,
          timing: Time.from_iso8601!("00:01:05.500000"),
          speed_avg: "total-time"
        },
        %Lap{
          start_time: "no-time",
          pilot_id: "pilot-x",
          pilot_name: "X Pilot",
          number: 2,
          timing: Time.from_iso8601!("00:01:21.500000"),
          speed_avg: "total-time"
        },
        %Lap{
          start_time: "no-time",
          pilot_id: "pilot-y",
          pilot_name: "Y Pilot",
          number: 2,
          timing: Time.from_iso8601!("00:01:57.500000"),
          speed_avg: "total-time"
        },
        %Lap{
          start_time: "no-time",
          pilot_id: "pilot-x",
          pilot_name: "X Pilot",
          number: 3,
          timing: Time.from_iso8601!("00:01:38.500000"),
          speed_avg: "total-time"
        },
        %Lap{
          start_time: "no-time",
          pilot_id: "pilot-x",
          pilot_name: "X Pilot",
          number: 4,
          timing: Time.from_iso8601!("00:01:51.500000"),
          speed_avg: "total-time"
        }
      ]

      race_final =
        Enum.reduce(laps, %{}, fn lap, race ->
          Race.build_race(lap, race)
        end)

      result = Race.build_ranking(race_final)
      {pilot, winner} = List.first(result)

      assert map_size(race_final) == 2
      assert is_map(winner)
      assert winner.position == 1
      assert winner.pilot_id == "pilot-x"
      assert pilot == "pilot-x"
    end
  end
end
