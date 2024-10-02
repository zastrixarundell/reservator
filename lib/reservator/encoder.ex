defmodule Reservator.Encoder do
  @moduledoc """
  Provides functions for encoding segments into a human-readable file.
  """

  alias Reservator.Reservation.Segment

  @doc """
  Convert the given segment list into the expected output string.
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
      |> Enum.uniq()
      |> Enum.join(", ")

    "TRIP to #{joined_ending_locations}"
  end

  @spec is_travel_location?(node :: Segment.t(), starting_location :: String.t()) :: boolean()
  defp is_travel_location?(%Segment{} = node, starting_location)
       when is_binary(starting_location) do
    node.start_location != starting_location and
      node.end_location != starting_location
  end
end
