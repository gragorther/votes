defmodule Votes.Follows.Follow do
  use Ecto.Schema
  import Ecto.Changeset

  schema "follows" do
    belongs_to(:actor, Votes.Actors.Actor)
    field :accepted, :boolean, default: false

    timestamps(type: :utc_datetime)
  end

  @doc false

  # use this when we have internal data
  def changeset(follow, attrs) do
    follow
    |> cast(attrs, [:actor_id, :accepted])
    |> validate_required([:actor_id])
    |> unique_constraint(:actor_id)
  end
end
