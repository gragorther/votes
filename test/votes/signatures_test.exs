defmodule Votes.SignaturesTest do
  alias Votes.Signatures.Signature
  alias Votes.Federation
  use ExUnit.Case

  describe "signatures" do
    test "parses Signature header properly" do
      x =
        ~S[keyId="https://my-example.com/actor#main-key",headers="(request-target) host date",signature="Y2FiYW...IxNGRiZDk4ZA=="]

      # apply nil action to get Signatures{} struct
      signature = Federation.change_signature(x) |> Ecto.Changeset.apply_action!(nil)

      assert signature.key_id == "https://my-example.com/actor#main-key"

      assert signature.headers == ["(request-target)", "host", "date"]
      assert signature.signature == "Y2FiYW...IxNGRiZDk4ZA=="
    end
  end
end
