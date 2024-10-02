defmodule SegmentTest do
  use ExUnit.Case

  alias Reservator.Reservation.Segment

  doctest Segment

  describe "string format is correct" do
    test "when Flight" do
      segment =
        %Segment{
          segment_type: "Flight",
          start_location: "SVQ",
          start_time: NaiveDateTime.from_iso8601!("2023-03-02 06:40:00"),
          end_location: "BCN",
          end_time: NaiveDateTime.from_iso8601!("2023-03-02 09:10:00")
        }

      assert to_string(segment) == "Flight from SVQ to BCN at 2023-03-02 06:40 to 09:10"
    end

    test "when Train" do
      segment =
        %Segment{
          segment_type: "Train",
          start_location: "SVQ",
          start_time: NaiveDateTime.from_iso8601!("2023-03-02 06:40:00"),
          end_location: "BCN",
          end_time: NaiveDateTime.from_iso8601!("2023-03-02 09:10:00")
        }

      assert to_string(segment) == "Train from SVQ to BCN at 2023-03-02 06:40 to 09:10"
    end

    test "when Hotel" do
      segment =
        %Segment{
          segment_type: "Hotel",
          start_location: "BCN",
          start_time: NaiveDateTime.from_iso8601!("2023-01-05 00:00:00"),
          end_location: "BCN",
          end_time: NaiveDateTime.from_iso8601!("2023-01-10 00:00:00")
        }

      assert to_string(segment) == "Hotel at BCN on 2023-01-05 to 2023-01-10"
    end
  end
end
