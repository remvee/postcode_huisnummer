defmodule PostcodeHuisnummer.SyncHistory do
  use PostcodeHuisnummer.Web, :model
  alias PostcodeHuisnummer.Repo

  schema "syncs" do
    field :last_modified, Ecto.DateTime
    field :started_at, Ecto.DateTime
    field :finished_at, Ecto.DateTime

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:last_modified, :started_at, :finished_at])
    |> validate_required([:last_modified, :started_at, :finished_at])
  end

  def last_modified do
    rec = (from a in __MODULE__, order_by: [desc: a.last_modified], limit: 1) |> Repo.one
    rec && rec.last_modified
  end

  def need_sync?(dt) do
    case (from a in __MODULE__, where: a.last_modified >= ^dt, limit: 1) |> Repo.one do
      nil -> true
      _ -> false
    end
  end
end
