defmodule PostcodeHuisnummer.BagAdres do
  use PostcodeHuisnummer.Web, :model

  schema "bagadressen" do
    field :openbareruimte, :string
    field :huisnummer, :integer
    field :huisletter, :string
    field :huisnummertoevoeging, :string
    field :postcode, :string
    field :woonplaats, :string
    field :gemeente, :string
    field :provincie, :string
    field :object_id, :decimal
    field :object_type, :string
    field :nevenadres, :string
    field :x, :float
    field :y, :float
    field :lon, :float
    field :lat, :float

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:openbareruimte, :huisnummer, :huisletter, :huisnummertoevoeging, :postcode, :woonplaats, :gemeente, :provincie, :object_id, :object_type, :nevenadres, :x, :y, :lon, :lat])
    |> validate_required([:openbareruimte, :huisnummer, :huisletter, :huisnummertoevoeging, :postcode, :woonplaats, :gemeente, :provincie, :object_id, :object_type, :nevenadres, :x, :y, :lon, :lat])
  end
end
