defmodule SyncRepos.Display do
  alias SyncRepos.{HexDocs, Notable}

  def token(%{debug: true} = token) do
    token
    |> IO.inspect()
  end

  def token(token) do
    token
    |> simplified()
    |> IO.inspect()

    token
  end

  defp simplified(%{processed: processed} = token) do
    simplified =
      processed
      |> Enum.map(&Notable.keep_major_fields/1)

    put_in(token, [:processed], simplified)
  end

  def response(%{halt: true}) do
    IO.puts("SyncRepos script terminated prematurely\n\n")

    IO.puts(IO.ANSI.reverse() <> "*** WARNING: Processing did not complete successfully ***")

    IO.write(IO.ANSI.reset())
  end

  def response(%{} = token) do
    IO.puts("SyncRepos script completed\n\n")

    IO.puts(IO.ANSI.reverse() <> "Notable repos: #{inspect(token[:notable_repos], pretty: true)}")

    IO.write(IO.ANSI.reset())

    if HexDocs.active?(token) do
      IO.puts(
        IO.ANSI.reverse() <>
          "Updated Hex package docs: #{inspect(token[:updated_hex_docs], pretty: true)}"
      )

      IO.write(IO.ANSI.reset())
    end
  end
end
