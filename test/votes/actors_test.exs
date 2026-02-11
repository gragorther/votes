defmodule Votes.ActorsTest do
  use Votes.DataCase

  alias Votes.Actors

  describe "actors" do
    alias Votes.Actors.Actor

    import Votes.ActorsFixtures

    @invalid_attrs %{ap_id: nil}

    test "list_actors/0 returns all actors" do
      actor = actor_fixture()
      assert Actors.list_actors() == [actor]
    end

    test "get_actor!/1 returns the actor with given id" do
      actor = actor_fixture()
      assert Actors.get_actor!(actor.id) == actor
    end

    test "create_actor/1 with valid data creates a actor" do
      valid_attrs = %{ap_id: "some ap_id"}

      assert {:ok, %Actor{} = actor} = Actors.create_actor(valid_attrs)
      assert actor.ap_id == "some ap_id"
    end

    test "create_actor/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Actors.create_actor(@invalid_attrs)
    end

    test "update_actor/2 with valid data updates the actor" do
      actor = actor_fixture()
      update_attrs = %{ap_id: "some updated ap_id"}

      assert {:ok, %Actor{} = actor} = Actors.update_actor(actor, update_attrs)
      assert actor.ap_id == "some updated ap_id"
    end

    test "update_actor/2 with invalid data returns error changeset" do
      actor = actor_fixture()
      assert {:error, %Ecto.Changeset{}} = Actors.update_actor(actor, @invalid_attrs)
      assert actor == Actors.get_actor!(actor.id)
    end

    test "delete_actor/1 deletes the actor" do
      actor = actor_fixture()
      assert {:ok, %Actor{}} = Actors.delete_actor(actor)
      assert_raise Ecto.NoResultsError, fn -> Actors.get_actor!(actor.id) end
    end

    test "change_actor/1 returns a actor changeset" do
      actor = actor_fixture()
      assert %Ecto.Changeset{} = Actors.change_actor(actor)
    end
  end
end
