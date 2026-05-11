defmodule Votes.Repo.Migrations.UpdatedAtDefault do
  use Ecto.Migration

  def change do
    for table_name <- [:actors, :posts, :votes] do
      alter table(table_name) do
        modify :updated_at, :naive_datetime, default: fragment("now()")
      end
    end
  end
end
