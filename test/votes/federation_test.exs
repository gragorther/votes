defmodule Votes.FederationTest do
  use ExUnit.Case
  alias Hex.Crypto
  alias Votes.Federation
  alias Votes.Signatures

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

    {:ok, signature} = Federation.validate_signature(signature_header)
    headers = %{"host" => "gregtech.eu", "date" => date, "signature" => signature_header}
  end

  describe "federation" do
    test "accepts proper public key" do
      date = current_time_in_rfc1124()
      {public_key, private_key} = keypair = keypair()
      headers = headers(keypair, date)

      :ok = Federation.inbox(headers, public_key, nil)
    end

    test "doesn't accept outdated request (to prevent replay attacks)" do
      dt = Timex.to_datetime(~D[1971-05-23], "Etc/UTC")
      date = Timex.format!(dt, "{RFC1123}")

      {public_key, _private_key} = keypair = keypair()
      headers = headers(keypair, date)

      assert {:error, :invalid_date} == Federation.inbox(headers, public_key, nil)
    end
  end
end
