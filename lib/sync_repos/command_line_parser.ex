defmodule SyncRepos.CommandLineParser do
  alias SyncRepos.{Timestamp, Token}

  def parse(args) do
    {parsed_switches, _other_args, _errors} =
      args
      |> OptionParser.parse(
        aliases: [d: :sync_dir],
        strict: [sync_dir: :string, debug: :boolean]
      )

    switches_map =
      parsed_switches
      |> Enum.into(%{})

    token =
      Token.new()
      |> Map.merge(switches_map)
      |> Map.put_new(:timestamp, Timestamp.now())

    token
    |> Map.put(:sync_dir, token.sync_dir |> Path.expand())
  end
end
