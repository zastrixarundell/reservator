defmodule Reservator.Encoder do
  @moduledoc """
  Provides functions for encoding segments into a human-readable file.
  """

  alias Reservator.Reservation.Segment

  @doc """
  Convert the given segment list into the expected output string.

  ## Examples

      iex> Reservator.Encoder.convert_to_string(
      ...>   "SVQ",
      ...>   [
      ...>     [
      ...>       %Reservator.Reservation.Segment{
      ...>         segment_type: "Flight",
      ...>         start_time: ~N[2023-03-02 06:40:00],
      ...>         start_location: "SVQ",
      ...>         end_time: ~N[2023-03-02 09:10:00],
      ...>         end_location: "BCN"
      ...>       },
      ...>       %Reservator.Reservation.Segment{
      ...>         segment_type: "Flight",
      ...>         start_time: ~N[2023-03-02 15:00:00],
      ...>         start_location: "BCN",
      ...>         end_time: ~N[2023-03-02 22:45:00],
      ...>         end_location: "NYC"
      ...>       }
      ...>     ]
      ...>   ]
      ...> )
      "TRIP to NYC\\nFlight from SVQ to BCN at 2023-03-02 06:40 to 09:10\\nFlight from BCN to NYC at 2023-03-02 15:00 to 22:45"
      
      iex> Reservator.Encoder.convert_to_string(
      ...>   "SVQ",
      ...>   [
      ...>     [
      ...>       %Reservator.Reservation.Segment{
      ...>         segment_type: "Flight",
      ...>         start_time: ~N[2023-03-02 06:40:00],
      ...>         start_location: "SVQ",
      ...>         end_time: ~N[2023-03-02 09:10:00],
      ...>         end_location: "BCN"
      ...>       },
      ...>       %Reservator.Reservation.Segment{
      ...>         segment_type: "Flight",
      ...>         start_time: ~N[2023-03-02 15:00:00],
      ...>         start_location: "BCN",
      ...>         end_time: ~N[2023-03-02 22:45:00],
      ...>         end_location: "NYC"
      ...>       },
      ...>       %Reservator.Reservation.Segment{
      ...>         segment_type: "Flight",
      ...>         start_time: ~N[2023-03-02 15:00:00],
      ...>         start_location: "NYC",
      ...>         end_time: ~N[2023-03-03 00:00:00],
      ...>         end_location: "BCN"
      ...>       },
      ...>       %Reservator.Reservation.Segment{
      ...>         segment_type: "Flight",
      ...>         start_time: ~N[2023-03-03 15:00:00],
      ...>         start_location: "BCN",
      ...>         end_time: ~N[2023-03-03 22:45:00],
      ...>         end_location: "NYC"
      ...>       }
      ...>     ]
      ...>   ]
      ...> )
      "TRIP to NYC, BCN, NYC\\nFlight from SVQ to BCN at 2023-03-02 06:40 to 09:10\\n" <>
        "Flight from BCN to NYC at 2023-03-02 15:00 to 22:45\\n" <>
        "Flight from NYC to BCN at 2023-03-02 15:00 to 00:00\\n" <>
        "Flight from BCN to NYC at 2023-03-03 15:00 to 22:45"
  """
  @spec convert_to_string(starting_location :: String.t(), segments :: list(list(Segment.t()))) ::
          String.t()
  def convert_to_string(starting_location, segments) do
    Enum.map_join(segments, "\n\n", fn segments ->
      generate_end_destinations(starting_location, segments) <> "\n" <> convert_segments(segments)
    end)
  end

  @spec convert_segments(segments :: list(Segment.t())) :: String.t()
  defp convert_segments(segments) do
    segments
    |> Enum.map_join("\n", &to_string/1)
  end

  @spec generate_end_destinations(starting_location :: String.t(), segments :: list(Segment.t())) ::
          String.t()
  defp generate_end_destinations(starting_location, segments) do
    joined_ending_locations =
      segments
      |> Enum.filter(&is_travel_location?(&1, starting_location))
      |> Enum.map(fn node -> node.end_location end)
      |> delete_consecutive_duplicates()
      |> Enum.join(", ")

    "TRIP to #{joined_ending_locations}"
  end

  @spec is_travel_location?(node :: Segment.t(), starting_location :: String.t()) :: boolean()
  defp is_travel_location?(%Segment{} = node, starting_location)
       when is_binary(starting_location) do
    node.start_location != starting_location and
      node.end_location != starting_location
  end

  @spec delete_consecutive_duplicates(list(Segment.t())) :: list(Segment.t())
  defp delete_consecutive_duplicates(list) do
    Stream.cycle([nil])
    |> Enum.reduce_while({list, 0}, &delete_consecutive_duplicates_logic(&1, &2))
  end

  @spec delete_consecutive_duplicates_logic(
          any(),
          {current_list :: list(Segment.t()), index :: integer()}
        ) ::
          {:cont, {list(Segment.t()), integer()}} | {:halt, list(Segment.t())}
  defp delete_consecutive_duplicates_logic(_, {current_list, index}) do
    if index >= length(current_list) - 1 do
      {:halt, current_list}
    else
      current_element = Enum.at(current_list, index)
      next_element = Enum.at(current_list, index + 1)

      if current_element == next_element do
        {:cont, {List.delete(current_list, index + 1), index}}
      else
        {:cont, {current_list, index + 1}}
      end
    end
  end
end
