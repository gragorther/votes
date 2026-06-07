defmodule Votes.Follows do
  @moduledoc """
  The Follows context.
  """

  import Ecto.Query, warn: false
  alias Votes.Repo
  alias Votes.Federation.Signature
  alias Votes.Follows.Follow
  use VotesWeb, :verified_routes
  alias Votes.Crypto

  @doc """
  Follow an actor (be that a community or person)
  """
  def follow(community) do
    url = URI.parse(community)

    headers = [
      date: to_string(:httpd_util.rfc1123_date()),
      host: url.host
    ]

    comparison_string =
      Enum.map(headers, fn {key, value} -> "#{key}: #{value}" end) |> Enum.join("\n")

    signature =
      %Signature{
        # get app url
        key_id: VotesWeb.base_url(),
        headers: Keyword.keys(headers) |> Enum.map(&to_string/1),
        signature: Crypto.sign(Application.get_env(:votes, :private_key), comparison_string)
      }
      |> to_string

    # add signature header
    headers = [{:signature, signature} | headers]

    follow = create_follow(%{object: community})

    body = %{
      "@context" => "https://www.w3.org/ns/activitystreams",
      "actor" => VotesWeb.base_url(),
      "object" => community,
      "type" => "Follow",
      "id" => VotesWeb.base_url() <> "follows/#{follow.id}"
    }

    request = Req.new(method: :post, url: community, headers: headers, body: body)
    Req.post(request)
  end

  @doc """
  Returns the list of follows.

  ## Examples

      iex> list_follows()
      [%Follow{}, ...]

  """
  def list_follows do
    Repo.all(Follow)
  end

  @doc """
  Gets a single follow.

  Raises `Ecto.NoResultsError` if the Follow does not exist.

  ## Examples

      iex> get_follow!(123)
      %Follow{}

      iex> get_follow!(456)
      ** (Ecto.NoResultsError)

  """
  def get_follow!(id), do: Repo.get!(Follow, id)

  @doc """
  Creates a follow.

  ## Examples

      iex> create_follow(%{field: value})
      {:ok, %Follow{}}

      iex> create_follow(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_follow(attrs) do
    %Follow{}
    |> Follow.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a follow.

  ## Examples

      iex> update_follow(follow, %{field: new_value})
      {:ok, %Follow{}}

      iex> update_follow(follow, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_follow(%Follow{} = follow, attrs) do
    follow
    |> Follow.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a follow.

  ## Examples

      iex> delete_follow(follow)
      {:ok, %Follow{}}

      iex> delete_follow(follow)
      {:error, %Ecto.Changeset{}}

  """
  def delete_follow(%Follow{} = follow) do
    Repo.delete(follow)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking follow changes.

  ## Examples

      iex> change_follow(follow)
      %Ecto.Changeset{data: %Follow{}}

  """
  def change_follow(%Follow{} = follow, attrs \\ %{}) do
    Follow.changeset(follow, attrs)
  end

  def approve_follow(%Follow{} = follow) do
    update_follow(follow, %{approved: true})
  end
end
