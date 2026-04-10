defmodule Votes.Repo.Migrations.UseDataTypeTextActors do
  use Ecto.Migration

  def change do
    alter table(:actors) do
      modify :public_key, :text
    end
  end
end
