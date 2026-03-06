defmodule VotesWeb.FederationController do
  use VotesWeb, :controller
  alias Votes.Federation

  def inbox(conn, data) do
    case Federation.inbox(Map.new(conn.req_headers), data) do
      :ok -> Plug.Conn.put_status(conn, 200)
      {:error, _} -> Plug.Conn.put_status(conn, 400)
    end
  end
end
