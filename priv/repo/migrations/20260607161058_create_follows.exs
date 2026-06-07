defmodule Votes.Repo.Migrations.CreateFollows do
  use Ecto.Migration

  def change do
    create table(:follows) do
      add :object, :text, null: false
      add :accepted, :boolean, default: false, null: false

      timestamps(type: :utc_datetime)
    end
  end
end
