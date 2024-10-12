defmodule Mix.Tasks.Reservator do
  @moduledoc """
  Start the reservator application
  """

  use Mix.Task

  @doc """
  Start the reservator application. If no file path is defined `input.txt` will be assumed.
  """
  @spec run(list(String.t())) :: :ok | no_return()
  def run(args) do
    Mix.Task.run("app.start")

    input_file = args |> List.first("input.txt")

    case Reservator.main(input_file) do
      :ok ->
        :ok

      {:error, :enoent} ->
        IO.puts(:stderr, "File #{input_file} not found.")
        System.halt(1)

      {:error, :eacces} ->
        IO.puts(:stderr, "Unable to read file #{input_file}. Insufficient permissions?")
        System.halt(2)

      {:error, :enotdir} ->
        IO.puts(:stderr, "Unable to read file #{input_file}. Is a directory.")
        System.halt(3)

      {:error, :enomem} ->
        IO.puts(:stderr, "Unable to read file #{input_file}. File is too large.")
        System.halt(4)

      {:error, :no_start_location} ->
        IO.puts(:stderr, "`BASED:` not defined!")
        System.halt(5)

      {:error, :deserialization_failed} ->
        IO.puts(:stderr, "Failed to generally deserialize. Is it malformed?")
        System.halt(6)

      {_, failed_segments} when is_list(failed_segments) ->
        translated_failed_segments =
          failed_segments
          |> List.flatten()
          |> Enum.map_join(", ", &to_string/1)

        IO.puts(
          :stderr,
          "[#{translated_failed_segments}] are not connected, please check the files!"
        )

        System.halt(7)
    end
  end
end
