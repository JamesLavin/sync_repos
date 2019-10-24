defmodule SyncRepos.RepoDir do
  alias SyncRepos.{Github, ValidRepoDir}
  @type t() :: ValidRepoDir.t() | {:invalid, String.t()}
end
