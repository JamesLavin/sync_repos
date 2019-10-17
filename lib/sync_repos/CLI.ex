defmodule SyncRepos.CLI do

  alias SyncRepos.Calcurse

  def main(args \\ []) do
    args
    |> parse_args
    |> Calcurse.sync
    |> response
    |> IO.puts()
  end

  defp parse_args(args) do
    {opts, word, _} =
      args
      |> OptionParser.parse(switches: [upcase: :boolean])

    {opts, List.to_string(word)}
  end

  defp response({opts, word}) do
    if opts[:upcase], do: String.upcase(word), else: word
  end
end
