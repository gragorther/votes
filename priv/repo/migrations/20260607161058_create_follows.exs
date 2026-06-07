defmodule Votes.Repo.Migrations.CreateFollows do
  use Ecto.Migration

  def change do
    create table(:follows) do
      add :actor_id, references(:actors, on_delete: :delete_all), null: false
      add :accepted, :boolean, default: false, null: false

      timestamps(type: :utc_datetime)
    end

    create unique_index(:follows, [:actor_id])
  end
end
