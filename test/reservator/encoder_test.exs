defmodule EncoderTest do
  use ExUnit.Case

  require Logger

  alias Reservator.Encoder

  doctest Encoder

  # Tests

  test "when valid file" do
    {input_data, []} = DataMock.data(:calculated_no_remainder)

    assert Encoder.convert_to_string("SVQ", input_data) == OutputMock.expected()
  end
end
