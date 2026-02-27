defmodule Votes.FederationTest do
  use ExUnit.Case
  alias Hex.Crypto
  alias Votes.Federation
  alias Votes.Signatures

  defp current_time_in_rfc1124 do
    to_string(:httpd_util.rfc1123_date())
  end

  describe "federation" do
    test "accepts proper public key" do
      date = current_time_in_rfc1124()

      {public_key, private_key} = :crypto.generate_key(:rsa, {2048, 65537})

      to_be_signed_string =
        "(request-target): post /inbox\nhost: gregtech.eu\ndate: #{date}"

      signed_string =
        :crypto.sign(:rsa, :sha256, to_be_signed_string, private_key) |> Base.encode64()

      # add digest at some point
      signature_header =
        ~s|keyId="https://my-example.com/actor#main-key",headers="(request-target) host date",signature="#{signed_string}"|

      {:ok, signature} = Federation.validate_signature(signature_header)
      headers = %{"Host" => "gregtech.eu", "Date" => date}

      :ok = Federation.handle_inbox(signature, headers, public_key, nil)
    end
  end
end
