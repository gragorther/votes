defmodule Votes.ObjectsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Votes.Objects` context.
  """

  @doc """
  Generate a post.
  """
  def post_fixture(attrs \\ %{}) do
    {:ok, post} =
      attrs
      |> Enum.into(%{
        ap_id: "some ap_id",
        title: "some title"
      })
      |> Votes.Objects.create_post()

    post
  end
end
