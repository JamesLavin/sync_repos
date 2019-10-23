defmodule SyncRepos.Display do
  @major_fields [
    :dir,
    :halt_reason,
    :changes_pulled,
    :changes_pushed,
    :repo_cloned,
    :new_repo_location
  ]

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
    IO.puts("SyncRepos script terminated prematurely\n\n")

    IO.puts(IO.ANSI.reverse() <> "*** WARNING: Processing did not complete successfully ***")

    IO.write(IO.ANSI.reset())
  end

  def response(%{} = token) do
    IO.puts("SyncRepos script completed\n\n")

    IO.puts(IO.ANSI.reverse() <> "Notable repos: #{inspect(token[:notable_repos], pretty: true)}")

    IO.write(IO.ANSI.reset())
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
