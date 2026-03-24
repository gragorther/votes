import Testcontainers.ExUnit
# {:ok, _} = Testcontainers.start_link()
# repo_config = Application.fetch_env!(:votes, Votes.Repo)

# config =
#   Testcontainers.PostgresContainer.new()
#   |> Testcontainers.PostgresContainer.with_port(Keyword.get(repo_config, :port))
#   |> Testcontainers.PostgresContainer.with_password(Keyword.get(repo_config, :password))
#   |> Testcontainers.PostgresContainer.with_database(Keyword.get(repo_config, :database))
#   |> Testcontainers.PostgresContainer.with_user(Keyword.get(repo_config, :username))

# # |> Testcontainers.PostgresContainer.with_reuse(true)

# {:ok, container} = Testcontainers.start_container(config)
# IO.inspect(container)
# ExUnit.Callbacks.on_exit(fn -> Testcontainers.stop_container(container.container_id) end)

ExUnit.start()

Ecto.Adapters.SQL.Sandbox.mode(Votes.Repo, :manual)
