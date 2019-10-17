defmodule SyncRepos.CLI do
  alias SyncRepos.{Display, Git, Timestamp, Token}

  def main(args \\ []) do
    args
    |> parse_args
    |> read_yaml()
    |> Git.sync()
    |> display_token()
    |> Log.output()
    |> response()
    |> IO.puts()
  end

  defp parse_args(args) do
    {opts, _word, _} =
      args
      |> OptionParser.parse(switches: [debug: :boolean])

    opts
    |> Enum.into(%{})
    |> Map.merge(Token.new())
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

  defp response(%{halt: true}) do
    "*** WARNING: Processing did not complete successfully ***"
  end

  defp response(_token) do
    "*** SUCCESS: Processing completed successfully ***"
  end
end
