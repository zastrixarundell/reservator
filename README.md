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

## Assumptions

The document regarding assumptions is displayed [here](./ASSUMPTIONS.md).

## Testing

There's not much setup to do for testing except for the requirement of using a system which has `mktemp` and runs an OS of the UNIX family (has `/tmp` folder).

To start the tests, run:

```bash
mix test
```

> [!TIP]
> You can run `mix credo` to check the application syntax during the development cycle.

## Running

To start the application, simply run:

```bash
mix reservator
```

This will try to read the file `input.txt` inside of the root directory. If no such file is present it will give an error and gracefully stop.

In case a custom file should be read, you may run:

```bash
mix reservator my_custom_file.txt
```

Where the path can be either relative or absolute.

Alternatively, if you want to use the provided OCI image, you can use that as well.

For this example we'll use `podman` and `podman-compose`:

```bash
podman-compose up
```

This is considering that the `input.txt` file is present in the current container build directory.

> [!TIP]
> Docker should work just fine as podman is a replacement for docker.

> [!NOTE]
> I've decided to opt-in for containers, just so that the time for trying out this app would be lowered... considerably...