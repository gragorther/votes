defmodule Votes.PostsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Votes.Posts` context.
  """
  def unique_vote_ap_id, do: "https://someserver.com/votes/#{System.unique_integer([:positive])}"

  @doc """
  Generate a vote.
  """
  def vote_fixture(attrs \\ %{}) do
    post = post_fixture()
    actor = Votes.ActorsFixtures.actor_fixture()

    {:ok, vote} =
      attrs
      |> Enum.into(%{
        upvote: true,
        ap_id: unique_vote_ap_id(),
        post_id: post.id,
        actor_id: actor.id
      })
      |> Votes.Posts.create_vote()

    vote
  end

  @doc """
  Generate a unique post ap_id.
  """
  def unique_post_ap_id, do: "https://someserver.com/#{System.unique_integer([:positive])}"

  def post_fixture(attrs \\ %{}) do
    actor = Votes.ActorsFixtures.actor_fixture()

    {:ok, post} =
      attrs
      |> Enum.into(%{
        title: "some title",
        ap_id: unique_post_ap_id(),
        actor_id: actor.id
      })
      |> Votes.Posts.create_post()

    post
  end
end
