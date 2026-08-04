defmodule VotesWeb.FederationControllerTest do
  use VotesWeb.ConnCase
  use Votes.DataCase
  alias Votes.Crypto
  import Votes.PostsFixtures
  import Votes.ActorsFixtures

  defp current_time_in_rfc1124 do
    to_string(:httpd_util.rfc1123_date())
  end

  defp headers({public_key, private_key}, date) do
    # {:ok, signature} = Federation.validate_signature(signature_header)
    signature_header = create_signature_header(private_key, date)
    %{"host" => "gregtech.eu", "date" => date, "signature" => signature_header}
  end

  defp create_signature_header(private_key, date) do
    to_be_signed_string =
      "(request-target): post /inbox\nhost: gregtech.eu\ndate: #{date}"

    signed_string = Crypto.sign(private_key, to_be_signed_string) |> Base.encode64()
    # :crypto.sign(:rsa, :sha256, to_be_signed_string, private_key) |> Base.encode64()

    # add digest at some point
    signature_header =
      ~s|keyId="https://my-example.com/actor#main-key",headers="(request-target) host date",signature="#{signed_string}"|
  end

  # describe "inbox" do
  #   test "accepts valid create activity" do

  #   end
  # end
end
