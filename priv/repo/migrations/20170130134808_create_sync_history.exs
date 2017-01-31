defmodule PostcodeHuisnummer.Repo.Migrations.CreateSyncHistory do
  use Ecto.Migration

  def change do
    create table(:syncs) do
      add :last_modified, :datetime
      add :started_at, :datetime
      add :finished_at, :datetime

      timestamps()
    end

  end
end
