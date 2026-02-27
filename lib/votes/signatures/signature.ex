defmodule Votes.Signatures.Signature do
  use Ecto.Schema
  import Ecto.Changeset

  embedded_schema do
    field :key_id, :string
    field :headers, {:array, :string}
    field :signature, :string
  end

  def changeset(signature, headerstring) when is_binary(headerstring) do
    header_map =
      String.split(headerstring, ",")
      |> Enum.map(fn x ->
        [key, value] = String.split(x, "=", parts: 2)

        value = String.trim(value, "\"")

        case key do
          "headers" -> {key, String.split(value, " ")}
          "keyId" -> {"key_id", value}
          _ -> {key, value}
        end
      end)
      |> Map.new()

    changeset(signature, header_map)
  end

  def changeset(signature, attrs) when is_map(attrs) do
    signature
    |> cast(attrs, [:key_id, :headers, :signature])
    |> validate_required([:key_id, :headers, :signature])
  end
end
