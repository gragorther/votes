defmodule Votes.Repo.Migrations.AddAudienceField do
  use Ecto.Migration

  def change do
    alter table(:posts) do
      add :audience, :string, null: true
      remove :announced_by_actor_id
      add :published, :utc_datetime, null: false
    end
  end
end
