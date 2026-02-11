defmodule Votes.Signatures.Signature do
  use Ecto.Schema
  import Ecto.Changeset

  embedded_schema do
    field :key_id, :string
    field :headers, :string
    field :signature, :string
  end

  def changeset(attrs) when is_map(attrs) do
    %Votes.Signatures.Signature{}
    |> cast(attrs, [:key_id, :headers, :signature])
    |> validate_required([:key_id, :headers, :signature])
  end

  def changeset(headerstring) when is_binary(headerstring) do
    header_map =
      String.split(headerstring, ",")
      |> Enum.map(fn x ->
        [key, value] = String.split(x, "=")
        {key, String.replace(value, "\"", "")}
      end)
      |> Map.new()

    changeset(header_map)
  end
end
