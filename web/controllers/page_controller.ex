# postcode_huisnummer
# Copyright (C) 2017 R.W. van 't Veer
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

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
