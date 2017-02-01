defmodule PostcodeHuisnummer.BagAdresSyncTest do
  use PostcodeHuisnummer.ModelCase

  alias PostcodeHuisnummer.BagAdresSync

  @valid_attrs %{finished_at: %{day: 17, hour: 14, min: 0, month: 4, sec: 0, year: 2010}, last_modified: %{day: 17, hour: 14, min: 0, month: 4, sec: 0, year: 2010}, started_at: %{day: 17, hour: 14, min: 0, month: 4, sec: 0, year: 2010}}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = BagAdresSync.changeset(%BagAdresSync{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = BagAdresSync.changeset(%BagAdresSync{}, @invalid_attrs)
    refute changeset.valid?
  end
end
