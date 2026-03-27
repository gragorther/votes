defmodule Votes.Posts.Post do
  use Ecto.Schema
  import Ecto.Changeset

  schema "posts" do
    field :ap_id, :string
    field :title, :string
    # announced by
    belongs_to :announced_by, Votes.Actors.Actor, foreign_key: :announced_by_actor_id
    # posted by
    belongs_to :actor, Votes.Actors.Actor
    has_many :votes, Votes.Posts.Vote

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(post, attrs) do
    post
    |> cast(attrs, [:ap_id, :title])
    |> validate_required([:ap_id, :title])
    |> unique_constraint(:ap_id)
  end
end
