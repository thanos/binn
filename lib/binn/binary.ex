defmodule Binn.Binary do
    @moduledoc """
    A struct to represent the Binn [Binary
    type](https://github.com/liteserver/binn#data-types).
    Elixir binaries are serialized and de-serialized as [Binn
    strings](https://github.com/liteserver/binn#data-types):
    `Binn.Binary` is used when you want to enforce the serialization of a binary
    into the Binary Binn type. De-serialization functions (such as
    `Binn.decode/2`) provide an option to deserialize Binary terms (which are
    de-serialized to Elixir binaries by default) to `Binn.Binary` structs.
    """
  
    @type t :: %__MODULE__{
      data: binary,
    }
  
    defstruct [:data]
  
    @doc """
    Creates a new `Binn.Binary` struct from the given binary.
    ## Examples
        iex> Binn.Binary.new("foo")
        #Binn.Binary<"foo">
    """
    def new(data) when is_binary(data) do
      %__MODULE__{data: data}
    end
  
    defimpl Inspect do
      import Inspect.Algebra
  
      def inspect(%{data: data}, opts) do
        concat ["#Binn.Binary<", Inspect.BitString.inspect(data, opts), ">"]
      end
    end
  end
  