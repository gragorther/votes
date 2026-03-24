defmodule VotesWeb.FederationControllerTest do
  alias Votes.Federation
  use VotesWeb.ConnCase

  defp current_time_in_rfc1124 do
    to_string(:httpd_util.rfc1123_date())
  end

  defp keypair do
    :crypto.generate_key(:rsa, {2048, 65537})
  end

  defp headers({public_key, private_key}, date) do
    to_be_signed_string =
      "(request-target): post /inbox\nhost: gregtech.eu\ndate: #{date}"

    signed_string =
      :crypto.sign(:rsa, :sha256, to_be_signed_string, private_key) |> Base.encode64()

    # add digest at some point
    signature_header =
      ~s|keyId="https://my-example.com/actor#main-key",headers="(request-target) host date",signature="#{signed_string}"|

    # {:ok, signature} = Federation.validate_signature(signature_header)

    %{"host" => "gregtech.eu", "date" => date, "signature" => signature_header}
  end

  describe "inbox" do
    test "works", %{conn: conn} do
      date = current_time_in_rfc1124()
      {public_key, private_key} = keypair = keypair()

      headers = for header <- headers(keypair, date), into: [], do: header

      conn =
        Map.update(conn, :req_headers, [], fn current -> current ++ headers end)

      # convert into kwlists because that's what conn has
      # Enum.reduce(headers(keypair, date), conn, fn {k, v}, acc -> Plug.Conn. end)
      [exponent, n] = public_key
      exponent = :binary.decode_unsigned(exponent)
      n = :binary.decode_unsigned(n)
      rsa_pub_record = {:RSAPublicKey, n, exponent}

      encoded_public_key =
        [:public_key.pem_entry_encode(:RSAPublicKey, rsa_pub_record)]
        |> :public_key.pem_encode()

      Req.Test.stub(VotesWeb.FederationController, fn conn ->
        Req.Test.json(conn, %{"publicKey" => %{"publicKeyPem" => encoded_public_key}})
      end)

      assert post(conn, ~p"/inbox").status == 200
    end
  end
end
