defmodule PostcodeHuisnummer.Repo.Migrations.CreateBagAdresSync do
  use Ecto.Migration

  def change do
    create table(:bagadressen_syncs) do
      add :last_modified, :datetime
      add :started_at, :datetime
      add :finished_at, :datetime
    end
  end
end
