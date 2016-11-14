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
    PostcodeHuisnummer.Repo.delete_all(PostcodeHuisnummer.Address)

    File.stream!('bagadres.csv') |>
      CSV.Decoder.decode(separator: ?;, headers: true) |>
      Stream.map(
        fn %{"postcode" => zip_code,
             "huisnummer" => house_number,
             "openbareruimte" => street_name,
             "woonplaats" => city,
             "lat" => latitude,
              "lon" => longitude} ->
            %{
              zip_code: zip_code,
              house_number: String.to_integer(house_number),
              street_name: street_name,
              city: city,
              latitude: String.to_float(latitude),
              longitude: String.to_float(longitude),
              inserted_at: Ecto.DateTime.from_erl(:calendar.universal_time),
              updated_at: Ecto.DateTime.from_erl(:calendar.universal_time)}
        end) |>
      Stream.chunk(1000) |>
      Stream.each(
        fn recs ->
          PostcodeHuisnummer.Repo.insert_all(PostcodeHuisnummer.Address, recs)
        end) |>
      Stream.run
  end
end
