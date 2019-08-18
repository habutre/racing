# test/racing/infrastructure/log_reader_test.exs
defmodule Racing.Infrastructure.LogReaderTest do
  use ExUnit.Case
  alias Racing.Infrastructure.LogReader

  describe "read/1" do
    test "notify the users when less columns were found" do
      line1 = ["23:49:08.277", "038", "F.MASSA","1", "1:02.852","44,275"]
      line2 = ["23:49:10.858", "033", "R.BARRICHELLO", "1", "1:04.352", "43,243"]

      content = LogReader.read("../../../test/support/racing_sample.log")

      assert is_list(content)
      assert List.first(content) == line1
      assert List.last(content) == line2
    end
  end
end
