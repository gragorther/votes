defmodule Votes.Federation do
  alias Votes.Federation.Signature

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
end
