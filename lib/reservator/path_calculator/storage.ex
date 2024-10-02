defmodule Reservator.PathCalculator.Storage do
  @moduledoc """
  Responsible for storing memory information about the current path routes.

  Easier to manage in a seperate process than to jump hoops with fancy enum logic.
  """

  use Agent

  alias Reservator.Reservation.Segment

  def start_link(travel_nodes) do
    Agent.start_link(fn -> travel_nodes end)
  end

  @doc """
  List all of the available paths.
  """
  @spec list_paths(pid()) :: list(list(Segment.t()))
  def list_paths(pid) do
    Agent.get(pid, &(&1))
  end

  @doc """
  Remove first exactly matching node from node list.
  """
  @spec remove_node(pid(), node_path :: list(Segment.t())) :: :ok
  def remove_node(pid, node_path) do
    Agent.update(pid, fn nodes ->
      index = Enum.find_index(nodes, &Kernel.==(&1, node_path))

      case index do
        nil ->
          nodes

        _ ->
          List.delete_at(nodes, index)
      end
    end)
  end
end
