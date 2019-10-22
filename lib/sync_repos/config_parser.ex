defmodule SyncRepos.ConfigParser do
  alias SyncRepos.Validator

  def read_yaml(token) do
    filename = Path.expand("#{token[:sync_dir]}/config")
    {:ok, yaml} = YamlElixir.read_from_file(filename)

    default_git_dir = yaml["default_git_dir"]

    # TODO: Display error and exit if no `:git`?
    git_dirs =
      (yaml["git"] || [])
      |> Enum.map(&Path.expand/1)

    %{token | to_process: git_dirs, default_git_dir: default_git_dir}
    |> Validator.exit_if_invalid_default_git_dir()
  end
end
