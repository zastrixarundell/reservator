defmodule DecoderTest do
  alias Reservator.Decoder

  use ExUnit.Case

  doctest Decoder

  require Logger

  # Setup process

  setup tags do
    type = tags[:type] || :valid

    with {:ok, path} <- create_tmpfile(),
         content <- InputMock.input_file(type),
         :ok <- File.write(path, content, [:write]) do

      on_exit(fn -> File.rm(path) end)

      {
        :ok,
        file_content: InputMock.input_file(type),
        file_path: path
      }
    else
      {:error, :tmpdir_fail} ->
        Logger.error("Failed to create context for DecoderTest")
        :error

      {:error, :tmpfile_fail} ->
        Logger.error("Failed to create tmpfile inside of /tmp/reservator")
        :error

      {:error, _} ->
        Logger.error("Failed to write into file")
        :error
    end
  end

  def create_tmpfile() do
    context_path = "/tmp/reservator"

    with :ok <- File.mkdir_p(context_path),
         # Why invent hot water / a complex setup, just use UNIX's mktemp
         {path, 0} <- System.cmd("mktemp", ["#{context_path}/input.txt.XXXXXXXXXX"]),
         path <- String.trim(path) do
      {:ok, path}
    else
      {_, value} when is_integer(value) ->
        {:error, :tmpfile_fail}

      {:error, _} ->
        {:error, :tmpdir_fail}
    end
  end

  # Tests

  describe "when valid file" do
    test "file is deserialized", %{file_path: path} do
      {:ok, start_location, content} = Decoder.decode_file(path)

      assert start_location == "SVQ"

      assert length(content) == 9

      assert content |> Enum.at(0) |> Map.get(:segment_type) == "Flight"
      assert content |> Enum.at(8) |> Map.get(:end_location) == "BOS"
    end
  end

  describe "when invalid file" do
    @tag type: :invalid
    test "file is not deserialized", %{file_path: path} do
      assert {:error, :deserialization_failed} = Decoder.decode_file(path)
    end
  end
end
