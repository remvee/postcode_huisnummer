defmodule PostcodeHuisnummer.Repo.Migrations.AddCountToBagAdresSyncs do
  use Ecto.Migration

  def change do
    alter table(:bagadressen_syncs) do
      add :count, :integer
    end
  end
end
