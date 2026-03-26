defmodule Votes.PostsTest do
  use Votes.DataCase

  alias Votes.Posts

  describe "votes" do
    alias Votes.Posts.Vote

    import Votes.PostsFixtures

    @invalid_attrs %{upvote: nil}

    test "list_votes/0 returns all votes" do
      vote = vote_fixture()
      assert Posts.list_votes() == [vote]
    end

    test "get_vote!/1 returns the vote with given id" do
      vote = vote_fixture()
      assert Posts.get_vote!(vote.id) == vote
    end

    test "create_vote/1 with valid data creates a vote" do
      valid_attrs = %{upvote: true}

      assert {:ok, %Vote{} = vote} = Posts.create_vote(valid_attrs)
      assert vote.upvote == true
    end

    test "create_vote/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Posts.create_vote(@invalid_attrs)
    end

    test "update_vote/2 with valid data updates the vote" do
      vote = vote_fixture()
      update_attrs = %{upvote: false}

      assert {:ok, %Vote{} = vote} = Posts.update_vote(vote, update_attrs)
      assert vote.upvote == false
    end

    test "update_vote/2 with invalid data returns error changeset" do
      vote = vote_fixture()
      assert {:error, %Ecto.Changeset{}} = Posts.update_vote(vote, @invalid_attrs)
      assert vote == Posts.get_vote!(vote.id)
    end

    test "delete_vote/1 deletes the vote" do
      vote = vote_fixture()
      assert {:ok, %Vote{}} = Posts.delete_vote(vote)
      assert_raise Ecto.NoResultsError, fn -> Posts.get_vote!(vote.id) end
    end

    test "change_vote/1 returns a vote changeset" do
      vote = vote_fixture()
      assert %Ecto.Changeset{} = Posts.change_vote(vote)
    end
  end

  describe "communities" do
    alias Votes.Posts.Community

    import Votes.PostsFixtures

    @invalid_attrs %{name: nil, ap_id: nil}

    test "list_communities/0 returns all communities" do
      community = community_fixture()
      assert Posts.list_communities() == [community]
    end

    test "get_community!/1 returns the community with given id" do
      community = community_fixture()
      assert Posts.get_community!(community.id) == community
    end

    test "create_community/1 with valid data creates a community" do
      valid_attrs = %{name: "some name", ap_id: "some ap_id"}

      assert {:ok, %Community{} = community} = Posts.create_community(valid_attrs)
      assert community.name == "some name"
      assert community.ap_id == "some ap_id"
    end

    test "create_community/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Posts.create_community(@invalid_attrs)
    end

    test "update_community/2 with valid data updates the community" do
      community = community_fixture()
      update_attrs = %{name: "some updated name", ap_id: "some updated ap_id"}

      assert {:ok, %Community{} = community} = Posts.update_community(community, update_attrs)
      assert community.name == "some updated name"
      assert community.ap_id == "some updated ap_id"
    end

    test "update_community/2 with invalid data returns error changeset" do
      community = community_fixture()
      assert {:error, %Ecto.Changeset{}} = Posts.update_community(community, @invalid_attrs)
      assert community == Posts.get_community!(community.id)
    end

    test "delete_community/1 deletes the community" do
      community = community_fixture()
      assert {:ok, %Community{}} = Posts.delete_community(community)
      assert_raise Ecto.NoResultsError, fn -> Posts.get_community!(community.id) end
    end

    test "change_community/1 returns a community changeset" do
      community = community_fixture()
      assert %Ecto.Changeset{} = Posts.change_community(community)
    end
  end
end
