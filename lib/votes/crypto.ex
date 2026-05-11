defmodule Votes.Crypto do
  def create_rsa_private_key do
    :public_key.generate_key({:rsa, 4096, 65537})
  end

  def pem_encode_rsa_private_key(key) do
    :public_key.pem_encode([:public_key.pem_entry_encode(:RSAPrivateKey, key)])
  end

  def public_key_from_private(private_key) do
    {:RSAPrivateKey, _, modulus, publicExponent, _, _, _, _exponent1, _, _, _otherPrimeInfos} =
      private_key

    {:RSAPublicKey, modulus, publicExponent}
  end

  def create_rsa_keypair do
    rsa_private_key = create_rsa_private_key()
    rsa_public_key = public_key_from_private(rsa_private_key)
    {rsa_public_key, rsa_private_key}
  end

  def pem_encode_rsa_public_key(key) do
    [:public_key.pem_entry_encode(:RSAPublicKey, key)]
    |> :public_key.pem_encode()
  end

  def sign(key, text) do
    :public_key.sign(text, :sha256, key)
  end

  def verify(msg, signature, key) do
    :public_key.verify(msg, :sha256, signature, key)
  end

  def decode_pem_key(pem) do
    [public_key_pem_decoded] = :public_key.pem_decode(pem)
    :public_key.pem_entry_decode(public_key_pem_decoded)
  end
end
