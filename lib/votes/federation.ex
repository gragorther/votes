defmodule Votes.Federation do
  alias Votes.Signatures.Signature

  def change_signature(attrs) do
    Votes.Signatures.Signature.changeset(%Signature{}, attrs)
  end

  @doc "makes the signature a changeset and converts it into a struct"
  def validate_signature(attrs) do
    change_signature(attrs) |> Ecto.Changeset.apply_action(nil)
  end

  def handle_inbox(signature, http_headers, public_key, _data) do
    #  {:ok, %{body: %{"publicKey" => %{"publicKeyPem" => public_key}}} = resp} <-
    #   Req.get(signature.key_id) do

    # converts keys to lowercase to allow for case-insensitive map lookups while building the comparison string (because the header names in the Signature header are lowercase)
    http_headers = for {k, v} <- http_headers, do: {String.downcase(k), v}, into: %{}

    comparison_string =
      Enum.map(signature.headers, fn signed_header_name ->
        if String.starts_with?(signed_header_name, "(request-target)") do
          "(request-target): post /inbox"
        else
          # this has to be capitalized because http headers are capitalized
          "#{signed_header_name}: #{http_headers[signed_header_name]}"
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
