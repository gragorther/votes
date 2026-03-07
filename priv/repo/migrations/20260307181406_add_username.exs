defmodule Votes.Repo.Migrations.AddUsername do
  use Ecto.Migration

  def change do
    alter table(:actors) do
      add :username, :string
    end
  end
end
