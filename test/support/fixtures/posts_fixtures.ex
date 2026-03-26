defmodule Votes.PostsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Votes.Posts` context.
  """

  @doc """
  Generate a vote.
  """
  def vote_fixture(attrs \\ %{}) do
    {:ok, vote} =
      attrs
      |> Enum.into(%{
        upvote: true
      })
      |> Votes.Posts.create_vote()

    vote
  end

  @doc """
  Generate a unique community ap_id.
  """
  def unique_community_ap_id, do: "some ap_id#{System.unique_integer([:positive])}"

  @doc """
  Generate a community.
  """
  def community_fixture(attrs \\ %{}) do
    {:ok, community} =
      attrs
      |> Enum.into(%{
        ap_id: unique_community_ap_id(),
        name: "some name"
      })
      |> Votes.Posts.create_community()

    community
  end

  def post_fixture(attrs \\ %{}) do
    {:ok, post} =
      attrs
      |> Enum.into(%{
        ap_id: "some ap_id",
        title: "some title"
      })
      |> Votes.Posts.create_post()

    post
  end
end
