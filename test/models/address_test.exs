defmodule PostcodeHuisnummer.AddressTest do
  use PostcodeHuisnummer.ModelCase

  alias PostcodeHuisnummer.Address

  @valid_attrs %{city: "some content", house_number: 42, latitude: "120.5", longitude: "120.5", street_name: "some content", zip_code: "some content"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Address.changeset(%Address{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Address.changeset(%Address{}, @invalid_attrs)
    refute changeset.valid?
  end
end
