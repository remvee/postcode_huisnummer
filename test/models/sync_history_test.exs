defmodule PostcodeHuisnummer.SyncHistoryTest do
  use PostcodeHuisnummer.ModelCase

  alias PostcodeHuisnummer.SyncHistory

  @valid_attrs %{finished_at: %{day: 17, hour: 14, min: 0, month: 4, sec: 0, year: 2010}, last_modified: %{day: 17, hour: 14, min: 0, month: 4, sec: 0, year: 2010}, started_at: %{day: 17, hour: 14, min: 0, month: 4, sec: 0, year: 2010}}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = SyncHistory.changeset(%SyncHistory{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = SyncHistory.changeset(%SyncHistory{}, @invalid_attrs)
    refute changeset.valid?
  end
end
