defmodule Votes.Follows.Follow do
  use Ecto.Schema
  import Ecto.Changeset

  schema "follows" do
    field :object, :string
    field :accepted, :boolean, default: false

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(follow, attrs) do
    follow
    |> cast(attrs, [:object, :accepted])
    |> validate_required([:object, :accepted])
  end
end
