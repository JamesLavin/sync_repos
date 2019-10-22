defmodule SyncRepos.Github do
  def is_valid_github?(git_path) do
    regex = ~r/^[[:alnum:]_-]+\/[[:alnum:]_-]+$/
    String.match?(git_path, regex)
  end

  def to_github_path(git_path) do
    "git@github.com:#{git_path}.git"
  end

  def create_missing_github_dir(%{processing: %{dir: dir}} = token) do
    regex = ~r/git@github\.com:(?<owner>.*)\/(?<repo>.*)\.git/

    cond do
      String.match?(dir, regex) ->
        %{"owner" => _owner, "repo" => repo} = Regex.named_captures(regex, dir)
        git_dir = token[:default_git_dir]
        :ok = File.cd(git_dir)
        {git_output, 0} = System.cmd("git", ["clone", dir])
        IO.inspect(git_output, label: "git_output")
        put_in(token, [:processing, :dir], Path.join(git_dir, repo))

      true ->
        token
    end
  end
end
