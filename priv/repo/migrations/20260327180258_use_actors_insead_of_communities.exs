defmodule Votes.Repo.Migrations.UseActorsInseadOfCommunities do
  use Ecto.Migration

  def change do
    drop constraint(:posts, "posts_community_id_fkey")
    drop index(:communities, [:ap_id])
    drop table(:communities)

    alter table(:posts) do
      remove :community_id
      add :announced_by_actor_id, references(:actors, on_delete: :delete_all)
    end
  end
end
