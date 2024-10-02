defmodule PathCalculatorTest do
  alias Reservator.PathCalculator

  use ExUnit.Case

  doctest PathCalculator

  describe "gives the correct connection path" do
    test "with no unexpected remainder" do
      {:ok, location, input_data} = DataMock.data(:just_read)

      output_data = DataMock.data(:calculated_no_remainder)

      assert PathCalculator.calculate_path(location, input_data |> Enum.shuffle()) == output_data
    end

    test "with expected remainder" do
      {:ok, location, input_data} = DataMock.data(:just_read_remainder)

      output_data = DataMock.data(:calculated_remainder)

      assert PathCalculator.calculate_path(location, input_data |> Enum.shuffle()) == output_data
    end
  end
end
