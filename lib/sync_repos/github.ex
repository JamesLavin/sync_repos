defmodule SyncRepos.Github do
  @enforce_keys [:local_dir, :github_path, :owner, :repo]
  defstruct [:local_dir, :github_path, :owner, :repo]

  @github_path_regex ~r/git@github\.com:(?<owner>.*)\/(?<repo>.*)\.git/

  def is_valid_github?(git_path) do
    regex = ~r/^[[:alnum:]_-]+\/[[:alnum:]_-]+$/
    String.match?(git_path, regex)
  end

  def to_github_path(git_path) do
    "git@github.com:#{git_path}.git"
  end

  def create_missing_github_dir(%{processing: %{dir: dir}} = token) when is_binary(dir), do: token

  def create_missing_github_dir(
        %{
          processing: %{
            dir: %__MODULE__{
              local_dir: local_dir,
              github_path: github_path
            }
          }
        } = token
      )
      when is_binary(local_dir) do
    case File.dir?(local_dir) do
      true ->
        token

      false ->
        git_dir =
          local_dir
          |> parent_dir()

        :ok = File.cd(git_dir)
        clone_repo(token, github_path, local_dir)
    end
  end

  defp clone_repo(token, github_path, local_dir) do
    {_git_output, 0} = System.cmd("git", ["clone", github_path])
    :ok = File.cd(local_dir)
    {status_string, 0} = System.cmd("git", ["status"])
    IO.inspect(status_string, label: "status_string")

    token
    |> put_in([:processing, :dir], local_dir)
    |> put_in([:processing, :repo_cloned], true)
    |> put_in([:processing, :new_repo_location], local_dir)
    |> put_in([:processing, :status], status_string)
  end

  def create_github(git_path, default_git_dir) do
    case is_valid_github?(git_path) do
      true ->
        github_path = git_path |> to_github_path()

        %{"owner" => owner, "repo" => repo} = extract_owner_and_repo(github_path)

        %__MODULE__{
          local_dir: Path.join(default_git_dir, repo) |> Path.expand(),
          github_path: github_path,
          owner: owner,
          repo: repo
        }

      false ->
        {:invalid, git_path}
    end
  end

  defp extract_owner_and_repo(github_path) do
    Regex.named_captures(@github_path_regex, github_path)
  end

  defp parent_dir(dir) do
    Path.join([dir, ".."])
    |> Path.expand()
  end
end
