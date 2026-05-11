defmodule Votes.Objects do
  alias Votes.Actors.Actor

  import Ecto.Query, warn: false
  alias Votes.Repo
  alias Votes.Posts.Vote
  alias Votes.Posts.Post

  def create_object(%{
        "type" => "Announce",
        "actor" => _announced_by,
        "object" => %{
          "id" => like_activitypub_id,
          "actor" => liked_by,
          "type" => type,
          "object" => liked_post
        }
      })
      when type in ["Like", "Dislike"] do
    upvote? = type == "Like"

    # only one record should be put in the db

    case Repo.insert_all(
           Vote,
           from(p in Post,
             where: p.ap_id == ^liked_post,
             join: a in Actor,
             on: a.ap_id == ^liked_by,
             select: %{
               upvote: ^upvote?,
               post_id: p.id,
               ap_id: ^like_activitypub_id,
               actor_id: a.id
             }
           )
         ) do
      {1, _} -> :ok
      _ -> :error
    end
  end
end
