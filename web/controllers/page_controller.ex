defmodule PostcodeHuisnummer.PageController do
  use PostcodeHuisnummer.Web, :controller
  alias PostcodeHuisnummer.BagAdres

  def index(conn, _params) do
    render conn, "index.html", postcode: "", huisnummer: "", bag_adressen: nil
  end

  def show(conn, %{"postcode" => postcode, "huisnummer" => huisnummer}) do
    render conn, "show.html", postcode: postcode, huisnummer: huisnummer, bag_adressen: BagAdres.by_postcode_huisnummer(postcode, huisnummer)
  end
end
