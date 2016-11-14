defmodule PostcodeHuisnummer.PageController do
  use PostcodeHuisnummer.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
