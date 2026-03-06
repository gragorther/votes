defmodule Votes.Federation do
  alias Votes.Signatures.Signature

  def change_signature(attrs) do
    Votes.Signatures.Signature.changeset(%Signature{}, attrs)
  end

  @doc "makes the signature a changeset and converts it into a struct"
  def validate_signature(attrs) do
    change_signature(attrs) |> Ecto.Changeset.apply_action(nil)
  end

  defp valid_time?(date) do
    {:ok, time} = Timex.parse(date, "{RFC1123}")

    # absulute because the received date is usually before the current date (unless the actor is a time traveler)
    diff = abs(DateTime.diff(time, DateTime.now!("Etc/UTC")))

    not (diff > :timer.seconds(60))
  end

  # if a public key isn't supplied
  def inbox(http_headers, data) do
    with {:ok, signature} <- validate_signature(http_headers["signature"]),
         {:ok, %{body: %{"publicKey" => %{"publicKeyPem" => public_key}}}} <-
           Req.get(signature.key_id) do
      inbox(http_headers, public_key, data)
    end
  end

  # if a public key is supplied (used mainly for testing)
  def inbox(http_headers, public_key, signature \\ nil, data) do
    signature =
      if signature == nil do
        {:ok, signature} = validate_signature(http_headers["signature"])
        signature
      else
        signature
      end

    if valid_time?(http_headers["date"]) do
      handle_inbox(signature, http_headers, public_key, data)
    else
      {:error, :invalid_date}
    end
  end

  defp handle_inbox(signature, http_headers, public_key, _data) do
    # for case-insensitive lookups
    http_headers = for {k, v} <- http_headers, do: {String.downcase(k), v}, into: %{}

    comparison_string =
      Enum.map(signature.headers, fn signed_header_name ->
        if String.starts_with?(signed_header_name, "(request-target)") do
          "(request-target): post /inbox"
        else
          "#{String.downcase(signed_header_name)}: #{http_headers[signed_header_name]}"
        end
      end)
      |> Enum.join("\n")

    # public_key = :public_key.der_decode(:RSAPublicKey, public_key)

    signature_base64 = signature.signature

    signature_decoded = Base.decode64!(signature_base64)

    if :crypto.verify(
         :rsa,
         :sha256,
         comparison_string,
         signature_decoded,
         public_key
       ) do
      :ok
    else
      {:error, :invalid_signature}
    end
  end
end
