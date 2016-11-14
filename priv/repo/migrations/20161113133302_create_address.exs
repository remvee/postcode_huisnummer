defmodule PostcodeHuisnummer.Repo.Migrations.CreateAddress do
  use Ecto.Migration

  def change do
    create table(:addresses) do
      add :zip_code, :string, size: 6
      add :house_number, :integer
      add :street_name, :string
      add :city, :string
      add :latitude, :float
      add :longitude, :float
      add :active, :boolean, default: false

      timestamps()
    end
    create index(:addresses, [:zip_code, :house_number])
  end
end
