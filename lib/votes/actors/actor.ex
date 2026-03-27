defmodule Votes.Actors.Actor do
  use Ecto.Schema
  import Ecto.Changeset

  schema "actors" do
    field :ap_id, :string
    field :public_key, :string
    field :username, :string
    has_many :posts, Votes.Posts.Post
    has_many :votes, Votes.Posts.Vote

    # this is not the same as the :posts relationship
    has_many :announcments, Votes.Posts.Post, foreign_key: :announced_by_actor_id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(actor, attrs) do
    actor
    |> cast(attrs, [:ap_id, :public_key, :username])
    |> validate_required([:ap_id, :public_key])
  end
end
