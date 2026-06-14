defmodule Votes.Repo.Migrations.ActorsApIdUnique do
  use Ecto.Migration

  def change do
    create unique_index(:actors, [:ap_id])
  end
end
