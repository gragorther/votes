defmodule VotesWeb.FederationJSON do
  def inbox(data) do
    %{actor: data.actor, header: data.header}
  end

  def account_page do
  end
end
