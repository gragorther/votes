defmodule Votes.Posts.Post do
  use Ecto.Schema
  import Ecto.Changeset

  schema "posts" do
    field :ap_id, :string
    field :title, :string
    # field :actor_id, :id
    belongs_to :actor, Votes.Actors.Actor
    belongs_to :community, Votes.Posts.Community
    has_many :items, Votes.Posts.Vote

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
