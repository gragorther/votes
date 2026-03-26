defmodule Votes.Posts.Community do
  use Ecto.Schema
  import Ecto.Changeset

  schema "communities" do
    field :name, :string
    field :ap_id, :string
    has_many :posts, Votes.Posts.Post

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(community, attrs) do
    community
    |> cast(attrs, [:name, :ap_id])
    |> validate_required([:name, :ap_id])
    |> unique_constraint(:ap_id)
  end
end
