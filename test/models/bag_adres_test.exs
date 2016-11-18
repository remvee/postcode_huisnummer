defmodule PostcodeHuisnummer.BagAdresTest do
  use PostcodeHuisnummer.ModelCase

  alias PostcodeHuisnummer.BagAdres

  @valid_attrs %{gemeente: "some content", huisletter: "some content", huisnummer: 42, huisnummertoevoeging: "some content", lat: "120.5", lon: "120.5", nevenadres: "some content", object_id: 42, object_type: "some content", openbareruimte: "some content", postcode: "some content", provincie: "some content", woonplaats: "some content", x: 42, y: 42}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = BagAdres.changeset(%BagAdres{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = BagAdres.changeset(%BagAdres{}, @invalid_attrs)
    refute changeset.valid?
  end
end
