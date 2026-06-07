defmodule Votes.Federation do
  alias Votes.Federation.Signature
  alias Votes.Actors.Actor

  import Ecto.Query, warn: false
  alias Votes.Repo
  alias Votes.Posts.Vote
  alias Votes.Posts.Post

  def change_signature(attrs) do
    Signature.changeset(%Signature{}, attrs)
  end

  @doc "makes the signature a changeset and converts it into a struct"
  def validate_signature(attrs) do
    change_signature(attrs) |> Ecto.Changeset.apply_action(nil)
  end

  def valid_time?(date) do
    {:ok, time} = Timex.parse(date, "{RFC1123}")

    # absulute because the received date is usually before the current date (unless the actor is a time traveler)
    diff = abs(DateTime.diff(time, DateTime.now!("Etc/UTC")))

    not (diff > :timer.seconds(60))
  end

  # Like / Dislike
  def handle_event(%{
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
