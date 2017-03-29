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

defmodule PostcodeHuisnummer.BagAdresSync do
  use PostcodeHuisnummer.Web, :model
  alias PostcodeHuisnummer.Repo

  schema "bagadressen_syncs" do
    field :last_modified, Ecto.DateTime
    field :started_at, Ecto.DateTime
    field :finished_at, Ecto.DateTime
    field :count, :integer
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:last_modified, :started_at, :finished_at])
    |> validate_required([:last_modified, :started_at, :finished_at])
  end

  def latest_first do
    (from a in __MODULE__, order_by: [desc: a.last_modified]) |> Repo.all
  end

  def last_modified do
    rec = (from a in __MODULE__, order_by: [desc: a.last_modified], limit: 1) |> Repo.one
    rec && rec.last_modified
  end

  def need_sync?(dt) do
    case (from a in __MODULE__, where: a.last_modified >= ^dt, limit: 1) |> Repo.one do
      nil -> true
      _ -> false
    end
  end
end
