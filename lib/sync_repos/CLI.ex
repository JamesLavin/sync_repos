defmodule SyncRepos.CLI do
  alias SyncRepos.Calcurse

  @default_args %{
    halt: false,
    to_process: ["/Users/jameslavin/.calcurse"],
    processing: nil,
    processed: []
  }

  def main(args \\ []) do
    args
    |> parse_args
    |> Calcurse.sync()
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

  defp response(%{halt: true}) do
    "*** WARNING: Processing did not complete successfully ***"
  end

  defp response(_args) do
    "*** SUCCESS: Processing completed successfully ***"
  end
end
