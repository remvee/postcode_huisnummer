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
    import ChunkyStreams

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
end
