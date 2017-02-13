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

  def count do
    Repo.aggregate(PostcodeHuisnummer.BagAdres, :count, :object_id)
  end
end
