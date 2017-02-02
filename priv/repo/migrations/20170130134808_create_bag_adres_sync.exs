defmodule PostcodeHuisnummer.Repo.Migrations.CreateBagAdresSync do
  use Ecto.Migration

  def change do
    create table(:bagadressen_syncs) do
      add :last_modified, :utc_datetime
      add :started_at, :utc_datetime
      add :finished_at, :utc_datetime
    end
  end
end
