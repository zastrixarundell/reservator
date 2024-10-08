defmodule Reservator.Reservation.Segment do
  @moduledoc """
  Struct representing a segment of a reservation.
  """
  require Logger

  defstruct [
    :segment_type,
    :start_time,
    :start_location,
    :end_time,
    :end_location
  ]

  @type t() :: %__MODULE__{
          segment_type: String.t(),
          start_time: NaiveDateTime.t(),
          start_location: String.t(),
          end_time: NaiveDateTime.t(),
          end_location: String.t()
        }

  @typedoc "The type of segment"
  @type segment_type :: String.t()

  @typedoc "TimeZone-less date_time for when the segment starts"
  @type start_time :: NaiveDateTime.t()

  @typedoc "Where does the segment start"
  @type start_location :: String.t()

  @typedoc "TimeZone-less date_time for when the segment ends"
  @type end_time :: NaiveDateTime.t()

  @typedoc "What is the end location. If it's a hotel, it will be the same as the start_location"
  @type end_location :: String.t()

  @doc """
  Decodes the string (which is a list of segments) into decoded segments. It splits by `\\n` (newline character),
  decodes and filters them.

  ## Examples

      iex> Reservator.Reservation.Segment.deserialize_segments("SEGMENT: Flight BCN 2023-03-02 15:00 -> NYC 22:45\\nSEGMENT: Flight NYC 2023-03-06 08:00 -> BOS 09:25")
      {
       :ok,
        [
          %Reservator.Reservation.Segment{
            segment_type: "Flight",
            start_time: ~N[2023-03-02 15:00:00],
            start_location: "BCN",
            end_time: ~N[2023-03-02 22:45:00],
            end_location: "NYC"
          },
          %Reservator.Reservation.Segment{
            segment_type: "Flight",
            start_time: ~N[2023-03-06 08:00:00],
            start_location: "NYC",
            end_time: ~N[2023-03-06 09:25:00],
            end_location: "BOS"
          }
        ]
      }
        
      iex> Reservator.Reservation.Segment.deserialize_segments("SEGMENT: Flight BCN 2023-03-02 15:00 -> NYC 22:45\\nSEGMENT: Flight NYC 2023-03-06 08:00 -> BOS 09:60")
      {
        :error,
        :deserialization_failed
      }
  """
  @spec deserialize_segments(reservations :: String.t()) ::
          {:ok, list(Segment.t())} | {:error, :deserialization_failed}
  def deserialize_segments(reservations) do
    segments =
      reservations
      |> String.split("\n")
      |> Enum.map(&deserialize_segment!/1)
      |> Enum.reject(&is_nil/1)

    {:ok, segments}
  rescue
    error in ArgumentError ->
      Logger.warning("Date failed with #{error.message}")
      {:error, :deserialization_failed}
  end

  @doc """
  Decodes the segment from a string. It will return either the decoded segment or raise `ArgumentError`.

  ## Examples

      iex> Reservator.Reservation.Segment.deserialize_segment!("SEGMENT: Hotel BCN 2023-01-05 -> 2023-01-10")
      %Reservator.Reservation.Segment{
        segment_type: "Hotel",
        start_time: ~N[2023-01-05 00:00:00],
        start_location: "BCN",
        end_time: ~N[2023-01-10 00:00:00],
        end_location: "BCN"
      }
  """
  @spec deserialize_segment!(segment :: binary()) :: Segment.t()
  def deserialize_segment!(
        <<"SEGMENT: Hotel ", location::binary-3, " ", start_date::binary-10, " -> ",
          end_date::binary-10>>
      ) do
    %__MODULE__{
      segment_type: "Hotel",
      start_time: gen_start_date(start_date, nil),
      start_location: location |> String.upcase(),
      end_time: gen_end_date(nil, end_date, nil),
      end_location: location |> String.upcase()
    }
  end

  def deserialize_segment!(
        <<"SEGMENT: Train ", location::binary-3, " ", start_date::binary-10, " ",
          start_time::binary-5, " -> ", end_location::binary-3, " ", end_time::binary-5>>
      ) do
    %__MODULE__{
      segment_type: "Train",
      start_time: gen_start_date(start_date, start_time),
      start_location: location |> String.upcase(),
      end_time: gen_end_date(start_date, nil, end_time),
      end_location: end_location |> String.upcase()
    }
  end

  def deserialize_segment!(
        <<"SEGMENT: Flight ", location::binary-3, " ", start_date::binary-10, " ",
          start_time::binary-5, " -> ", end_location::binary-3, " ", end_time::binary-5>>
      ) do
    %__MODULE__{
      segment_type: "Flight",
      start_time: gen_start_date(start_date, start_time),
      start_location: location |> String.upcase(),
      end_time: gen_end_date(start_date, nil, end_time),
      end_location: end_location |> String.upcase()
    }
  end

  def deserialize_segment!(_) do
    nil
  end

  defp gen_start_date(start_date, nil),
    do: "#{start_date} 00:00:00" |> NaiveDateTime.from_iso8601!()

  defp gen_start_date(start_date, start_time),
    do: "#{start_date} #{start_time}:00" |> NaiveDateTime.from_iso8601!()

  defp gen_end_date(start_date, nil, end_time),
    do: "#{start_date} #{end_time}:00" |> NaiveDateTime.from_iso8601!()

  defp gen_end_date(_start_date, end_date, _end_time),
    do: "#{end_date} 00:00:00" |> NaiveDateTime.from_iso8601!()

  # Implementation for the encoding part.
  defimpl String.Chars, for: __MODULE__ do
    @spec to_string(segment :: Reservator.Reservation.Segment.t()) :: String.t()
    def to_string(%Reservator.Reservation.Segment{} = segment) do
      case segment.segment_type do
        "Hotel" ->
          "Hotel at #{segment.start_location} on #{Calendar.strftime(segment.start_time, "%Y-%m-%d")} to #{Calendar.strftime(segment.end_time, "%Y-%m-%d")}"

        type ->
          "#{type} from #{segment.start_location} to #{segment.end_location} " <>
            "at #{Calendar.strftime(segment.start_time, "%Y-%m-%d %H:%M")} to #{Calendar.strftime(segment.end_time, "%H:%M")}"
      end
    end
  end
end
