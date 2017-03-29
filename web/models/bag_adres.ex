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

defmodule PostcodeHuisnummer.BagAdres do
  use PostcodeHuisnummer.Web, :model
  alias PostcodeHuisnummer.Repo

  @primary_key false
  schema "bagadressen" do
    field :openbareruimte, :string
    field :huisnummer, :integer
    field :huisletter, :string
    field :huisnummertoevoeging, :string
    field :postcode, :string
    field :woonplaats, :string
    field :gemeente, :string
    field :provincie, :string
    field :object_id, :decimal
    field :object_type, :string
    field :nevenadres, :boolean
    field :x, :float
    field :y, :float
    field :lon, :float
    field :lat, :float
  end

  def by_postcode_huisnummer(postcode, huisnummer) do
    postcode = postcode |> String.replace(" ", "") |> String.upcase
    huisnummer = huisnummer |> String.replace(~r{[^\d]}, "") |> String.upcase
    (from a in __MODULE__, where: a.postcode == ^postcode and a.huisnummer == ^huisnummer)
    |> Repo.all
  end
end
