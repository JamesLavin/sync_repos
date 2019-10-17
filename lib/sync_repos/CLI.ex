defmodule SyncRepos.CLI do
  alias SyncRepos.{Git, Timestamp}

  @default_args %{
    sync_dir: "~/.sync_repos",
    halt: false,
    to_process: [],
    processing: nil,
    processed: []
  }

  def main(args \\ []) do
    args
    |> parse_args
    |> read_yaml()
    |> Git.sync()
    |> display_args()
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
    |> Map.merge(@default_args)
    |> Map.put_new(:timestamp, Timestamp.now())
  end

  defp display_args(%{debug: true} = args) do
    args
    |> IO.inspect()
  end

  defp display_args(args), do: args

  defp read_yaml(args) do
    filename = Path.expand("#{args[:sync_dir]}/config")
    {:ok, yaml} = YamlElixir.read_from_file(filename)

    git_dirs =
      yaml["git"]
      |> Enum.map(&Path.expand/1)

    %{args | to_process: git_dirs}
  end

  defp response(%{halt: true}) do
    "*** WARNING: Processing did not complete successfully ***"
  end

  defp response(_args) do
    "*** SUCCESS: Processing completed successfully ***"
  end
end
