defmodule SyncRepos.Notable do
  alias SyncRepos.Token

  @major_fields [
    :dir,
    :halt_reason,
    :changes_pulled,
    :changes_pushed,
    :repo_cloned,
    :new_repo_location
  ]
  @spec set_notables(Token.t()) :: map()
  def set_notables(token) do
    token
    |> set_notable_git_repos()
  end

  def set_notable_git_repos(%Token{processed: processed} = token) do
    notable =
      processed
      |> Enum.map(&keep_major_fields/1)
      |> Enum.reject(&no_significant_major_fields/1)

    put_in(token.notable_repos, notable)
  end

  # NOTE: Unnecessary because we're storing only a list of Hex packages
  #       whose documentation changed. But this is the pattern we can
  #       use to boil down complex info into a "just the facts" version
  #       for future sync types
  # def set_notable_hex_packages(%{updated_hex_docs: updated_hex_docs} = token) when is_list(updated_hex_docs) do
  #   put_in(token.updated_hex_docs, updated_hex_docs)
  # end

  def keep_major_fields(repo) do
    Map.take(repo, @major_fields)
  end

  defp no_significant_major_fields(%_{} = struct) do
    struct
    |> Map.from_struct()
    |> no_significant_major_fields()
  end

  defp no_significant_major_fields(map) when is_map(map) do
    map == Map.take(map, [:dir, :repo_cloned]) && map[:repo_cloned] == false
  end
end
