defmodule VotesWeb.FederationController do
  use VotesWeb, :controller
  alias Votes.Federation

  def inbox(conn, data) do
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

        signature_base64 = signature.signature

        signature_decoded = Base.decode64!(signature_base64)

        if :crypto.verify(
             :rsa,
             :sha256,
             comparison_string,
             signature_decoded,
             public_key
           ) do
          put_status(conn, 200)
        else
          put_status(conn, 401)
        end
      end
    end
  end
end
