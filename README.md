# Reservator

A technical, test, elixir application.

![with tests badge](https://img.shields.io/badge/With-ExUnit%20tests!-8A2BE2)

## Requirements

The application is designed with [asdf](https://asdf-vm.com/) first in mind.

Setup asdf by following the instruction guide [here](https://asdf-vm.com/guide/getting-started.html).

After that, install elixir and erlang:

```bash
asdf plugin add elixir
asdf plugin add erlang
asdf install
```

## Testing

There's not much setup to do for testing except for the requirement of using a system which has `mktemp` and runs an OS of the UNIX family (has `/tmp` folder).

To start the tests, run:

```bash
mix test
```

> Not really a requirement, but you can run `mix credo` to check the application syntax during the development cycle.
