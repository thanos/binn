defmodule Binn.UserType do
    @moduledoc """
    A struct used to represent the Binn [UserType
    type](https://github.com/liteserver/binn#data-types).
    ## Examples
    Let's say we want to be able to serialize a custom type that consists of a
    byte `data` repeated `reps` times. We could represent this as a `RepByte`
    struct in Elixir:
        defmodule RepByte do
          defstruct [:data, :reps]
        end
    A simple (albeit not space efficient) approach to encoding such data is simply
    a binary containing `data` for `reps` times: `%RepByte{data: ?a, reps: 2}`
    would be encoded as `"aa"`.
    We can now define the `Binn.Encoder` protocol for the `RepByte` struct to
    tell `Binn` how to encode this struct (we'll choose `10` as an arbitrary
    integer to identify the type of this user type).
        defimpl Binn.Encoder, for: RepByte do
          def encode(%RepByte{data: b, reps: reps}) do
            Binn.UserType.new(10, String.duplicate(<<b>>, reps))
            |> Binn.Encoder.encode()
          end
        end
    Now, we can encode `RepByte`s:
        iex> packed = Binn.encode!(%RepByte{data: ?a, reps: 3})
        iex> Binn.decode!(packed)
        #Binn.UserType<10, "aaa">
    ### Unpacking
    As seen in the example above, since the `RepByte` struct is *packed* as a
    Binn user type, it will be unpacked as that user type later on; what we
    may want, however, is to decode that user type back to a `RepByte` struct.
    To do this, we can pass an `:ext` option to `Binn.decode/2` (and other
    unpacking functions). This option has to be a module that implements the
    `Binn.UserType.Decoder` behaviour; it will be used to decode extensions to
    arbitrary Elixir terms.
    For our `RepByte` example, we could create an unpacker module like this:
        defmodule MyUserTypeDecoder do
          @behaviour Binn.UserType.Decoder
          @rep_byte_user_type 10
          def decode(%Binn.UserType{type: @rep_byte_user_type, data: data}) do
            <<byte, _rest::binary>> = data
            {:ok, %RepByte{data: byte, reps: byte_size(data)}}
          end
        end
    With this in place, we can now decode a packed `RepByte` back to a `RepByte`
    struct:
        iex> encoded = Binn.encode!(%RepByte{data: ?a, reps: 3})
        iex> Binn.decode!(encoded, ext: MyUserTypeDecoder)
        %RepByte{data: ?a, reps: 3}
    """
  
    @type type :: 0..127
    @type t :: %__MODULE__{
      type: type,
      data: binary,
    }
  
    defstruct [:type, :data]
  
    @doc """
    Creates a new `Binn.UserType` struct.
    `type` must be an integer in `0..127` and it will be used as the type of the
    user type (whose meaning depends on your application). `data` must be a binary
    containing the serialized user type (whose serialization depends on your
    application).
    ## Examples
        iex> Binn.UserType.new(24, "foo")
        #Binn.UserType<24, "foo">
    """
    def new(type, data)
        when type in 0..127 and is_binary(data) do
      %__MODULE__{type: type, data: data}
    end
  
    defimpl Inspect do
      import Inspect.Algebra
  
      def inspect(%{type: type, data: data}, opts) do
        concat ["#Binn.UserType<",
          Inspect.Integer.inspect(type, opts), ", ",
          Inspect.BitString.inspect(data, opts), ">"]
      end
    end
  end