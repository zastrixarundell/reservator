defmodule DecoderTest do
  use ExUnit.Case

  require Logger

  import Tmpfile

  alias Reservator.Decoder

  doctest Decoder

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

  # Tests

  describe "when valid file" do
    test "file is deserialized", %{file_path: path} do
      {:ok, start_location, content} = Decoder.decode_file(path)

      assert start_location == "SVQ"

      assert length(content) == 6
    end
  end

  describe "when invalid file" do
    @tag type: :invalid
    test "file is not deserialized", %{file_path: path} do
      assert {:error, :deserialization_failed} = Decoder.decode_file(path)
    end
  end
end
