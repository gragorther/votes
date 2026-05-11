defmodule Votes.Repo.Migrations.InsertedAtDefault do
  use Ecto.Migration

  def change do
    for table_name <- [:actors, :posts, :votes] do
      alter table(table_name) do
        modify :inserted_at, :naive_datetime, default: fragment("now()")
      end
    end
  end
end
