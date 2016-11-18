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
        {:ok, id} = :httpc.request(:get, {'http://localhost/~me/bag.csv', []}, [], [{:stream, :self}, {:sync, false}])
        {id, ""}
      end,
      fn {id, rest} ->
        receive do
          {:http, {id, :stream_start, _}} ->
            {[], {id, rest}}
          {:http, {id, :stream, chunk}} ->
            lines = String.split(chunk, "\n")
            {Enum.take(lines, Enum.count(lines) - 1), {id, Enum.drop(lines, Enum.count(lines) -1)}}
          {:http, {id, :stream_end, _}} ->
            {:halt, {id, rest}}
        end
      end,
      fn id ->
        IO.inspect("ended")
      end
    )
  end
end
