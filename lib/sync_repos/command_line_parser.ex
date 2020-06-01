defmodule SyncRepos.CommandLineParser do
  alias SyncRepos.{Timestamp, Token}

  def parse(args) do
    {parsed_switches, _other_args, _errors} =
      args
      |> OptionParser.parse(
        aliases: [
          # Default behavior:
          #   Does nothing.
          # Safe mode (-s):
          #   -f Fetches master for specified Git repos
          #   -h Updates existing Hex repos & downloads newly specified Hex repos
          a: :all_the_things, # does everything
          d: :sync_dir,       # specifies the config file dir
          f: :fetch_master,   # Git fetch origin master ?
          # g: :sync_git,     # should I sync Git (remove as redundant?)
          h: :sync_hex,       # should I sync Hex?
          r: :rebase_head,    # git pull --rebase origin [branch] ?
          p: :rebase_push_head, # git pull --rebase origin [branch] && git push origin [branch]?
          s: :safe_mode       # -f -h
        ],
        strict: [
          all_the_things: :boolean,
          sync_dir: :string,
          debug: :boolean,
          fetch_master: :boolean,
          rebase_head: :boolean,
          rebase_push_head: :boolean,
          safe_mode: :boolean,
          # sync_git: :boolean,
          sync_hex: :boolean
        ]
      )

    switches_map =
      parsed_switches
      |> Enum.into(%{})

    token =
      Token
      |> struct()
      |> Map.merge(switches_map)
      |> Map.put_new(:timestamp, Timestamp.now())

    token
    |> Map.put(:sync_dir, token.sync_dir |> Path.expand())
    # |> update_sync_git(token.sync_git)
    # |> update_sync_hex(token.sync_hex)
    # |> update_fetch_master(token.fetch_master)
    |> update_safe_mode(token.safe_mode)
    |> update_all_the_things(token.all_the_things)
    |> IO.inspect()

    System.halt(0)
  end

  defp update_safe_mode(%Token{} = token, true) do
    |> set_sync_git(true)
    |> set_sync_hex(true)
    |> set_fetch_head(true)
    |> set_rebase_push_head(false)
    |> set_fetch_master(true)
  end

  defp update_safe_mode(%Token{} = token, _false), do: token

  defp update_all_the_things(%Token{} = token, true) do
    token
    |> set_sync_git(true)
    |> set_sync_hex(true)
    |> set_pull_master(true)
    |> set_rebase_push_head(true)
    |> set_fetch_master(true)
  end

  defp update_all_the_things(%Token{} = token, _false), do: token

  # TODO: DRY up the code below

  # defp update_sync_git(%Token{} = token, true) do
  #   token
  #   |> Map.put(:sync_git, token.sync_git)
  # end

  # defp update_sync_git(%Token{} = token, _value), do: token

  defp set_sync_git(%Token{} = token, value) when is_boolean(value) do
    token
    |> Map.put(:sync_git, value)
  end

  # defp update_sync_hex(%Token{} = token, true) do
  #   token
  #   |> Map.put(:sync_hex, token.sync_hex)
  # end

  # defp update_fetch_master(%Token{} = token, true) do
  #   token
  #   |> Map.put(:fetch_master, token.fetch_master)
  # end

  # defp update_sync_hex(%Token{} = token, _value), do: token

  defp set_sync_hex(%Token{} = token, value) when is_boolean(value) do
    token
    |> Map.put(:sync_hex, value)
  end

  defp set_fetch_master(%Token{} = token, value) when is_boolean(value) do
    token
    |> Map.put(:fetch_master, value)
  end

  defp set_pull_master(%Token{} = token, value) when is_boolean(value) do
    token
    |> Map.put(:pull_master, value)
  end

  defp set_rebase_push_head(%Token{} = token, value) when is_boolean(value) do
    token
    |> Map.put(:rebase_push_head, value)
  end
end
