defmodule SyncRepos.CommandLineParser do
  alias SyncRepos.{Timestamp, Token}

  def parse(args) do
    {parsed_switches, _other_args, _errors} =
      args
      |> OptionParser.parse(
        aliases: [d: :sync_dir, g: :only_git, h: :only_hex],
        strict: [sync_dir: :string, debug: :boolean, only_git: :boolean, only_hex: :boolean]
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
    |> update_only_git(token.only_git)
    |> update_only_hex(token.only_hex)
  end

  defp update_only_git(%Token{} = token, true) do
    token
    |> Map.put(:only_git, token.only_git)
  end

  defp update_only_git(%Token{} = token, _value), do: token

  defp update_only_hex(%Token{} = token, true) do
    token
    |> Map.put(:only_hex, token.only_hex)
  end

  defp update_only_hex(%Token{} = token, _value), do: token
end
