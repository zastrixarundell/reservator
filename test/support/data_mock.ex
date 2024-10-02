defmodule DataMock do
  def data(:just_read) do
    {
      :ok,
      "SVQ",
      [
        [
          %Reservator.Reservation.Segment{
            segment_type: "Flight",
            start_time: ~N[2023-03-02 06:40:00],
            start_location: "SVQ",
            end_time: ~N[2023-03-02 09:10:00],
            end_location: "BCN"
          }
        ],
        [
          %Reservator.Reservation.Segment{
            segment_type: "Hotel",
            start_time: ~N[2023-01-05 00:00:00],
            start_location: "BCN",
            end_time: ~N[2023-01-10 00:00:00],
            end_location: "BCN"
          }
        ],
        [
          %Reservator.Reservation.Segment{
            segment_type: "Flight",
            start_time: ~N[2023-01-05 20:40:00],
            start_location: "SVQ",
            end_time: ~N[2023-01-05 22:10:00],
            end_location: "BCN"
          },
          %Reservator.Reservation.Segment{
            segment_type: "Flight",
            start_time: ~N[2023-01-10 10:30:00],
            start_location: "BCN",
            end_time: ~N[2023-01-10 11:50:00],
            end_location: "SVQ"
          }
        ],
        [
          %Reservator.Reservation.Segment{
            segment_type: "Train",
            start_time: ~N[2023-02-15 09:30:00],
            start_location: "SVQ",
            end_time: ~N[2023-02-15 11:00:00],
            end_location: "MAD"
          },
          %Reservator.Reservation.Segment{
            segment_type: "Train",
            start_time: ~N[2023-02-17 17:00:00],
            start_location: "MAD",
            end_time: ~N[2023-02-17 19:30:00],
            end_location: "SVQ"
          }
        ],
        [
          %Reservator.Reservation.Segment{
            segment_type: "Hotel",
            start_time: ~N[2023-02-15 00:00:00],
            start_location: "MAD",
            end_time: ~N[2023-02-17 00:00:00],
            end_location: "MAD"
          }
        ],
        [
          %Reservator.Reservation.Segment{
            segment_type: "Flight",
            start_time: ~N[2023-03-02 15:00:00],
            start_location: "BCN",
            end_time: ~N[2023-03-02 22:45:00],
            end_location: "NYC"
          },
          %Reservator.Reservation.Segment{
            segment_type: "Flight",
            start_time: ~N[2023-03-06 08:00:00],
            start_location: "NYC",
            end_time: ~N[2023-03-06 09:25:00],
            end_location: "BOS"
          }
        ]
      ]
    }
  end

  def data(:calculated_no_remainder) do
    {
      [
        [
          %Reservator.Reservation.Segment{
            segment_type: "Flight",
            start_time: ~N[2023-01-05 20:40:00],
            start_location: "SVQ",
            end_time: ~N[2023-01-05 22:10:00],
            end_location: "BCN"
          },
          %Reservator.Reservation.Segment{
            segment_type: "Hotel",
            start_time: ~N[2023-01-05 00:00:00],
            start_location: "BCN",
            end_time: ~N[2023-01-10 00:00:00],
            end_location: "BCN"
          },
          %Reservator.Reservation.Segment{
            segment_type: "Flight",
            start_time: ~N[2023-01-10 10:30:00],
            start_location: "BCN",
            end_time: ~N[2023-01-10 11:50:00],
            end_location: "SVQ"
          }
        ],
        [
          %Reservator.Reservation.Segment{
            segment_type: "Train",
            start_time: ~N[2023-02-15 09:30:00],
            start_location: "SVQ",
            end_time: ~N[2023-02-15 11:00:00],
            end_location: "MAD"
          },
          %Reservator.Reservation.Segment{
            segment_type: "Hotel",
            start_time: ~N[2023-02-15 00:00:00],
            start_location: "MAD",
            end_time: ~N[2023-02-17 00:00:00],
            end_location: "MAD"
          },
          %Reservator.Reservation.Segment{
            segment_type: "Train",
            start_time: ~N[2023-02-17 17:00:00],
            start_location: "MAD",
            end_time: ~N[2023-02-17 19:30:00],
            end_location: "SVQ"
          }
        ],
        [
          %Reservator.Reservation.Segment{
            segment_type: "Flight",
            start_time: ~N[2023-03-02 06:40:00],
            start_location: "SVQ",
            end_time: ~N[2023-03-02 09:10:00],
            end_location: "BCN"
          },
          %Reservator.Reservation.Segment{
            segment_type: "Flight",
            start_time: ~N[2023-03-02 15:00:00],
            start_location: "BCN",
            end_time: ~N[2023-03-02 22:45:00],
            end_location: "NYC"
          },
          %Reservator.Reservation.Segment{
            segment_type: "Flight",
            start_time: ~N[2023-03-06 08:00:00],
            start_location: "NYC",
            end_time: ~N[2023-03-06 09:25:00],
            end_location: "BOS"
          }
        ]
      ],
      []
    }
  end

  def data(:just_read_remainder) do
    {
      :ok,
      "SVQ",
      [
        [
          %Reservator.Reservation.Segment{
            segment_type: "Flight",
            start_time: ~N[2023-03-02 06:40:00],
            start_location: "SVQ",
            end_time: ~N[2023-03-02 09:10:00],
            end_location: "BCN"
          }
        ],
        [
          %Reservator.Reservation.Segment{
            segment_type: "Hotel",
            start_time: ~N[2023-01-05 00:00:00],
            start_location: "BCN",
            end_time: ~N[2023-01-10 00:00:00],
            end_location: "BCN"
          }
        ],
        [
          %Reservator.Reservation.Segment{
            segment_type: "Flight",
            start_time: ~N[2023-01-05 20:40:00],
            start_location: "SVQ",
            end_time: ~N[2023-01-05 22:10:00],
            end_location: "BCN"
          },
          %Reservator.Reservation.Segment{
            segment_type: "Flight",
            start_time: ~N[2023-01-10 10:30:00],
            start_location: "BCN",
            end_time: ~N[2023-01-10 11:50:00],
            end_location: "SVQ"
          }
        ],
        [
          %Reservator.Reservation.Segment{
            segment_type: "Train",
            start_time: ~N[2023-02-15 09:30:00],
            start_location: "SVQ",
            end_time: ~N[2023-02-15 11:00:00],
            end_location: "MAD"
          },
          %Reservator.Reservation.Segment{
            segment_type: "Train",
            start_time: ~N[2023-02-17 17:00:00],
            start_location: "MAD",
            end_time: ~N[2023-02-17 19:30:00],
            end_location: "SVQ"
          }
        ],
        [
          %Reservator.Reservation.Segment{
            segment_type: "Hotel",
            start_time: ~N[2023-02-15 00:00:00],
            start_location: "MAD",
            end_time: ~N[2023-02-17 00:00:00],
            end_location: "MAD"
          }
        ],
        [
          %Reservator.Reservation.Segment{
            segment_type: "Flight",
            start_time: ~N[2023-03-06 08:00:00],
            start_location: "NYC",
            end_time: ~N[2023-03-06 09:25:00],
            end_location: "BOS"
          }
        ]
      ]
    }
  end

  def data(:calculated_remainder) do
    {
      [
        [
          %Reservator.Reservation.Segment{
            segment_type: "Flight",
            start_time: ~N[2023-01-05 20:40:00],
            start_location: "SVQ",
            end_time: ~N[2023-01-05 22:10:00],
            end_location: "BCN"
          },
          %Reservator.Reservation.Segment{
            segment_type: "Hotel",
            start_time: ~N[2023-01-05 00:00:00],
            start_location: "BCN",
            end_time: ~N[2023-01-10 00:00:00],
            end_location: "BCN"
          },
          %Reservator.Reservation.Segment{
            segment_type: "Flight",
            start_time: ~N[2023-01-10 10:30:00],
            start_location: "BCN",
            end_time: ~N[2023-01-10 11:50:00],
            end_location: "SVQ"
          }
        ],
        [
          %Reservator.Reservation.Segment{
            segment_type: "Train",
            start_time: ~N[2023-02-15 09:30:00],
            start_location: "SVQ",
            end_time: ~N[2023-02-15 11:00:00],
            end_location: "MAD"
          },
          %Reservator.Reservation.Segment{
            segment_type: "Hotel",
            start_time: ~N[2023-02-15 00:00:00],
            start_location: "MAD",
            end_time: ~N[2023-02-17 00:00:00],
            end_location: "MAD"
          },
          %Reservator.Reservation.Segment{
            segment_type: "Train",
            start_time: ~N[2023-02-17 17:00:00],
            start_location: "MAD",
            end_time: ~N[2023-02-17 19:30:00],
            end_location: "SVQ"
          }
        ],
        [
          %Reservator.Reservation.Segment{
            segment_type: "Flight",
            start_time: ~N[2023-03-02 06:40:00],
            start_location: "SVQ",
            end_time: ~N[2023-03-02 09:10:00],
            end_location: "BCN"
          }
        ]
      ],
      [
        [
          %Reservator.Reservation.Segment{
            segment_type: "Flight",
            start_time: ~N[2023-03-06 08:00:00],
            start_location: "NYC",
            end_time: ~N[2023-03-06 09:25:00],
            end_location: "BOS"
          }
        ]
      ]
    }
  end
end
