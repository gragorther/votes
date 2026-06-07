defmodule Votes.FollowsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Votes.Follows` context.
  """

  @doc """
  Generate a follow.
  """
  def follow_fixture(attrs \\ %{}) do
    {:ok, follow} =
      attrs
      |> Enum.into(%{
        accepted: true,
        object: "some object"
      })
      |> Votes.Follows.create_follow()

    follow
  end
end
