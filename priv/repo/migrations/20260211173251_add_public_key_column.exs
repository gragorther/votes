defmodule Votes.Repo.Migrations.AddPublicKeyColumn do
  use Ecto.Migration

  def change do
    alter table(:actors) do
      add :public_key, :string, null: false
    end
  end
end
