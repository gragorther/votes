defmodule Votes.Repo.Migrations.CreateVotes do
  use Ecto.Migration

  def change do
    create table(:votes) do
      add :upvote, :boolean, default: true, null: false
      add :post_id, references(:posts, on_delete: :delete_all)
      add :actor_id, references(:actors, on_delete: :delete_all)
      add :ap_id, :string, null: false

      timestamps(type: :utc_datetime)
    end

    create index(:votes, [:post_id])
    create unique_index(:votes, [:ap_id])
  end
end
