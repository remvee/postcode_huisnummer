defmodule ChunkyStreams do
  @doc """
  Emit a HTTP GET request as a chunked stream.
  """
  def stream_http(url) do
    Stream.resource(
      fn ->
        {:ok, id} = :httpc.request(:get, {url, []}, [], [{:stream, :self}, {:sync, false}])
        id
      end,
      fn id ->
        receive do
          {:http, {^id, :stream_start, _}} ->
            {[], id}
          {:http, {^id, :stream, data}} ->
            {[data], id}
          {:http, {^id, :stream_end, _}} ->
            {:halt, id}
        end
      end,
      fn id ->
        :httpc.cancel_request(id)
      end
    )
  end

  @doc """
  Decode a chunky gzipped stream into a decoded chunky stream.
  """
  def gunzip_stream(stream) do
    Stream.transform(
      stream,
      fn ->
        z = :zlib.open()
        # http://stackoverflow.com/questions/1838699/how-can-i-decompress-a-gzip-stream-with-zlib
        :zlib.inflateInit(z, 31)
        :zlib.setBufSize(z, 512 * 1024)
        z
      end,
      fn data, z -> {[doInflateChunk(z, :zlib.inflateChunk(z, data))], z} end,
      fn z -> :zlib.close(z) end
    )
  end

  @doc """
  Extract a zip file from a chunky stream.  Only a single file is expected in the zip file.
  """
  def unzip_single_file_stream(stream) do
    Stream.transform(
      stream,
      fn ->
        z = :zlib.open()
        :zlib.inflateInit(z, -15)
        {z, {:header, <<>>}}
      end,
      fn
        (data, {z, :data, rest}) ->
          {[doInflateChunk(z, :zlib.inflateChunk(z, rest <> data))], {z, :data}}
        (data, {z, :data}) ->
          {[doInflateChunk(z, :zlib.inflateChunk(z, data))], {z, :data}}
        (data, {z, {:header, header}}) ->
          case header <> data do
            <<0x50,0x4b,0x03,0x04,_::32,8::16-little,_::128,
              n::16-little,e::16-little,_::binary-size(n),_::binary-size(e),
              rest::binary>> -> {[], {z, :data, rest}}
            _ -> {[], {z, {:header, header <> data}}}
          end
      end,
      fn {z, _} -> :zlib.close(z) end
    )
  end

  defp doInflateChunk(z, {:more, chunk}), do: chunk <> doInflateChunk(z, :zlib.inflateChunk(z))
  defp doInflateChunk(_, chunk), do: chunk

  @doc """
  Transform a chunked text stream into a stream of lines.
  """
  def split_lines_stream(stream) do
    Stream.transform(
      stream,
      "",
      fn chunk, rest ->
        lines = String.split(rest <> chunk, "\n")
        {Enum.take(lines, Enum.count(lines) - 1), Enum.at(lines, -1, "")}
      end
    )
  end
end
