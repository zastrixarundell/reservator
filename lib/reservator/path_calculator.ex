defmodule Reservator.PathCalculator do
  @moduledoc """
  Provides functions to calculate paths for reservations.
  """

  alias Reservator.PathCalculator.Storage
  alias Reservator.Reservation.Segment

  require Logger

  @doc """
  Function for calculating reservation path. Returns a 2-element touple. First element
  would be direction connections. The other element would be segments which aren't connected
  to any other segment within 24 hours.    
  """
  @spec calculate_path(String.t(), list(list(Segment.t()))) ::
          {list(list(Segment.t())), list(list(Segment.t()))}
  def calculate_path(starting_location, segments) when is_binary(starting_location) do
    {start_paths, travel_paths} =
      segments
      |> sort_nodes()
      |> Enum.split_with(&starting_path?(starting_location, &1))

    # Not really going to use a cond, if an Agent doesn't manage to start
    # there's something wrong outside of the app
    {:ok, storage_pid} = Storage.start_link(travel_paths)

    calcualted_paths =
      start_paths
      |> Enum.map(fn start_path ->
        build_node_path(start_path, storage_pid)
      end)

    {calcualted_paths, Storage.list_paths(storage_pid)}
  end

  @spec sort_nodes(node_matrix :: list(list(Segment.t()))) :: list(list(Segment.t()))
  defp sort_nodes(node_matrix) do
    node_matrix
    |> Enum.sort(fn row1, row2 ->
      case NaiveDateTime.compare(List.first(row1).start_time, List.first(row2).start_time) do
        :gt -> false
        _ -> true
      end
    end)
  end

  @spec starting_path?(String.t(), node_path :: list(Segment.t())) :: boolean()
  defp starting_path?(location, node_path) when is_binary(location) do
    List.first(node_path).start_location == location
  end

  @spec build_node_path(list(Segment.t()), storage_pid :: pid()) :: list(Segment.t())
  defp build_node_path(starting_path, storage_pid) do
    # Not an issue, a numeric index is used to safe-exit
    Stream.cycle([nil])
    |> Enum.reduce_while({starting_path, 0}, &build_node_path_logic(&1, &2, storage_pid))
  end

  @spec build_node_path_logic(
          _ :: any(),
          {current_path :: list(Segment.t()), current_index :: integer()},
          storage_pid :: pid()
        ) ::
          {:halt, calculated_path :: list(Segment.t())}
          | {:cont, {path :: list(Segment.t()), index :: integer()}}
  defp build_node_path_logic(_, {current_path, current_index}, storage_pid) do
    {leading_root, tailing_root} = Enum.split(current_path, current_index + 1)

    connected_node =
      Storage.list_paths(storage_pid)
      |> Enum.find(&connected_mid_nodes?(leading_root, tailing_root, &1))

    case connected_node do
      nil ->
        if current_index == length(current_path) - 1 do
          {:halt, current_path}
        else
          {:cont, {current_path, current_index + 1}}
        end

      nodes ->
        Storage.remove_node(storage_pid, nodes)
        {:cont, {leading_root ++ nodes ++ tailing_root, current_index}}
    end
  end

  @spec connected_mid_nodes?(
          leading_root_path :: list(Segment.t()),
          tailing_root_path :: list(Segment.t()),
          current_path :: list(Segment.t())
        ) :: boolean()
  defp connected_mid_nodes?(leading_root_path, [], current_path)
       when is_list(leading_root_path) and is_list(current_path) do
    left_node = leading_root_path |> List.last()
    right_node = current_path |> List.first()

    connected_node?(left_node, right_node)
  end

  defp connected_mid_nodes?(leading_root_path, tailing_root_path, current_path)
       when is_list(leading_root_path) and is_list(current_path) and is_list(tailing_root_path) do
    left_1_node = leading_root_path |> List.last()
    right_1_node = current_path |> List.first()

    left_2_node = current_path |> List.last()
    right_2_node = tailing_root_path |> List.first()

    connected_node?(left_1_node, right_1_node) and connected_node?(left_2_node, right_2_node)
  end

  @spec connected_node?(left_node :: Segment.t(), right_node :: Segment.t()) :: boolean()
  defp connected_node?(%Segment{} = left_node, %Segment{} = right_node) do
    case right_node.segment_type do
      "Hotel" ->
        left_node.end_location == right_node.start_location and
          NaiveDateTime.beginning_of_day(left_node.end_time) ==
            NaiveDateTime.beginning_of_day(right_node.start_time)

      _ ->
        time_compare = NaiveDateTime.compare(left_node.end_time, right_node.start_time)

        left_node.end_location == right_node.start_location and
          (time_compare == :lt or time_compare == :eq) and
          NaiveDateTime.diff(right_node.start_time, left_node.end_time, :hour) <= 24
    end
    |> tap(
      &Logger.debug("""
      Are nodes #{inspect(left_node, pretty: true)} and
      #{inspect(right_node, pretty: true)} connected?: #{inspect(&1)}
      """)
    )
  end
end
