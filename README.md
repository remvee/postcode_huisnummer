# http://data.nlextract.nl/bag/csv/bag-adressen-laatst.csv.zip #

# :inets.start
# :httpc.request(:get, {'http://data.nlextract.nl/bag/csv/bag-adressen-laatst.csv.zip', []}, [], [{:stream, 'data.zip'}])
# :zip.extract('data.zip', [:memory])

require Ecto.Query
PostcodeHuisnummer.Address |> Ecto.Query.select([a], count(a.street_name)) |> PostcodeHuisnummer.Repo.all

File.stream!('bag-adressen-amstelveen.csv') |> CSV.Decoder.decode(headers: true) |> Enum.take(2)

File.stream!('bagadres.csv') |> CSV.Decoder.decode(headers: true) |>
Enum.take(20) |> Enum.map(fn %{"postcode" => zip_code, "huisnummer" =>
house_number, "openbareruimte" => street_name, "woonplaats" => city, "lat" =>
latitude, "lon" => longitude} -> %PostcodeHuisnummer.Address{zip_code:
zip_code, house_number: String.to_integer(house_number), street_name:
street_name, city: city, latitude: String.to_float(latitude), longitude:
String.to_float(longitude)} end)|> Enum.each(fn rec ->
PostcodeHuisnummer.Repo.insert!(rec) end)

[%{street_name: street_name}] = PostcodeHuisnummer.Repo.all(Ecto.Query.from a in PostcodeHuisnummer.Address, where: a.zip_code == "1181AA" and a.house_number == 26)

https://hexdocs.pm/ecto/Ecto.html
https://hexdocs.pm/csv/1.2.1/overview.html
https://hexdocs.pm/httpoison/api-reference.html
http://erlang.org/doc/man/zip.html

# PostcodeHuisnummer

To start your Phoenix app:

  * Install dependencies with `mix deps.get`
  * Create and migrate your database with `mix ecto.create && mix ecto.migrate`
  * Install Node.js dependencies with `npm install`
  * Start Phoenix endpoint with `mix phoenix.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](http://www.phoenixframework.org/docs/deployment).

## Learn more

  * Official website: http://www.phoenixframework.org/
  * Guides: http://phoenixframework.org/docs/overview
  * Docs: https://hexdocs.pm/phoenix
  * Mailing list: http://groups.google.com/group/phoenix-talk
  * Source: https://github.com/phoenixframework/phoenix
