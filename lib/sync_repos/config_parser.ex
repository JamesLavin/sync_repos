defmodule SyncRepos.ConfigParser do
  def read_yaml(token) do
    filename = Path.expand("#{token[:sync_dir]}/config")
    {:ok, yaml} = YamlElixir.read_from_file(filename)

    git_dirs =
      yaml["git"]
      |> Enum.map(&Path.expand/1)

    %{token | to_process: git_dirs}
  end
end
