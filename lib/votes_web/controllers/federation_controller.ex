defmodule VotesWeb.FederationController do
  use VotesWeb, :controller

  def inbox(conn, %{"actor" => actor}) do
    headers = Plug.Conn.get_req_header(conn, "signature")

    render(conn, %{actor: actor, header: headers})
  end
end
