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

  def import_bag do
    PostcodeHuisnummer.Repo.delete_all(PostcodeHuisnummer.BagAdres)

    File.stream!('bagadres.csv') |>
      CSV.Decoder.decode(separator: ?;, headers: true) |>
      Stream.map(
        fn rec ->
          rec |>
            Map.update!("huisnummer", fn x -> String.to_integer(x) end) |>
            Map.update!("object_id", fn x -> String.to_integer(x) end) |>
            Map.update!("x", fn x -> Float.parse(x) |> elem(0) end) |>
            Map.update!("y", fn x -> Float.parse(x) |> elem(0) end) |>
            Map.update!("lat", fn x -> Float.parse(x) |> elem(0) end) |>
            Map.update!("lon", fn x -> Float.parse(x) |> elem(0) end) |>
            Map.put("inserted_at", Ecto.DateTime.from_erl(:calendar.universal_time)) |>
            Map.put("updated_at", Ecto.DateTime.from_erl(:calendar.universal_time))
        end) |>
      Stream.map(
        fn rec ->
          for {k, v} <- rec, into: %{}, do: {String.to_atom(k), v}
        end) |>
      Stream.chunk(100) |>
      Stream.each(
        fn recs ->
          PostcodeHuisnummer.Repo.insert_all(PostcodeHuisnummer.BagAdres, recs)
        end) |>
      Stream.run
  end

  def stream_http do
    Stream.resource(
      fn ->
        {:ok, id} = :httpc.request(:get, {'http://localhost/~me/bag.csv.gz', []}, [], [{:stream, :self}, {:sync, false}])
        z = :zlib.open()
        :zlib.inflateInit(z, 16 + 15)
        :zlib.setBufSize(z, 512 * 1024)
        {id, z}
      end,
      fn
        {id, z, :more} ->
          doChunk(id, z, :zlib.inflateChunk(z))
        {id, z} ->
          receive do
          {:http, {^id, :stream_start, x}} ->
            {[], {id, z}}
          {:http, {^id, :stream, data}} ->
            doChunk(id, z, :zlib.inflateChunk(z, data))
          {:http, {^id, :stream_end, _}} ->
            {:halt, {id, z}}
        end
      end,
      fn
        {id, z} ->
          :zlib.close(z)
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

  defp doInflateChunk(z, {:more, chunk}) do
    chunk <> doInflateChunk(z, :zlib.inflateChunk(z))
  end

  defp doInflateChunk(_, chunk) do
    chunk
  end
end
