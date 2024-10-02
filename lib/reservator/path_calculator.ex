defmodule Reservator.PathCalculator do
  @moduledoc """
  Provides functions to calculate paths for reservations.
  """

  alias Reservator.Reservation.Segment

  require Logger

  @doc """
  Function for calculating reservation path. Returns a 2-element touple. First element
  would be direction connections. The other element would be segments which aren't connected
  to any other segment within 24 hours.    
  """
  @spec calculate_path(starting_location :: binary(), segments :: list(Segment.t()))
    :: {built_paths :: list(list(Segment.t())), remainder_segments :: list(Segment.t())}
  def calculate_path(starting_location, segments) when is_bitstring(starting_location) do
    {start_nodes, travel_nodes} =
      segments
      |> sort_nodes()
      |> Enum.split_with(&same_location?(starting_location, &1))
      |> wrap_starting_locations()

    # Using reduce over here for memory optimization
    start_nodes
    |> Enum.reduce({[], travel_nodes}, fn current_node, {existing_paths, remainder_nodes} ->
      {new_path, nodes} = build_node_path(current_node, remainder_nodes)

      {existing_paths ++ [new_path], nodes}
    end)
  end

  defp sort_nodes(nodes) do
    Enum.sort(nodes, fn node1, node2 ->
      case NaiveDateTime.compare(node1.start_time, node2.start_time) do
        :gt -> false
        _ -> true
      end
    end)
  end

  defp same_location?(location, %Segment{} = node) do
    node.start_location == location
  end

  defp wrap_starting_locations({start_nodes, nodes}) do
    {
      start_nodes |> Enum.map(&List.wrap/1),
      nodes
    }
  end

  defp build_node_path(starting_node, potential_nodes) do
    # Safe operator for maximum calls
    (1..length(potential_nodes))
    |> Enum.reduce_while({starting_node, potential_nodes}, fn _, {root_path, node_list} ->
      end_node = root_path |> List.last()

      case pop_first_match(node_list, &connected_node?(&1, end_node)) do
        {nil, _} ->
          {:halt, {root_path, node_list}}

        {match, new_list} ->
          {:cont, {root_path ++ [match], new_list}}
      end
    end)
  end

  defp pop_first_match(list, fun) do
    case Enum.find_index(list, &fun.(&1)) do
      nil ->
        {nil, list}

      index ->
        {Enum.at(list, index), List.delete_at(list, index)}
    end
  end

  defp connected_node?(%Segment{} = leaf_node, %Segment{} = root_node) do
    case leaf_node.segment_type do
      "Hotel" ->
        root_node.end_location == leaf_node.start_location and
          NaiveDateTime.beginning_of_day(root_node.end_time) == NaiveDateTime.beginning_of_day(leaf_node.start_time)

      _ ->
        time_compare = NaiveDateTime.compare(root_node.end_time, leaf_node.start_time)

        root_node.end_location == leaf_node.start_location and
          (time_compare == :lt or time_compare == :eq) and
          (NaiveDateTime.diff(leaf_node.start_time, root_node.end_time, :hour) <= 24)
    end
    |> tap(&Logger.debug("""
      For node #{inspect(root_node, pretty: true)} and
      #{inspect(leaf_node, pretty: true)} the result is: #{inspect(&1)}
      """))
  end
end
