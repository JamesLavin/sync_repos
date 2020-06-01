defmodule SyncRepos.HexDocs do
  alias SyncRepos.Token

  @spec sync(Token.t()) :: Token.t()
  def sync(%Token{sync_hex: false} = token), do: token

  def sync(%Token{hex_docs_dir: dir, hexdoc_packages: hexdoc_packages} = token)
      when is_binary(dir) do
    update_hex_packages(dir, hexdoc_packages, token)
  end

  def sync(%Token{} = token), do: token

  defp update_hex_packages(dir, new_packages, %Token{} = token)
       when is_binary(dir) and is_list(new_packages) do
    if File.dir?(dir) do
      do_update_hex_packages(dir, new_packages, token)
    else
      IO.puts("WARNING: '#{dir}' is not a valid HexDocs package directory\n")
      IO.puts("WARNING: Skipping HexDocs package updating\n")
      token
    end
  end

  @spec active?(Token.t()) :: boolean
  def active?(%Token{hex_docs_dir: hex_docs_dir}) when is_binary(hex_docs_dir) do
    File.dir?(hex_docs_dir)
  end

  def active?(%Token{}), do: false

  @spec do_update_hex_packages(String.t(), [String.t()], %Token{}) :: %Token{}
  def do_update_hex_packages(dir, new_packages, %Token{} = token)
      when is_binary(dir) and is_list(new_packages) do
    IO.puts("changing into hex_docs_dir, '#{dir}'\n")
    :ok = File.cd(dir)
    {:ok, dir_names} = File.ls()

    new_and_existing =
      (dir_names ++ new_packages)
      |> Enum.uniq()
      |> Enum.sort()

    IO.puts("Updating docs for Hex packages #{inspect(new_and_existing, pretty: true)}\n")

    new_and_existing
    |> Enum.reduce(token, fn dir_name, token -> update_hex_docs(dir_name, token) end)
    |> display_no_hex_doc_updates_msg()
  end

  defp update_hex_docs(dir_name, token) do
    {msg, 0} = System.cmd("mix", ["hex.docs", "fetch", dir_name])

    cond do
      msg =~ ~r/Docs already fetched/ ->
        token

      msg == "" ->
        # IO.puts("*** Couldn't find docs for the package '#{dir_name}' ***")
        IO.puts(msg)
        token

      true ->
        IO.puts("updated docs for Hex package '#{dir_name}'")
        updated_hex_docs = [dir_name | token.updated_hex_docs]
        put_in(token.updated_hex_docs, updated_hex_docs)
    end
  end

  defp display_no_hex_doc_updates_msg(%{updated_hex_docs: []} = token) do
    IO.puts("Your Hex package documentation is already up to date\n")
    token
  end

  defp display_no_hex_doc_updates_msg(token), do: token
end
