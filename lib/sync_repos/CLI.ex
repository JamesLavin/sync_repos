defmodule SyncRepos.CLI do
  alias SyncRepos.{CommandLineParser, ConfigParser, Display, Git, Token, Validator}

  def main(args \\ []) do
    args
    |> CommandLineParser.parse()
    |> Validator.exit_if_invalid_sync_dir()
    |> ConfigParser.read_yaml()
    |> Git.sync()
    |> Display.token()
    |> Display.set_notable_repos()
    |> Log.output()
    |> response()
    |> IO.puts()
  end

  defp response(%{halt: true}) do
    "*** WARNING: Processing did not complete successfully ***"
  end

  defp response(%{} = token) do
    "SyncRepos script completed\n\nNotable repos: #{inspect(token[:notable_repos], pretty: true)}"
  end
end
