defmodule VotesWeb.FederationController do
  use VotesWeb, :controller
  require Logger
  alias Votes.Federation
  alias Votes.Crypto
  alias Votes.Posts

  @ap_object_fields_tied_to_server [
    "attributedTo",
    "actor",
    "id",
    "following",
    "followers",
    "liked",
    "inbox",
    "outbox"
  ]

  defp handle_object(object, actor) do
    if object_server_specific_fields_have_same_server?(object) do
      do_handle_object(object, actor)
    else
      401
    end
  end

  # defp do_handle_object(%{"type" => "Accept", "object" => type =>}, _)

  # returns an HTTP status
  defp do_handle_object(
         %{
           "id" => like_activitypub_id,
           "actor" => liked_by,
           "type" => type,
           "object" => liked_post
           #      "audience" => _audience
         } = vote,
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
  end

  defp do_handle_object(%{"type" => type} = post, _) when type in ["Note", "Page"] do
    case Posts.create_post(post) do
      :ok -> 201
      # Conflict
      {:error, :already_exists} -> 409
    end
  end

  defp do_handle_object(%{"type" => "Announce", "object" => object, "actor" => actor}, _) do
    fetch_remote_object(object) |> handle_object(actor)
  end

  # if the server doesn't recognize the request
  defp do_handle_object(_, _) do
    422
  end

  # defp handle_object(%{"type" => "Create"})

  # verifies stuff and hands the object off to handle_object
  defp handle_event(conn, object, actor) do
    put_status(conn, fetch_remote_object(object) |> handle_object(actor))
  end

  defp fetch_remote_object(%{"id" => id}) when is_binary(id) do
    fetch_remote_object(id)
  end

  defp fetch_remote_object(object) when is_binary(object) do
    case Req.get!(object) do
      %{body: ap_object} -> ap_object
    end
  end

  defp object_server_specific_fields_have_same_server?(object) do
    Enum.map(@ap_object_fields_tied_to_server, fn field -> object[field] end)
    |> Enum.reject(fn field -> field == nil end)
    |> Enum.map(fn x ->
      uri = URI.new!(x)
      {uri.host, uri.port, uri.scheme}
    end)
    |> Enum.uniq()
    |> length == 1
  end

  # defp verify_remote_object(%{"id" => id} = object) do
  #   case Req.get(id) do
  #     {:error, err} ->
  #       raise err

  #     #  {:ok, %{body: %{"" => id} = body}} ->
  #     #    verify_remote_object(body)

  #     {:ok, %{body: ap_received_object}} ->
  #       ap_received_object == object
  #   end
  # end

  defp verify_crypto(http_headers, request_body, signature, public_key) do
    comparison_string =
      Enum.map(signature.headers, fn signed_header_name ->
        case signed_header_name do
          "(request-target)" ->
            "(request-target): post /inbox"

          "digest" ->
            Crypto.hash(request_body)

          _ ->
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
    {:ok, body, conn} = Plug.Conn.read_body(conn)

    with {:ok, signature} <- Federation.validate_signature(http_headers["signature"]),
         {:ok, %{body: %{"publicKey" => %{"publicKeyPem" => public_key}} = signature_response}} <-
           Req.get(signature.key_id, Application.get_env(:votes, :public_key_req_options, [])) do
      if not Federation.valid_time?(http_headers["date"]) do
        put_status(conn, 400)
      else
        key_owner = signature_response["publicKey"]["owner"]

        # ensure "digest" is in signature headers so the payload can be verified
        verify_crypto_fun = fn ->
          if verify_crypto(http_headers, body, signature, public_key) and
               "digest" in signature.headers do
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
              put_status(conn, 401)

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

  # defp expand_embedded_objects(object) when is_binary(object) do
  #   case Req.get!(object) do
  #     %{body: %{"object" => next_object}} ->
  #       %{object | "object" => expand_embedded_objects(next_object)}

  #     %{body: next_object} ->
  #       next_object
  #   end
  # end

  # defp expand_embedded_objects(object) do
  #   case object do
  #     %{"object" => next_object} -> %{object | "object" => expand_embedded_objects(next_object)}
  #   end
  # end

  # defp verify_recursive_objects(id) when is_binary(id) do
  #   case Req.get(id) do
  #     {:error, err} ->
  #       Logger.error(err)
  #       false

  #     {:ok, %{body: ap_received_object}} ->
  #       verify_recursive_objects(ap_received_object, true)
  #   end
  # end

  # defp verify_recursive_objects(object, object_trusted? \\ false) do
  #   if not object_trusted? or not is_map_key(object, "id") or not verify_remote_object(object) do
  #     false
  #   else
  #     case object do
  #       %{"object" => next_object} ->
  #         verify_recursive_objects(next_object)

  #       _ when not is_map_key(object, "object") ->
  #         true
  #     end
  #   end
  # end
end
