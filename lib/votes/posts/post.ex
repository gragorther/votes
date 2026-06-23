defmodule Votes.Posts.Post do
  use Ecto.Schema
  import Ecto.Changeset

  schema "posts" do
    field :ap_id, :string
    field :title, :string
    field :audience, :string
    field :published, :utc_datetime
    belongs_to :in_reply_to, Votes.Posts.Post
    #    belongs_to :announced_by, Votes.Actors.Actor, foreign_key: :announced_by_actor_id
    # posted by
    belongs_to :actor, Votes.Actors.Actor
    has_many :votes, Votes.Posts.Vote

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(post, attrs) do
    post
    |> cast(attrs, [:ap_id, :title, :published])
    |> validate_required([:published, :ap_id])
    |> then(fn changeset ->
      if Map.has_key?(attrs, :in_reply_to) do
        changeset
      else
        validate_required(changeset, [:title])
      end
    end)
    |> unique_constraint(:ap_id)
  end
end
