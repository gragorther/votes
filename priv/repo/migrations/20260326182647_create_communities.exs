defmodule Votes.Repo.Migrations.CreateCommunities do
  use Ecto.Migration

  def change do
    create table(:communities) do
      add :name, :string
      add :ap_id, :string

      timestamps(type: :utc_datetime)
    end

    create unique_index(:communities, [:ap_id])
  end
end
