defmodule Votes.Repo.Migrations.CreatePosts do
  use Ecto.Migration

  def change do
    create table(:posts) do
      add :ap_id, :string
      add :title, :string
      add :actor_id, references(:actors, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end

    create index(:posts, [:actor_id])
    create unique_index(:posts, [:ap_id])
  end
end
