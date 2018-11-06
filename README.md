# Binn

Binn is a computer data serialization format used mainly for application data transfer. It stores primitive data types and data structures in a binary form. For the full spec see github.com/liteserver/binn

The Binn format is designed to be compact and fast on readings. The elements are stored with their sizes to increase the read performance. The strings are null terminated so when read the library returns a pointer to them inside the buffer, avoiding memory allocation and data copying, an operation known as zero-copy.

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `binn` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:binn, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/binn](https://hexdocs.pm/binn).

