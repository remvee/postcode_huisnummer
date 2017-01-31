defmodule HttpcHelpers do
  use Timex

  def get_header_value([], _), do: nil
  def get_header_value([{name, val}|_], name), do: val
  def get_header_value([_|rest], name), do: get_header_value(rest, name)

  def get_header_date_time(headers, name) do
    if value = get_header_value(headers, name) do
      {:ok, dt} = Timex.Parse.DateTime.Parser.parse(to_string(value), "{RFC1123}")
      dt
    end
  end

  def last_modified(url) do
    {:ok, {{_, 200, _}, headers, []}} = :httpc.request(:head, {url, []}, [], [])
    {:ok, get_header_date_time(headers, 'last-modified')}
  end
end
