defmodule PostcodeHuisnummer.PageController do
  use PostcodeHuisnummer.Web, :controller
  alias PostcodeHuisnummer.BagAdres
  alias PostcodeHuisnummer.BagAdresSync

  def index(conn, _params) do
    render(
      conn, "index.html",
      postcode: "", huisnummer: "", bag_adressen: nil
    )
  end

  def show(conn, %{"postcode" => postcode, "huisnummer" => huisnummer}) do
    render(
      conn, "show.html",
      postcode: postcode, huisnummer: huisnummer, bag_adressen: BagAdres.by_postcode_huisnummer(postcode, huisnummer)
    )
  end

  def version(conn, _params) do
    text(conn, inspect(BagAdresSync.last_modified))
  end

  def versions(conn, _params) do
    render(
      conn, "versions.html",
      bag_adres_syncs: BagAdresSync.latest_first
    )
  end
end
