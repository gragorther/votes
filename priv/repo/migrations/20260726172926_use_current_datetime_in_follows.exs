defmodule Votes.Repo.Migrations.UseCurrentDatetimeInFollows do
  use Ecto.Migration

  def change do
    alter table(:follows) do
      modify :updated_at, :naive_datetime, default: fragment("now()")
    end
  end
end
