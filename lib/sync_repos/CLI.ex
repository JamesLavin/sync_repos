defmodule SyncRepos.CLI do
  alias SyncRepos.Git

  @default_args %{
    halt: false,
    to_process: [
      #  "/Users/jameslavin/Git/elixir",
      #  "/Users/jameslavin/.calcurse",
      #  "/Users/jameslavin/Git/sync_repos"
    ],
    processing: nil,
    processed: []
  }

  def main(args \\ []) do
    args
    |> parse_args
    |> read_yaml()
    |> Git.sync()
    |> display_args()
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
  end

  defp display_args(%{debug: true} = args) do
    args
    |> IO.inspect()
  end

  defp display_args(args), do: args

  defp read_yaml(args) do
    filename = "/Users/jameslavin/.sync_repos"
    {:ok, yaml} = YamlElixir.read_from_file(filename)
    %{args | to_process: yaml["git"]}
  end

  defp response(%{halt: true}) do
    "*** WARNING: Processing did not complete successfully ***"
  end

  defp response(_args) do
    "*** SUCCESS: Processing completed successfully ***"
  end
end
