defmodule Reservator.Decoder do
  @moduledoc """
  Module which decodes the file input.
  """

  alias Reservator.Reservation.Segment

  require Logger

  @location_regex ~r/^BASED: (?<base>[A-Z]{3})$/m

  @doc """
  Decodes the input file into usable information.

  ## Examples

      iex> Reservator.Decoder.read_file("input.txt")
      {
        :ok,
        \"\"\"
        BASED: SVQ

        RESERVATION
        SEGMENT: Flight SVQ 2023-03-02 06:40 -> BCN 09:10
        \"\"\"
      }
  """
  @spec read_file(file_path :: String.t())  :: {:ok, String.t()} | {:error, :enoent | :eacces | :eisdir | :enotdir | :enomem}
  def read_file(file_path) when is_binary(file_path) do
    with {:ok, binary} <- File.read(file_path) do
      Logger.debug("File #{inspect(file_path)} read successfuly.")
      {:ok, binary}
    end
  end

  @doc """
  Decode the input content properly. Returns a 3 element tuple if okay:

  * `:ok`
  * `start_location` - the based field.
  * `segments` list of segments read from the file.

  ## Examples

      iex> Reservator.Decoder.decode_content(
      ...>   \"\"\"
      ...>   BASED: SVQ
      ...>
      ...>   RESERVATION
      ...>   SEGMENT: Flight SVQ 2023-03-02 06:40 -> BCN 09:10
      ...>
      ...>   RESERVATION
      ...>   SEGMENT: Hotel BCN 2023-01-05 -> 2023-01-10
      ...>   \"\"\"
      ...> )
      {
        :ok,
        "SVQ",
        [
          %Reservator.Reservation.Segment{
            segment_type: "Flight",
            start_time: ~N[2023-03-02 06:40:00],
            start_location: "SVQ",
            end_time: ~N[2023-03-02 09:10:00],
            end_location: "BCN"
          },
          %Reservator.Reservation.Segment{
            segment_type: "Hotel",
            start_time: ~N[2023-01-05 00:00:00],
            start_location: "BCN",
            end_time: ~N[2023-01-10 00:00:00],
            end_location: "BCN"
          }
        ]
      }
  """
  @spec decode_content(String.t()) ::
          {:ok, String.t(), list(Segment.t())}
          | {:error, :deserialization_failed | :no_start_location}
  def decode_content(file_content) when is_binary(file_content) do
    with {:ok, start_location} <- start_location(file_content),
         {:ok, segments} <- Segment.deserialize_segments(file_content) do
      Logger.debug("Deserialized #{length(segments)} segments")
      {:ok, start_location, segments}
    end
  end

  @doc """
  Find the first instance of `BASED: ([A-Z]{3})`.

  ## Examples

      iex> Reservator.Decoder.start_location("BASED: SVQ")
      {:ok, "SVQ"}
      
      iex> Reservator.Decoder.start_location("BASED: SVQA")
      {:error, :no_start_location}
      
  """
  @spec start_location(content :: String.t()) :: {:ok, String.t()} | {:error, :no_start_location}
  def start_location(content) when is_binary(content) do
    case Regex.named_captures(@location_regex, content) do
      %{"base" => start_location} ->
        {:ok, start_location}

      _ ->
        {:error, :no_start_location}
    end
  end
end
