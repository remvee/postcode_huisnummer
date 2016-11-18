defmodule PostcodeHuisnummer.Repo.Migrations.CreateBagAdres do
  use Ecto.Migration

  def change do
    create table(:bagadressen) do
      add :openbareruimte, :string
      add :huisnummer, :integer
      add :huisletter, :string, size: 1
      add :huisnummertoevoeging, :string, size: 5
      add :postcode, :string, size: 6
      add :woonplaats, :string
      add :gemeente, :string
      add :provincie, :string
      add :object_id, :decimal
      add :object_type, :string
      add :nevenadres, :string
      add :x, :float
      add :y, :float
      add :lon, :float
      add :lat, :float

      timestamps()
    end
    create index(:bagadressen, [:postcode, :huisnummer])
  end
end
