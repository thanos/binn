# Binn

[![Build Status](https://travis-ci.org/thanos/binn.svg?branch=master)](https://travis-ci.org/thanos/binn)


Binn is a computer data serialization format used mainly for application data transfer. It stores primitive data types and data structures in a binary form. For the full spec see http://github.com/liteserver/binn

Elixir Types | Binn 
-------------:|------
1          # integer | integer
1.0        # float  | floating point numbers (IEEE single and double precision)
true       # boolean | boolean (true and false)
:atom      # atom / symbol | string
"elixir"   # string | string
[1, 2, 3]  # list | list
{1, 2, 3}  # tuple | list
%{:a => 1, :b => 2} # map | object,  where all keys are cast to string 
%{1 => :a, 2 => :b} # map | map, if the Elixir map's keys are all integer
%{:a => 1, 2 => :b} # map | object, where all keys are cast to string



The `Binn` format is designed to be compact and fast on readings. The elements are stored with their sizes to increase the read performance. The strings are null terminated so when read the library returns a pointer to them inside the buffer, avoiding memory allocation and data copying, an operation known as zero-copy.

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


## Encoding

```elixir
iex(1)> %{hello: "world", number: 123} |> Binn.encode
<<226, 22, 2, 2, 105, 100, 32, 12, 5, 104, 101, 108, 108, 111, 160, 5, 119, 111, 114, 108, 100, 0>>
```

## elixir

```elixir
iex(3)> data |> Binn.decode
%{hello: "world", number: 123}
```

Undefined
---------

The `undefined` value is enconded using the byte 0x03.

It is an extended type derived from the storage type NOBYTES.
