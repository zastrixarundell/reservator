# Example of mix release with burrito: https://github.com/zastrixarundell/nasa_btt/blob/main/Dockerfile

FROM elixir:1.17.3

WORKDIR /app

COPY . .

# Went with the standard mix route instead of release
# as the latter would just make this more complex without much
# benefits.

ENV MIX_ENV=prod

RUN mix deps.get

RUN mix deps.compile

RUN mix compile

CMD ["/usr/local/bin/mix", "reservator"]
