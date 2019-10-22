defmodule SyncRepos.Github do
  def is_valid_github?(git_path) do
    regex = ~r/^[[:alnum:]]+\/[[:alnum:]]+$/
    String.match?(git_path, regex)
  end

  def to_github_path(git_path) do
    "git@github.com:#{git_path}.git"
  end
end
