defmodule SyncRepos.ConfigParser do
  alias SyncRepos.{Github, Validator}

  def read_yaml(token) do
    filename = Path.expand("#{token.sync_dir}/config")
    {:ok, yaml} = YamlElixir.read_from_file(filename)

    default_git_dir = yaml["default_git_dir"]
    hex_docs_dir = yaml["hex_docs_dir"] |> expand_possibly_nil_path()

    # TODO: Display error and exit if no `:git`?
    # TODO: Add :errors field to Token and save `invalid_git_path: #{git_path}` in it
    git_dirs =
      (yaml["git"] || [])
      |> Enum.map(fn path -> convert_path(path, default_git_dir) end)

    %{token | to_process: git_dirs, default_git_dir: default_git_dir, hex_docs_dir: hex_docs_dir}
    |> Validator.exit_if_any_invalid_to_process_dirs()
    |> Validator.exit_if_invalid_default_git_dir()
  end

  defp convert_path(git_path, default_git_dir) do
    cond do
      is_valid_dir?(git_path) ->
        git_path |> Path.expand()

      Github.is_valid_github?(git_path) ->
        Github.create_github(git_path, default_git_dir)

      true ->
        {:invalid, git_path}
    end
  end

  defp is_valid_dir?(git_path) do
    git_path |> Path.expand() |> File.dir?()
  end

  defp expand_possibly_nil_path(nil), do: nil
  defp expand_possibly_nil_path(path) when is_binary(path), do: Path.expand(path)
end
