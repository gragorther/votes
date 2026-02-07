defmodule VotesWeb.PageController do
  use VotesWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
