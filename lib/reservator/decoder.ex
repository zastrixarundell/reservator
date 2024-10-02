defmodule Reservator.Decoder do
  @moduledoc """
  Module which decodes the file input.
  """

  alias Reservator.Reservation.Segment

  require Logger

  @spec decode_file(binary()) ::
          {:error, :deserialization_failed | :file_not_found | :file_read_error | :no_start_Location}
          | {:ok, binary(), list(Segment.t())}
  def decode_file(file_path) when is_bitstring(file_path) do
    with {:ok, binary} <- read_file(file_path),
         {:ok, start_location} <- start_location(binary),
         binary <- split_segment_chunks(binary),
         {:ok, segments} <- deserialize(binary) do
      {:ok, start_location, segments}
    else
      {:error, err} ->
        {:error, err}
    end
  end

  @spec start_location(content :: String.t()) :: {:ok, String.t()} | {:error, :no_start_location}
  defp start_location(content) when is_binary(content) do
    case Regex.run(~r/BASED: (\w{3})$/m, content) do
      [_match, start_location] ->
        {:ok, start_location}

      _ ->
        {:error, :no_start_Location}
    end
  end

  @spec deserialize(content :: list(String.t())) ::
          {:ok, list(list(Segment.t()))}
          | {:error, :deserialization_failed}
  defp deserialize(content) do
    case Segment.deserialize_segments(content) do
      {:ok, segment_cunks} ->
        Logger.debug("Scanned #{length(segment_cunks)} elements.")
        {:ok, segment_cunks}

      _ ->
        {:error, :deserialization_failed}
    end
  end

  @spec read_file(file_path :: String.t()) ::
          {:ok, String.t()} | {:error, :file_not_found} | {:error, :file_read_error}
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

  @spec split_segment_chunks(content :: String.t()) :: list(String.t())
  defp split_segment_chunks(content) do
    content
    |> String.split("RESERVATION")
    |> Enum.drop(1)
  end
end
