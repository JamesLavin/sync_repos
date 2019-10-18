defmodule SyncRepos.Display do
  @major_fields [:dir, :halt_reason, :changes_pulled, :changes_pushed]

  def token(%{debug: true} = token) do
    token
    |> IO.inspect()
  end

  def token(token) do
    token
    |> simplified()
    |> IO.inspect()

    token
  end

  defp simplified(%{processed: processed} = token) do
    simplified =
      processed
      |> Enum.map(&keep_major_fields/1)

    put_in(token, [:processed], simplified)
  end

  def response(%{halt: true}) do
    "*** WARNING: Processing did not complete successfully ***"
  end

  def response(%{} = token) do
    "SyncRepos script completed\n\nNotable repos: #{inspect(token[:notable_repos], pretty: true)}"
  end

  def set_notable_repos(%{processed: processed} = token) do
    notable =
      processed
      |> Enum.map(&keep_major_fields/1)
      |> Enum.reject(&map_with_only_dir_key/1)

    put_in(token, [:notable_repos], notable)
  end

  defp map_with_only_dir_key(map) do
    map == Map.take(map, [:dir])
  end

  defp keep_major_fields(repo) do
    Map.take(repo, @major_fields)
  end
end
