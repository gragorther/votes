defmodule Votes.Objects.Post do
  use Ecto.Schema
  import Ecto.Changeset

  schema "posts" do
    field :ap_id, :string
    field :title, :string
    field :actor_id, :id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(post, attrs) do
    post
    |> cast(attrs, [:ap_id, :title])
    |> validate_required([:ap_id, :title])
  end
end
