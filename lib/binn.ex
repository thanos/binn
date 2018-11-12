defmodule Binn do
  @moduledoc ~S"""
  This module provides functions for serializing and de-serializing Elixir terms
  using the [Binn](https://github.com/liteserver/binn/) format.
  ## Data conversion
  The following table shows how Elixir types are serialized to Binn types
  and how Binn types are de-serialized back to Elixir types.
  Elixir                            | Binn   | Elixir
  --------------------------------- | ------------- | -------------
  `nil`                             | nil           | `nil`
  `true`                            | boolean       | `true`
  `false`                           | boolean       | `false`
  `-1`                              | integer       | `-1`
  `1.25`                            | float         | `1.25`
  `:ok`                             | string        | `"ok"`
  `Atom`                            | string        | `"Elixir.Atom"`
  `"str"`                           | string        | `"str"`
  `"\xFF\xFF"`                      | string        | `"\xFF\xFF"`
  `#Binn.Bin<"\xFF">`               | binary        | `"\xFF"`
  `%{foo: "bar"}`                   | object           | `%{"foo" => "bar"}`
  `[foo: "bar"]`                    | object           | `%{"foo" => "bar"}`
  `[1, true]`                       | list         | `[1, true]`
  `#Binn.Ext<4, "02:12">`           | extension     | `#Binn.Ext<4, "02:12">`
  `#DateTime<2017-12-06 00:00:00Z>` | extension     | `#DateTime<2017-12-06 00:00:00Z>`
  """

  alias __MODULE__.Encoder
  alias __MODULE__.Decoder
  
@datetime_format "%Y-%m-%d %H:%M:%S"

# Data Formats
@list 0xE0
@map  0xe1
@object  0xe2 

@string  0xa0
@time  0xa1  # Not used
@datetime 0xa2

@blob  0xc0

@null  0x00
@true  0x01
@false 0x02

@uint8   0x20
@int8    0x21
@uint16  0x40
@int16   0x41
@unit32  0x60
@int32   0x61
@uint64  0x80
@int64   0x81
@float64 0x82

# Extended data formats
@MAP "\xb8"
@MAP_SIZE  8


  @doc """
  Serializes `term`.
  This function returns iodata by default; if you want to force the result to be
  a binary, you can use `IO.iodata_to_binary/1` or use the `:iodata` option (see
  the "Options" section below).
  This function returns `{:ok, iodata}` if the serialization is successful,
  `{:error, exception}` otherwise, where `exception` is a `Binn.EncodeError`
  struct which can be raised or converted to a more human-friendly error
  message with `Exception.message/1`. See `Binn.EncodeError` for all the
  possible reasons for a encoding error.
  ## Options
    * `:iodata` - (boolean) if `true`, this function returns the encoded term as
      iodata, if `false` as a binary. Defaults to `true`.
  ## Examples
      iex> {:ok, encoded} = Binn.encode("foo")
      iex> IO.iodata_to_binary(encoded)
      <<163, 102, 111, 111>>
      iex> Binn.encode(20000000000000000000)
      {:error, %Binn.EncodeError{reason: {:too_big, 20000000000000000000}}}
      iex> Binn.encode("foo", iodata: false)
      {:ok, <<163, 102, 111, 111>>}
  """
  @spec encode(term, Keyword.t) :: {:ok, iodata} | {:error, Binn.EncodeError.t}
  def encode(term, options \\ []) when is_list(options) do
    iodata? = Keyword.get(options, :iodata, true)

    try do
      Encoder.encode(term)
    catch
      :throw, reason ->
        {:error, %Binn.EncodeError{reason: reason}}
    else
      iodata when iodata? ->
        {:ok, iodata}
      iodata ->
        {:ok, IO.iodata_to_binary(iodata)}
    end
  end

  @doc """
  Works as `encode/1`, but raises if there's an error.
  This function works like `encode/1`, except it returns the `term` (instead of
  `{:ok, term}`) if the serialization is successful or raises a
  `Binn.EncodeError` exception otherwise.
  ## Options
  This function accepts the same options as `encode/2`.
  ## Examples
      iex> "foo" |> Binn.encode!() |> IO.iodata_to_binary()
      <<163, 102, 111, 111>>
      iex> Binn.encode!(20000000000000000000)
      ** (Binn.EncodeError) value is too big: 20000000000000000000
      iex> Binn.encode!("foo", iodata: false)
      <<163, 102, 111, 111>>
  """
  @spec encode!(term, Keyword.t) :: iodata | no_return
  def encode!(term, options \\ []) do
    case encode(term, options) do
      {:ok, result} ->
        result
      {:error, exception} ->
        raise exception
    end
  end

  @doc """
  De-serializes part of the given `iodata`.
  This function works like `decode/2`, but instead of requiring the input to be
  a Binn-serialized term with nothing after that, it accepts leftover
  bytes at the end of `iodata` and only de-serializes the part of the input that
  makes sense. It returns `{:ok, term, rest}` if de-serialization is successful,
  `{:error, exception}` otherwise (where `exception` is a `Binn.DecodeError`
  struct).
  See `decode/2` for more information on the supported options.
  ## Examples
      iex> Binn.decode_slice(<<163, "foo", "junk">>)
      {:ok, "foo", "junk"}
      iex> Binn.decode_slice(<<163, "fo">>)
      {:error, %Binn.DecodeError{reason: {:invalid_format, 163}}}
  """
  @spec decode_slice(iodata, Keyword.t) :: {:ok, any, binary} | {:error, Binn.DecodeError.t}
  def decode_slice(iodata, options \\ []) when is_list(options) do
    try do
      iodata
      |> IO.iodata_to_binary()
      |> Decoder.decode(options)
    catch
      :throw, reason ->
        {:error, %Binn.DecodeError{reason: reason}}
    else
      {value, rest} ->
        {:ok, value, rest}
    end
  end

  @doc """
  Works like `decode_slice/2` but raises in case of error.
  This function works like `decode_slice/2`, but returns just `{term, rest}` if
  de-serialization is successful and raises a `Binn.DecodeError` exception if
  it's not.
  ## Examples
      iex> Binn.decode_slice!(<<163, "foo", "junk">>)
      {"foo", "junk"}
      iex> Binn.decode_slice!(<<163, "fo">>)
      ** (Binn.DecodeError) invalid format, first byte: 163
  """
  @spec decode_slice!(iodata, Keyword.t) :: {any, binary} | no_return
  def decode_slice!(iodata, options \\ []) do
    case decode_slice(iodata, options) do
      {:ok, value, rest} ->
        {value, rest}
      {:error, exception} ->
        raise exception
    end
  end

  @doc """
  De-serializes the given `iodata`.
  This function de-serializes the given `iodata` into an Elixir term. It returns
  `{:ok, term}` if the de-serialization is successful, `{:error, exception}`
  otherwise, where `exception` is a `Binn.DecodeError` struct which can be
  raised or converted to a more human-friendly error message with
  `Exception.message/1`. See `Binn.DecodeError` for all the possible reasons
  for an decoding error.
  ## Options
    * `:binary` - (boolean) if `true`, then binaries are decoded as `Binn.Bin`
      structs instead of plain Elixir binaries.
    * `:ext` - (module) a module that implements the `Binn.Ext.Decoder`
      behaviour. For more information, see the docs for `Binn.Ext.Decoder`.
  ## Examples
      iex> Binn.decode(<<163, "foo">>)
      {:ok, "foo"}
      iex> Binn.decode(<<163, "foo", "junk">>)
      {:error, %Binn.DecodeError{reason: {:excess_bytes, "junk"}}}
      iex> encoded = Binn.encode!(Binn.Binary.new(<<3, 18, 122, 27, 115>>))
      iex> {:ok, bin} = Binn.decode(encoded, binary: true)
      iex> bin
      #Binn.Binary<<<3, 18, 122, 27, 115>>>
  """
  @spec decode(iodata, Keyword.t) :: {:ok, any} | {:error, Binn.DecodeError.t}
  def decode(iodata, options \\ []) do
    case decode_slice(iodata, options) do
      {:ok, value, <<>>} ->
        {:ok, value}
      {:ok, _, bytes} ->
        {:error, %Binn.DecodeError{reason: {:excess_bytes, bytes}}}
      {:error, _} = error ->
        error
    end
  end

  @doc """
  Works like `decode/2`, but raises in case of errors.
  This function works like `decode/2`, but it returns `term` (instead of `{:ok,
  term}`) if de-serialization is successful, otherwise raises a
  `Binn.DecodeError` exception.
  ## Example
      iex> Binn.decode!(<<163, "foo">>)
      "foo"
      iex> Binn.decode!(<<163, "foo", "junk">>)
      ** (Binn.DecodeError) found excess bytes: "junk"
      iex> encoded = Binn.encode!(Binn.Binary.new(<<3, 18, 122, 27, 115>>))
      iex> Binn.decode!(encoded, binary: true)
      #Binn.Binary<<<3, 18, 122, 27, 115>>>
  """
  @spec decode!(iodata, Keyword.t) :: any | no_return
  def decode!(iodata, options \\ []) do
    case decode(iodata, options) do
      {:ok, value} ->
        value
      {:error, exception} ->
        raise exception
    end
  end
end
