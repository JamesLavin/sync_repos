defmodule SyncRepos.Repo do
  alias SyncRepos.RepoDir
  @type t() :: %{dir: RepoDir.t()}
end
