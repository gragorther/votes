defmodule VotesWeb.FederationController do
  use VotesWeb, :controller

  def inbox(conn, %{"actor" => actor}) do
    [header] = Plug.Conn.get_req_header(conn, "signature")
    header = Votes.Signatures.Signature.changeset(header)

    # test
    render(conn, %{actor: actor, header: header.signature})
  end
end
