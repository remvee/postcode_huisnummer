defmodule PostcodeHuisnummer.Repo.Migrations.CreateBagAdres do
  use Ecto.Migration

  def change do
    create table(:bagadressen, primary_key: false) do
      add :openbareruimte, :string, size: 60
      add :huisnummer, :integer
      add :huisletter, :string, size: 1
      add :huisnummertoevoeging, :string, size: 4
      add :postcode, :string, size: 6
      add :woonplaats, :string, size: 40
      add :gemeente, :string, size: 40
      add :provincie, :string, size: 15
      add :object_id, :decimal
      add :object_type, :string, size: 3
      add :nevenadres, :boolean
      add :x, :float
      add :y, :float
      add :lon, :float
      add :lat, :float
    end
    create index(:bagadressen, [:postcode, :huisnummer])

    create table(:bagadressen_tmp, primary_key: false) do
      add :openbareruimte, :string, size: 60
      add :huisnummer, :integer
      add :huisletter, :string, size: 1
      add :huisnummertoevoeging, :string, size: 4
      add :postcode, :string, size: 6
      add :woonplaats, :string, size: 40
      add :gemeente, :string, size: 40
      add :provincie, :string, size: 15
      add :object_id, :decimal
      add :object_type, :string, size: 3
      add :nevenadres, :boolean
      add :x, :float
      add :y, :float
      add :lon, :float
      add :lat, :float
    end
    create index(:bagadressen_tmp, [:postcode, :huisnummer])
  end
end
