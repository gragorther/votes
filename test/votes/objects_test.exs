defmodule Votes.ObjectsTest do
  use Votes.DataCase

  alias Votes.Objects

  describe "posts" do
    alias Votes.Objects.Post

    import Votes.ObjectsFixtures

    @invalid_attrs %{title: nil, ap_id: nil}

    test "list_posts/0 returns all posts" do
      post = post_fixture()
      assert Objects.list_posts() == [post]
    end

    test "get_post!/1 returns the post with given id" do
      post = post_fixture()
      assert Objects.get_post!(post.id) == post
    end

    test "create_post/1 with valid data creates a post" do
      valid_attrs = %{title: "some title", ap_id: "some ap_id"}

      assert {:ok, %Post{} = post} = Objects.create_post(valid_attrs)
      assert post.title == "some title"
      assert post.ap_id == "some ap_id"
    end

    test "create_post/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Objects.create_post(@invalid_attrs)
    end

    test "update_post/2 with valid data updates the post" do
      post = post_fixture()
      update_attrs = %{title: "some updated title", ap_id: "some updated ap_id"}

      assert {:ok, %Post{} = post} = Objects.update_post(post, update_attrs)
      assert post.title == "some updated title"
      assert post.ap_id == "some updated ap_id"
    end

    test "update_post/2 with invalid data returns error changeset" do
      post = post_fixture()
      assert {:error, %Ecto.Changeset{}} = Objects.update_post(post, @invalid_attrs)
      assert post == Objects.get_post!(post.id)
    end

    test "delete_post/1 deletes the post" do
      post = post_fixture()
      assert {:ok, %Post{}} = Objects.delete_post(post)
      assert_raise Ecto.NoResultsError, fn -> Objects.get_post!(post.id) end
    end

    test "change_post/1 returns a post changeset" do
      post = post_fixture()
      assert %Ecto.Changeset{} = Objects.change_post(post)
    end
  end
end
