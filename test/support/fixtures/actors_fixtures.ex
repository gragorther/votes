defmodule Votes.ActorsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Votes.Actors` context.
  """

  @doc """
  Generate a actor.
  """
  def actor_fixture(attrs \\ %{}) do
    {:ok, actor} =
      attrs
      |> Enum.into(%{
        ap_id: "some ap_id"
      })
      |> Votes.Actors.create_actor()

    actor
  end
end
