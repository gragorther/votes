defmodule VotesWeb.FederationController do
  use VotesWeb, :controller
  alias Votes.Federation

  def inbox(conn, _data) do
    http_headers = Map.new(conn.req_headers)

    with {:ok, signature} <- Federation.validate_signature(http_headers["signature"]),
         {:ok, %{body: %{"publicKey" => %{"publicKeyPem" => public_key}}}} <-
           Req.get(signature.key_id, Application.get_env(:votes, :public_key_req_options, [])) do
      if not Federation.valid_time?(http_headers["date"]) do
        put_status(conn, 400)
      else
        comparison_string =
          Enum.map(signature.headers, fn signed_header_name ->
            if String.starts_with?(signed_header_name, "(request-target)") do
              "(request-target): post /inbox"
            else
              "#{String.downcase(signed_header_name)}: #{http_headers[signed_header_name]}"
            end
          end)
          |> Enum.join("\n")

        [public_key_pem_decoded] = :public_key.pem_decode(public_key)
        public_key = :public_key.pem_entry_decode(public_key_pem_decoded)
        signature_base64 = signature.signature

        signature_decoded = Base.decode64!(signature_base64)

        # I used :public_key instead of :crypto because for some reason the PEM decoders from :public_key return
        # a different format than the one :crypto accepts
        if :public_key.verify(comparison_string, :sha256, signature_decoded, public_key) do
          put_status(conn, 200)
        else
          put_status(conn, 401)
        end

        # if :crypto.verify(
        #      :rsa,
        #      :sha256,
        #      comparison_string,
        #      signature_decoded,
        #      public_key
        #    ) do
        #   put_status(conn, 200)
        # else
        #   put_status(conn, 401)
        # end
      end
    end
  end
end
