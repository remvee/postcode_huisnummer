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
