defmodule Votes.Actors.Actor do
  use Ecto.Schema
  import Ecto.Changeset

  schema "actors" do
    field :ap_id, :string
    field :public_key, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(actor, attrs) do
    actor
    |> cast(attrs, [:ap_id, :public_key])
    |> validate_required([:ap_id, :public_key])
  end
end
