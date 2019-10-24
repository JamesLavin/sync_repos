defmodule SyncRepos.HexDocs do
  alias SyncRepos.Token

  @spec sync(Token.t()) :: Token.t()
  def sync(%Token{hex_docs_dir: dir} = token) when is_binary(dir) do
    if File.dir?(dir) do
      update_hex_packages(dir, token)
    else
      IO.puts("WARNING: '#{dir}' is not a valid HexDocs package directory\n")
      IO.puts("WARNING: Skipping HexDocs package updating\n")
      token
    end
  end

  def sync(%Token{} = token), do: token

  @spec active?(Token.t()) :: boolean
  def active?(%Token{hex_docs_dir: hex_docs_dir}) when is_binary(hex_docs_dir) do
    File.dir?(hex_docs_dir)
  end

  def active?(%Token{}), do: false

  @spec update_hex_packages(String.t(), %Token{}) :: %Token{}
  def update_hex_packages(dir, token) do
    IO.puts("changing into hex_docs_dir, '#{dir}'\n")
    :ok = File.cd(dir)
    {:ok, dir_names} = File.ls()
    IO.puts("Updating docs for Hex packages #{inspect(dir_names, pretty: true)}\n")

    dir_names
    |> Enum.reduce(token, fn dir_name, token -> update_hex_docs(dir_name, token) end)
    |> display_no_hex_doc_updates_msg()
  end

  defp update_hex_docs(dir_name, token) do
    {msg, 0} = System.cmd("mix", ["hex.docs", "fetch", dir_name])

    if msg =~ "Docs already fetched" do
      token
    else
      IO.puts("updating docs for Hex package '#{dir_name}'")
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
