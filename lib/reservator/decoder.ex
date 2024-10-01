defmodule Reservator.Decoder do
  @moduledoc """
  Module which decodes the file input.
  """

  require Logger

  def decode_file(file_path) when is_bitstring(file_path) do
    with {:ok, binary} <- read_file(file_path) do
      {:ok, binary}
    else
      {:error, err} ->
        Logger.error("Error while reading file: #{inspect(err)}")
        {:error, err}
    end
  end

  defp read_file(file_path) do
    with {:file_check, true} <- {:file_check, File.exists?(file_path)},
         {:ok, binary} <- File.read(file_path) do
      {:ok, binary}
    else
      {:file_check, false} ->
        {:error, :file_not_found}

      _ ->
        {:error, :file_read_error}
    end
  end
end