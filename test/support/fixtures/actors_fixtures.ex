defmodule Votes.ActorsFixtures do
  alias Votes.Crypto

  @moduledoc """
  This module defines test helpers for creating
  entities via the `Votes.Actors` context.
  """

  @doc """
  Generate a actor.
  """
  def actor_fixture(attrs \\ %{}) do
    {public_key, _} = Crypto.create_rsa_keypair()

    {:ok, actor} =
      attrs
      |> Enum.into(%{
        ap_id: "some ap_id",
        public_key: Crypto.pem_encode_rsa_public_key(public_key)
      })
      |> Votes.Actors.create_actor()

    actor
  end
end
