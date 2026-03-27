defmodule Votes.Repo.Migrations.AddCommunityIdToPosts do
  use Ecto.Migration

  def change do
    alter table(:posts) do
      add :community_id, references(:communities, on_delete: :delete_all)
    end
  end
end
