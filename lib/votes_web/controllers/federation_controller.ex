defmodule VotesWeb.FederationController do
  use VotesWeb, :controller
  require Logger
  alias Votes.Federation
  alias Votes.Crypto
  alias Votes.Posts

  # returns an HTTP status
  defp handle_object(
         %{
           "id" => like_activitypub_id,
           "actor" => liked_by,
           "type" => type,
           "object" => liked_post
           #      "audience" => _audience
         },
         _announcer
       )
       when type in ["Like", "Dislike"] do
    upvote? = type == "Like"

    #   if audience != announcer do
    #     400
    #   else
    case Posts.create_vote(upvote?, liked_by, liked_post, like_activitypub_id) do
      :ok -> 200
      {:error, :already_exists} -> 409
    end

    #  end
  end

  defp handle_object(
         %{
           "type" => type
         } = post,
         _announcer
       )
       when type in ["Note", "Page"] do
    case Posts.create_post(post) do
      :ok -> 201
      # Conflict
      {:error, :already_exists} -> 409
    end
  end

  defp handle_object(%{"type" => "Announce", "id" => id, "object" => object, "actor" => actor}, _) do
    if verify_remote_object(object) do
      handle_object(object, actor)
    else
      403
    end
  end

  # verifies stuff and hands the object off to handle_object
  defp handle_event(
         conn,
         %{
           #        "type" => "Announce",
           "actor" => actor_in_object
         } = object,
         actor
       ) do
    if actor != actor_in_object do
      put_status(conn, 403)
    else
      if verify_remote_object(object) do
        put_status(conn, handle_object(object, actor))
      else
        put_status(conn, 403)
      end
    end
  end

  defp verify_remote_object(%{"id" => id} = object) do
    case Req.get(id) do
      {:error, err} ->
        raise err

      {:ok, %{body: ap_received_object}} ->
        ap_received_object == object
    end
  end

  defp verify_crypto(http_headers, signature, public_key) do
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

    Crypto.verify(comparison_string, signature_decoded, public_key)
  end

  def inbox(conn, data) do
    http_headers = Map.new(conn.req_headers)

    with {:ok, signature} <- Federation.validate_signature(http_headers["signature"]),
         {:ok, %{body: %{"publicKey" => %{"publicKeyPem" => public_key}} = signature_response}} <-
           Req.get(signature.key_id, Application.get_env(:votes, :public_key_req_options, [])) do
      if not Federation.valid_time?(http_headers["date"]) do
        put_status(conn, 400)
      else
        key_owner = signature_response["publicKey"]["owner"]

        verify_crypto_fun = fn ->
          if verify_crypto(http_headers, signature, public_key) do
            handle_event(conn, data, key_owner)
          else
            put_status(conn, 401)
          end
        end

        # if the key owner (which is acquired from the signature response)
        # isn't the same as the key id, i.e. they're split across different sites
        if key_owner != signature.key_id do
          actor_resp = Req.get(key_owner)

          case actor_resp do
            {:error, err} ->
              Logger.error(err)
              put_status(conn, 500)

            {:ok, %{status: status}} when status >= 300 ->
              put_status(conn, status)

            {:ok,
             %{body: %{"publicKey" => %{"publicKeyPem" => actor_public_key}, "id" => actor_ap_id}}}
            when actor_public_key != public_key or actor_ap_id != key_owner ->
              put_status(conn, 403)

            {:ok, %{body: %{"id" => actor_ap_id}}} ->
              verify_crypto_fun.()
          end
        else
          verify_crypto_fun.()
        end
      end
    else
      # if something goes wrong parsing the signature or getting the public key
      _ -> put_status(conn, 422)
    end
  end

  def instance_actor_page(conn, _) do
    render(conn, :instance_actor_page)
  end
end
