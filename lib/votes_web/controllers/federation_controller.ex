defmodule VotesWeb.FederationController do
  use VotesWeb, :controller
  alias Votes.Federation

  def inbox(conn, data) do
    [header] = Plug.Conn.get_req_header(conn, "signature")
    Federation.handle_inbox(header, conn.req_headers, data)
  end
end
