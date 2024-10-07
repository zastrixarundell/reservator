defmodule Reservator do
  @moduledoc """
  A technical, test, elixir application.

  This is an app for the showcase of technical experience.

  This is primarily meant to used directly in the CLI.

  To start the application run:

      mix reservator
    
  In case a custom input file is required, run:application

      mix reservator custom_input.txt
    
  Where the input path can be either relative or absolute.
  """

  alias Reservator.{Decoder, Encoder, PathCalculator}
  alias Reservator.Reservation.Segment

  @doc """
  Main entryoint to the application. Launch it via the `input_file` argument and it should
  read the file, connect all of the segments and display them in the expected order.
  """
  @spec main(input_file :: String.t()) ::
          :ok
          | {:error,
             :enoent
             | :eacces
             | :eisdir
             | :enotdir
             | :enomem
             | :deserialization_failed
             | :no_start_location}
          | {list(Segment.t()), list(Segment.t())}
  def main(input_file) do
    with {:ok, content} <- Decoder.read_file(input_file),
         {:ok, start_location, segments} <- Decoder.decode_content(content),
         {calculated_paths, []} <- PathCalculator.calculate_path(start_location, segments) do
      Encoder.convert_to_string(start_location, calculated_paths)
      |> Kernel.<>("\n")
      |> IO.write()
    end
  end
end
