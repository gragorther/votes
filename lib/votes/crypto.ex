defmodule Votes.Crypto do
  def create_rsa_private_key do
    :public_key.generate_key({:rsa, 4096, 65537})
  end

  def create_rsa_keypair do
    # stolen from https://elixirforum.com/t/how-to-generate-rsa-public-key-using-crypto-provided-exponent-and-modulus/38487/5
    {:RSAPrivateKey, _, modulus, publicExponent, _, _, _, _exponent1, _, _, _otherPrimeInfos} =
      rsa_private_key = create_rsa_private_key()

    rsa_public_key = {:RSAPublicKey, modulus, publicExponent}

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
end
