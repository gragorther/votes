defmodule Votes.Repo.Migrations.AddIsGroupFieldToActors do
  use Ecto.Migration

  def change do
    alter table(:actors) do
      add :is_group, :boolean, default: false, null: true
    end
  end
end
