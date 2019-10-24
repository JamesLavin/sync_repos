defmodule SyncRepos.Github do
  alias SyncRepos.{Token, ValidRepoDir}

  @enforce_keys [:local_dir, :github_path, :owner, :repo]
  defstruct [:local_dir, :github_path, :owner, :repo]

  @type t() :: %__MODULE__{
          local_dir: String.t(),
          github_path: String.t(),
          owner: String.t(),
          repo: String.t()
        }

  @github_path_regex ~r/git@github\.com:(?<owner>.*)\/(?<repo>.*)\.git/

  @spec is_valid_github?(binary) :: boolean
  def is_valid_github?(git_path) do
    regex = ~r/^[[:alnum:]_-]+\/[[:alnum:]_-]+$/
    String.match?(git_path, regex)
  end

  @spec to_github_path(String.t()) :: String.t()
  def to_github_path(git_path) when is_binary(git_path) do
    "git@github.com:#{git_path}.git"
  end

  @spec create_missing_github_dir(%Token{processing: %{dir: ValidRepoDir.t(), halt: false}}) ::
          %Token{
            processing: %{dir: ValidRepoDir.t()}
          }
  def create_missing_github_dir(%Token{processing: %{dir: dir}, halt: false} = token)
      when is_binary(dir),
      do: token

  def create_missing_github_dir(
        %Token{
          processing: %{
            dir: %__MODULE__{
              local_dir: local_dir,
              github_path: github_path
            },
            halt: false
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

    new_processing =
      token.processing
      |> Map.put_new(:repo_cloned, true)
      |> Map.put_new(:new_repo_location, local_dir)
      |> Map.put_new(:status, status_string)

    put_in(token.processing, new_processing)
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
