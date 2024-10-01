defmodule Reservator.Decoder do
  @moduledoc """
  Module which decodes the file input.
  """

  alias Reservator.Reservation.Segment

  require Logger

  def decode_file(file_path) when is_bitstring(file_path) do
    with {:ok, binary} <- read_file(file_path),
         {:ok, start_location, segments} <- deserialize(binary) do
      {:ok, start_location, segments}
    else
      {:error, err} ->
        {:error, err}
    end
  end

  defp deserialize(content) do
    with [_match, start_location] <- Regex.run(~r/BASED: (.*?)$/m, content),
         {:ok, segments} <- Segment.deserialize_segment(content) do
      Logger.debug("Scanned starting location as: #{inspect(start_location)}")
      Logger.debug("Scanned #{length(segments)} elements.")
      {:ok, start_location, segments}
    else
      _ ->
        {:error, :deserialization_failed}
    end
  end

  defp read_file(file_path) do
    with {:file_check, true} <- {:file_check, File.exists?(file_path)},
         {:ok, binary} <- File.read(file_path) do
      Logger.debug("Binary read file #{inspect(file_path)} successfuly.")
      {:ok, binary}
    else
      {:file_check, false} ->
        {:error, :file_not_found}

      _ ->
        {:error, :file_read_error}
    end
  end
end