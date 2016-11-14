defmodule PostcodeHuisnummer.Address do
  use PostcodeHuisnummer.Web, :model

  schema "addresses" do
    field :zip_code, :string
    field :house_number, :integer
    field :street_name, :string
    field :city, :string
    field :latitude, :float
    field :longitude, :float

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:zip_code, :house_number, :street_name, :city, :latitude, :longitude])
    |> validate_required([:zip_code, :house_number, :street_name, :city, :latitude, :longitude])
  end
end
