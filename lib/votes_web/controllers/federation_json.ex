defmodule VotesWeb.FederationJSON do
  def inbox(data) do
    %{actor: data.actor, header: data.header}
  end
end
