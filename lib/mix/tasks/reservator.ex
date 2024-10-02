defmodule Mix.Tasks.Reservator do
  @moduledoc """
  Start the reservator application
  """

  use Mix.Task

  @doc """
  Start the reservator application. It no `--file` argument is defined,
  `input.txt` will be implied.
  """
  @spec run(list(String.t())) :: :ok | no_return()
  def run(args) do
    Mix.Task.run("app.start")

    input_file = args |> List.first("input.txt")

    with {:ok, starting_location, segments} <- Reservator.Decoder.decode_file(input_file),
         {calculated_paths, []} <-
           Reservator.PathCalculator.calculate_path(starting_location, segments),
         final_result <- Reservator.Encoder.convert_to_string(starting_location, calculated_paths) do
      IO.puts(final_result)
    else
      {:error, :file_not_found} ->
        IO.puts(:stderr, "File #{input_file} not found.")
        System.halt(1)

      {:error, :file_read_error} ->
        IO.puts(:stderr, "Unable to read file #{input_file}. Insufficient permissions?")
        System.halt(2)

      {:error, :no_start_location} ->
        IO.puts(:stderr, "`BASED:` not defined!")
        System.halt(3)

      {:error, :deserialization_failed} ->
        IO.puts(:stderr, "Failed to generally deserialize. Is it malformed?")
        System.halt(4)

      {_, failed_segments} when is_list(failed_segments) ->
        translated_failed_segments =
          failed_segments
          |> List.flatten()
          |> Enum.map_join(", ", &to_string/1)

        IO.puts(
          :stderr,
          "[#{translated_failed_segments}] are not connected, please check the files!"
        )

        System.halt(5)
    end
  end
end
