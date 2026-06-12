defmodule VotesWeb.FederationController do
  use VotesWeb, :controller
  require Logger
  alias Votes.Federation
  alias Votes.Crypto

  def inbox(conn, data) do
    http_headers = Map.new(conn.req_headers)

    with {:ok, signature} <- Federation.validate_signature(http_headers["signature"]),
         {:ok, %{body: %{"publicKey" => %{"publicKeyPem" => public_key}} = signature_response}} <-
           Req.get(signature.key_id, Application.get_env(:votes, :public_key_req_options, [])) do
      if not Federation.valid_time?(http_headers["date"]) do
        put_status(conn, 400)
      else
        key_owner = signature_response["publicKey"]["owner"]
        actor_resp = Req.get(key_owner)

        case actor_resp do
          {:error, err} ->
            Logger.error(err)
            put_status(conn, 500)

          {:ok, %{status: status}} when status < 300 ->
            put_status(conn, status)

          {:ok,
           %{body: %{"publicKey" => %{"publicKeyPem" => actor_public_key}, "id" => actor_ap_id}}}
          when actor_public_key != public_key or actor_ap_id != key_owner ->
            put_status(conn, 403)

          # TODO: use actor_ap_id for security (to prevent random people from sending activities on behalf of others)
          {:ok, %{body: %{"id" => actor_ap_id}}} ->
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

            public_key = Crypto.decode_pem_key(public_key)

            if Crypto.verify(comparison_string, signature_decoded, public_key) do
              case Federation.handle_event(data) do
                :ok -> put_status(conn, 200)
                :error -> put_status(conn, 500)
              end
            else
              put_status(conn, 401)
            end
        end
      end
    else
      _ -> put_status(conn, 422)
    end
  end

  def account_page(conn, _) do
    render(conn, :account_page)
  end
end
