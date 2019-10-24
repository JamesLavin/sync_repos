defmodule SyncRepos.ValidRepoDir do
  alias SyncRepos.Github
  @type t() :: String.t() | Github.t()
end
