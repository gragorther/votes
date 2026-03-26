defmodule Votes.Posts.Vote do
  use Ecto.Schema
  import Ecto.Changeset

  schema "votes" do
    field :upvote, :boolean, default: false
    field :ap_id, :string
    # field :post_id, :id
    belongs_to :post, Votes.Posts.Post
    belongs_to :actor, Votes.Actors.Actor

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(vote, attrs) do
    vote
    |> cast(attrs, [:upvote, :post_id, :actor_id, :ap_id])
    |> validate_required([:upvote, :post_id, :actor_id, :ap_id])
    |> assoc_constraint(:post)
    |> assoc_constraint(:actor)
    |> unique_constraint(:ap_id)
  end
end
