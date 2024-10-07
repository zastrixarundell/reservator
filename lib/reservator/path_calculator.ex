defmodule Reservator.PathCalculator do
  @moduledoc """
  Provides functions to calculate paths for reservations.
  """

  @guess_days 7

  alias Reservator.PathCalculator.Storage
  alias Reservator.Reservation.Segment

  require Logger

  @doc """
  Function for calculating reservation path. Returns a 2-element touple. First element
  would be direction connections. The other element would be segments which aren't connected
  to any other segment within 24 hours. 

  The output is:

    {calculated_paths, skipped_segments}
      
  Calculated paths are the paths which are correctly found and connected. Skipped paths
  are paths which were not able to connect to any of the starting nodes, they are generally
  there due to user misinput.
  """
  @spec calculate_path(String.t(), list(Segment.t())) ::
          {calculated_paths :: list(list(Segment.t())), skipped_segments :: list(Segment.t())}
  def calculate_path(starting_location, segments) when is_binary(starting_location) do
    {start_paths, travel_paths} =
      segments
      # needs to be called, otherwise data can be invalid
      |> sort_nodes()
      |> Enum.split_with(&starting_node?(starting_location, &1))

    {:ok, storage_pid} = Storage.start_link(travel_paths)

    calcualted_paths =
      start_paths
      |> Enum.map(&List.wrap/1)
      |> Enum.map(&build_path(&1, storage_pid))
      # Guess the remainder
      |> Enum.map(&build_path(&1, storage_pid, true))

    {calcualted_paths, Storage.list_paths(storage_pid)}
  end

  @doc """
  Order the nodes so that older start_time is first.

  ## Examples

      iex> Reservator.PathCalculator.sort_nodes(
      ...>   [
      ...>     %Reservator.Reservation.Segment{
      ...>       start_time: ~N[2023-03-06 08:00:00],
      ...>       start_location: "BCN"
      ...>     },
      ...>     %Reservator.Reservation.Segment{
      ...>       start_time: ~N[2023-03-02 15:00:00],
      ...>       start_location: "NYC"
      ...>     }
      ...>   ]
      ...> )
      [
        %Reservator.Reservation.Segment{
          start_time: ~N[2023-03-02 15:00:00],
          start_location: "NYC",
        },
        %Reservator.Reservation.Segment{
          start_time: ~N[2023-03-06 08:00:00],
          start_location: "BCN",
        }
      ]
  """
  @spec sort_nodes(node_list :: list(Segment.t())) :: list(Segment.t())
  def sort_nodes(node_list) do
    node_list
    |> Enum.sort(fn node1, node2 ->
      case NaiveDateTime.compare(node1.start_time, node2.start_time) do
        :gt -> false
        _ -> true
      end
    end)
  end

  @doc """
  Is the current node a starting node, as in is the `location` the same as `segment.start_location`.

  ## Examples

      iex> Reservator.PathCalculator.starting_node?("SVQ", %Reservator.Reservation.Segment{start_location: "SVQ"})
      true
      
      iex> Reservator.PathCalculator.starting_node?("SVQ", %Reservator.Reservation.Segment{start_location: "NYC"})
      false
  """
  @spec starting_node?(String.t(), node :: Segment.t()) :: boolean()
  def starting_node?(location, %Segment{start_location: segment_start})
      when is_binary(location) do
    segment_start == location
  end

  @doc """
  Build the path for the current segment list.

  * `starting_path` is the current path on which it's searched upon.
  * `storage_pid` is the pid of the storage agent.
  * `guess?` is whether to guess a connection or not. A guessed connection is within #{@guess_days} days while a non-guessed is within one day.

  The return value is a list of connected segments.
  """
  @spec build_path(starting_path :: list(Segment.t()), storage_pid :: pid(), guess? :: boolean()) ::
          list(Segment.t())
  def build_path(starting_path, storage_pid, guess? \\ false) do
    # Loop until `{:halt, _}` is called.
    Stream.cycle([nil])
    |> Enum.reduce_while(starting_path, fn _, current_path ->
      last_index = List.last(current_path)

      current_elements = Storage.list_paths(storage_pid)

      case Enum.find(current_elements, &connected_node?(last_index, &1, guess?)) do
        nil ->
          {:halt, current_path}

        value ->
          Storage.remove_node(storage_pid, value)

          {:cont, current_path ++ [value]}
      end
    end)
  end

  @doc """
  Determine whether a node is connected. If `guess?` is set to false, the nodes will only be connected
  if there is a 24 hours differnce between them. If `guess?` is true, it will only be connected if there's
  a week between them.

  ## Examples

      iex> Reservator.PathCalculator.connected_node?(
      ...>   %Reservator.Reservation.Segment{
      ...>     segment_type: "Flight",
      ...>     start_time: ~N[2023-03-02 06:40:00],
      ...>     start_location: "SVQ",
      ...>     end_time: ~N[2023-03-02 09:10:00],
      ...>     end_location: "BCN"
      ...>   },
      ...>   %Reservator.Reservation.Segment{
      ...>     segment_type: "Flight",
      ...>     start_time: ~N[2023-03-02 15:00:00],
      ...>     start_location: "BCN",
      ...>     end_time: ~N[2023-03-02 22:45:00],
      ...>     end_location: "NYC"
      ...>   }
      ...> )
      true
      
      iex> Reservator.PathCalculator.connected_node?(
      ...>   %Reservator.Reservation.Segment{
      ...>     segment_type: "Flight",
      ...>     start_time: ~N[2023-03-02 15:00:00],
      ...>     start_location: "BCN",
      ...>     end_time: ~N[2023-03-02 22:45:00],
      ...>     end_location: "NYC"
      ...>   },
      ...>   %Reservator.Reservation.Segment{
      ...>     segment_type: "Flight",
      ...>     start_time: ~N[2023-03-06 08:00:00],
      ...>     start_location: "NYC",
      ...>     end_time: ~N[2023-03-06 09:25:00],
      ...>     end_location: "BOS"
      ...>   }
      ...> )
      false
      
      iex> Reservator.PathCalculator.connected_node?(
      ...>   %Reservator.Reservation.Segment{
      ...>     segment_type: "Flight",
      ...>     start_time: ~N[2023-03-02 15:00:00],
      ...>     start_location: "BCN",
      ...>     end_time: ~N[2023-03-02 22:45:00],
      ...>     end_location: "NYC"
      ...>   },
      ...>   %Reservator.Reservation.Segment{
      ...>     segment_type: "Flight",
      ...>     start_time: ~N[2023-03-06 08:00:00],
      ...>     start_location: "NYC",
      ...>     end_time: ~N[2023-03-06 09:25:00],
      ...>     end_location: "BOS"
      ...>   },
      ...>   true
      ...> )
      true
    
  """
  @spec connected_node?(left_node :: Segment.t(), right_node :: Segment.t(), guess? :: boolean()) ::
          boolean()
  def connected_node?(%Segment{} = left_node, %Segment{} = right_node, guess? \\ false) do
    {left_time, right_time} =
      case right_node.segment_type do
        "Hotel" ->
          {NaiveDateTime.beginning_of_day(left_node.end_time),
           NaiveDateTime.beginning_of_day(right_node.start_time)}

        _ ->
          {left_node.end_time, right_node.start_time}
      end

    time_difference = NaiveDateTime.diff(right_time, left_time, :day)
    time_compare = NaiveDateTime.compare(right_time, left_time)

    connected? =
      left_node.end_location == right_node.start_location and
        (time_compare == :gt or time_compare == :eq) and
        time_difference <= if guess?, do: @guess_days, else: 1

    connected?
    |> tap(
      &Logger.debug(
        "#{inspect(left_node, pretty: true)} and #{inspect(right_node, pretty: true)} connected?: #{inspect(&1)}"
      )
    )
  end
end
