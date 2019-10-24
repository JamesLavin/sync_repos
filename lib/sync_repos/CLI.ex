defmodule SyncRepos.CLI do
  alias SyncRepos.{CommandLineParser, ConfigParser, Display, Git, HexDocs, Notable, Validator}

  def main(args \\ []) do
    args
    |> CommandLineParser.parse()
    |> Validator.exit_if_invalid_sync_dir()
    |> ConfigParser.read_yaml()
    |> HexDocs.sync()
    |> Git.sync()
    |> Display.token()
    |> Notable.set_notables()
    |> Log.output()
    |> Display.response()
  end
end
