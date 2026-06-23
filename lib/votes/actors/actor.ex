defmodule Votes.Actors.Actor do
  use Ecto.Schema
  import Ecto.Changeset

  schema "actors" do
    field :ap_id, :string
    field :public_key, :string
    field :username, :string
    field :is_group, :boolean, default: false
    has_many :posts, Votes.Posts.Post
    has_many :votes, Votes.Posts.Vote
    has_one :follow, Votes.Follows.Follow

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(actor, attrs) do
    actor
    |> cast(attrs, [:ap_id, :public_key, :username])
    |> validate_required([:ap_id, :public_key])
    |> unique_constraint(:ap_id)
    |> unique_constraint(:public_key)
  end
end
