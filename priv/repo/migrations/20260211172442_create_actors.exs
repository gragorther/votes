defmodule Votes.Repo.Migrations.CreateActors do
  use Ecto.Migration

  def change do
    create table(:actors) do
      add :ap_id, :string, null: false

      timestamps(type: :utc_datetime)
    end
  end
end
