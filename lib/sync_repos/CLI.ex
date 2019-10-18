defmodule SyncRepos.CLI do
  alias SyncRepos.{Display, Git, Timestamp, Token}

  def main(args \\ []) do
    args
    |> parse_args
    |> exit_if_invalid_sync_dir()
    |> read_yaml()
    |> Git.sync()
    |> display_token()
    |> Display.set_notable_repos()
    |> Log.output()
    |> response()
    |> IO.puts()
  end

  defp parse_args(args) do
    {parsed_switches, _other_args, _errors} =
      args
      |> IO.inspect(label: "args")
      |> OptionParser.parse(
        aliases: [dir: :sync_dir],
        strict: [sync_dir: :string, debug: :boolean]
      )

    switches_map =
      parsed_switches
      |> Enum.into(%{})

    Token.new()
    |> Map.merge(switches_map)
    |> Map.put_new(:timestamp, Timestamp.now())
  end

  defp display_token(%{debug: true} = token) do
    token
    |> IO.inspect()
  end

  defp display_token(token) do
    token
    |> Display.simplified()
    |> IO.inspect()

    token
  end

  defp read_yaml(token) do
    filename = Path.expand("#{token[:sync_dir]}/config")
    {:ok, yaml} = YamlElixir.read_from_file(filename)

    git_dirs =
      yaml["git"]
      |> Enum.map(&Path.expand/1)

    %{token | to_process: git_dirs}
  end

  defp exit_if_invalid_sync_dir(token) do
    sync_dir = token[:sync_dir]

    if !File.dir?(token[:sync_dir]) do
      display_sync_dir_error_and_terminate(token)
    end

    token
  end

  defp display_sync_dir_error_and_terminate(token) do
    IO.puts("")

    IO.puts(
      "*** ERROR: SyncRepos terminated because the sync_repos directory ('#{token[:sync_dir]}') does not exist ***"
    )

    IO.puts("SyncRepo's default directory is ~/.sync_repos")

    IO.puts(
      "You can specify an alternative SyncRepo directory by calling '~/.sync_repos' --sync-dir ~/my_sync_dir"
    )

    IO.puts(
      "You can also specify an alternative directory by calling '~/.sync_repos' -d ~/my_sync_dir"
    )

    System.halt(0)
  end

  defp response(%{halt: true}) do
    "*** WARNING: Processing did not complete successfully ***"
  end

  defp response(%{} = token) do
    "SyncRepos script completed\n\nNotable repos: #{inspect(token[:notable_repos], pretty: true)}"
  end
end
