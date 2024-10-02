defmodule Reservator.Reservation.Segment do
  @moduledoc """
  Struct representing a segment of a reservation.
  """

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
  Function which loads segment data in as a string or an array of strings. In case
  the argument is an array, it will perform the singular string operation on each
  of its elements.

  Scans input string and generates a struct list for the given information.

  ## Examples

      iex> Reservator.Reservation.Segment.deserialize_segments("Flight SVQ 2023-03-02 06:40 -> BCN 09:59")
      {:ok,
        [
          %Reservator.Reservation.Segment{
            segment_type: "Flight",
            start_time: ~N[2023-03-02 06:40:00],
            start_location: "SVQ",
            end_time: ~N[2023-03-02 09:59:00],
            end_location: "BCN"
          }
        ]
      }

      iex> Reservator.Reservation.Segment.deserialize_segments(
      ...>   [
      ...>     "Flight SVQ 2023-03-02 06:40 -> BCN 09:59" <> "\\n" <>
      ...>     "Flight SVQ 2023-03-02 03:40 -> BCN 06:59"
      ...>   ]
      ...> )
      {
        :ok,
        [
          [
            %Reservator.Reservation.Segment{
              end_location: "BCN",
              end_time: ~N[2023-03-02 09:59:00],
              segment_type: "Flight",
              start_location: "SVQ",
              start_time: ~N[2023-03-02 06:40:00]
            },
            %Reservator.Reservation.Segment{
              end_location: "BCN",
              end_time: ~N[2023-03-02 06:59:00],
              segment_type: "Flight",
              start_location: "SVQ",
              start_time: ~N[2023-03-02 03:40:00]
            }
          ]
        ]
      }

      iex> Reservator.Reservation.Segment.deserialize_segments("Flight SVQ 2023-03-02 06:40 -> BCN 09:60")
      {:error, :deserialization_failed}
  """
  @spec deserialize_segments(content :: String.t() | list(String.t())) ::
          {:ok, list(Reservator.Reservation.Segment.t())} | {:error, :deserialization_failed}
  def deserialize_segments(content) when is_list(content) do
    deserialized_data =
      content
      |> Enum.map(&deserialize_segments/1)

    any_broken? =
      deserialized_data
      |> Enum.any?(fn segment_chunk ->
        case segment_chunk do
          {:error, _} ->
            true

          _ ->
            false
        end
      end)

    if any_broken? do
      {:error, :deserialization_failed}
    else
      {:ok, Enum.map(deserialized_data, &elem(&1, 1))}
    end
  end

  def deserialize_segments(content) when is_binary(content) do
    # That's a serious regex! But really is's a regex which does matching for a set amount of fields
    # (even if they don't exist), so that it handles both travel and location segments.
    #
    # Here's the breakdown:
    # 0) Segment type (ex. Flight), always defined
    # 1) Start location (ex. SVQ), always defined
    # 2) Start date (ex. 2023-01-05), always defined
    # 3) Start time (ex. 06:30), not always present
    # 4) End location (ex. BCN), not always present
    # 5) End date (ex. 2023-01-10), not always present
    # 6) End time (ex. 23:30), not always present

    data =
      Regex.scan(
        ~r/(\w+) (\w{3}) (\d{4}-\d{2}-\d{2}) (\d{2}:\d{2}) -> (\w{3}) ()(\d{2}:\d{2})|(\w+) (\w{3}) (\d{4}-\d{2}-\d{2})() -> ()(\d{4}-\d{2}-\d{2})()/m,
        content
      )
      |> Enum.map(fn [_match | groups] ->
        # It'll either match 7 or 14 elements
        groups
        |> Enum.take(-7)
        |> Enum.map(&empty_string_conversion/1)
      end)
      |> Enum.map(fn match ->
        start_time =
          gen_start_date(Enum.at(match, 2), Enum.at(match, 3))
          |> NaiveDateTime.from_iso8601!()

        end_time =
          gen_end_date(Enum.at(match, 2), Enum.at(match, 5), Enum.at(match, 6))
          |> NaiveDateTime.from_iso8601!()

        %__MODULE__{
          segment_type: Enum.at(match, 0),
          start_time: start_time,
          start_location: match |> Enum.at(1) |> String.upcase(),
          end_time: end_time,
          end_location: (Enum.at(match, 4) || Enum.at(match, 1)) |> String.upcase()
        }
      end)

    {:ok, data}
  rescue
    # Lazy way to do checking whether the information is correct.
    # The only actual breaking point can be during the date conversion
    # which yields an error block
    ArgumentError ->
      {:error, :deserialization_failed}
  end

  defp gen_start_date(start_date, nil), do: "#{start_date} 00:00:00"
  defp gen_start_date(start_date, start_time), do: "#{start_date} #{start_time}:00"

  defp gen_end_date(start_date, nil, end_time), do: "#{start_date} #{end_time}:00"
  defp gen_end_date(_start_date, end_date, _end_time), do: "#{end_date} 00:00:00"

  defp empty_string_conversion(""), do: nil
  defp empty_string_conversion(string), do: string

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
