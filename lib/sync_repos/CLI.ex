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
    |> Display.response()
    |> IO.puts()
  end
end
