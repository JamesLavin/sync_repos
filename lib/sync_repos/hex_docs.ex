defmodule SyncRepos.HexDocs do
  def sync(%{hex_docs_dir: dir} = token) when is_binary(dir) do
    update_hex_packages(dir, token)
  end

  def sync(token), do: token

  defp update_hex_packages(dir, token) do
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
      updated_hex_docs = [dir_name | token[:updated_hex_docs]]
      %{token | updated_hex_docs: updated_hex_docs}
    end
  end

  defp display_no_hex_doc_updates_msg(%{updated_hex_docs: []} = token) do
    IO.puts("Your Hex package documentation is already up to date\n")
    token
  end

  defp display_no_hex_doc_updates_msg(token), do: token
end
