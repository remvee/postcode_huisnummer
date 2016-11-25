require Ecto.Query

defmodule PostcodeHuisnummer do
  use Application

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec

    # Define workers and child supervisors to be supervised
    children = [
      # Start the Ecto repository
      supervisor(PostcodeHuisnummer.Repo, []),
      # Start the endpoint when the application starts
      supervisor(PostcodeHuisnummer.Endpoint, []),
      # Start your own worker by calling: PostcodeHuisnummer.Worker.start_link(arg1, arg2, arg3)
      # worker(PostcodeHuisnummer.Worker, [arg1, arg2, arg3]),
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: PostcodeHuisnummer.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    PostcodeHuisnummer.Endpoint.config_change(changed, removed)
    :ok
  end

#  @bag_zip_url 'http://localhost/~me/bag.zip'
  @bag_zip_url 'http://data.nlextract.nl/bag/csv/bag-adressen-laatst.csv.zip'

  def import_bag do
    begin_time = :calendar.local_time

    to_bool = fn "f" -> false; "t" -> true end
    to_int = fn x -> String.to_integer(x) end
    to_float = fn x -> Float.parse(x) |> elem(0) end

    {:ok, _} = PostcodeHuisnummer.Repo.query("TRUNCATE TABLE bagadressen_tmp")

    stream_http(@bag_zip_url)
    |> unzip_single_file_stream
    |> split_lines_stream
    |> CSV.Decoder.decode(separator: ?;, headers: true)
    |> Stream.map(fn rec ->
      rec
      |> Map.update!("huisnummer", to_int)
      |> Map.update!("object_id", to_int)
      |> Map.update!("x", to_float)
      |> Map.update!("y", to_float)
      |> Map.update!("lat", to_float)
      |> Map.update!("lon", to_float)
      |> Map.update!("nevenadres", to_bool)
    end)
    |> Stream.chunk(1000, 1000, [])
    |> Stream.each(fn recs ->
      PostcodeHuisnummer.Repo.insert_all("bagadressen_tmp", recs)
    end)
    |> Stream.run

    PostcodeHuisnummer.Repo.transaction(fn ->
      {:ok, _} = PostcodeHuisnummer.Repo.query("ALTER TABLE bagadressen RENAME TO bagadressen_old")
      {:ok, _} = PostcodeHuisnummer.Repo.query("TRUNCATE TABLE bagadressen_old")
      {:ok, _} = PostcodeHuisnummer.Repo.query("ALTER TABLE bagadressen_tmp RENAME TO bagadressen")
      {:ok, _} = PostcodeHuisnummer.Repo.query("ALTER TABLE bagadressen_old RENAME TO bagadressen_tmp")
    end)

    :calendar.time_difference(begin_time, :calendar.local_time)
  end

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

  def split_lines_stream(stream) do
    Stream.transform(
      stream,
      "",
      fn chunk, rest ->
        lines = String.split(rest <> chunk, "\n")
        {Enum.take(lines, Enum.count(lines) - 1), Enum.at(lines, -1)}
      end
    )
  end
end
