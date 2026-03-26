defmodule VotesWeb.FederationControllerTest do
  use VotesWeb.ConnCase
  alias Votes.Crypto

  defp current_time_in_rfc1124 do
    to_string(:httpd_util.rfc1123_date())
  end

  defp headers({public_key, private_key}, date) do
    to_be_signed_string =
      "(request-target): post /inbox\nhost: gregtech.eu\ndate: #{date}"

    signed_string = Crypto.sign(private_key, to_be_signed_string) |> Base.encode64()
    # :crypto.sign(:rsa, :sha256, to_be_signed_string, private_key) |> Base.encode64()

    # add digest at some point
    signature_header =
      ~s|keyId="https://my-example.com/actor#main-key",headers="(request-target) host date",signature="#{signed_string}"|

    # {:ok, signature} = Federation.validate_signature(signature_header)

    %{"host" => "gregtech.eu", "date" => date, "signature" => signature_header}
  end

  describe "inbox" do
    test "works", %{conn: conn} do
      date = current_time_in_rfc1124()
      {public_key, private_key} = keypair = Crypto.create_rsa_keypair()

      headers = for header <- headers(keypair, date), into: [], do: header

      conn =
        Map.update(conn, :req_headers, headers, fn current -> current ++ headers end)

      encoded_public_key = Crypto.pem_encode_rsa_public_key(public_key)

      Req.Test.stub(VotesWeb.FederationController, fn conn ->
        Req.Test.json(conn, %{"publicKey" => %{"publicKeyPem" => encoded_public_key}})
      end)

      assert post(conn, ~p"/inbox").status == 200
    end
  end
end
