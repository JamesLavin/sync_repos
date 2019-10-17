defmodule SyncRepos.Display do
  @major_fields [:dir, :halt_reason, :changes_pulled, :changes_pushed]

  def simplified(%{processed: processed} = token) do
    simplified =
      processed
      |> Enum.map(&keep_major_fields/1)

    put_in(token, [:processed], simplified)
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
