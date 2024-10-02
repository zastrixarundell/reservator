defmodule Tmpfile do
  @moduledoc """
  Provides functions for generating unique TMP files.
  """

  @doc """
  Generate a unique tmpfile for input. This is expected to run on a Linux
  based system as it utilizes the `mktemp` command.

  This might work on MacOS but not tested.
  """
  @spec create_tmpfile() :: path :: String.t()
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
end
