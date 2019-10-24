defmodule SyncRepos.HexDocs do
  def sync(%{hex_docs_dir: dir} = token) when is_binary(dir) do
    update_hex_packages(dir)
    token
  end

  def sync(token), do: token

  defp update_hex_packages(dir) do
    IO.puts("changing into hex_docs_dir, '#{dir}'\n")
    :ok = File.cd(dir)
    {:ok, dir_names} = File.ls()
    IO.puts("Updating docs for Hex packages #{inspect(dir_names, pretty: true)}\n")
    Enum.each(dir_names, &update_hex_docs/1)
  end

  defp update_hex_docs(dir_name) do
    {msg, 0} = System.cmd("mix", ["hex.docs", "fetch", dir_name])

    unless msg =~ "Docs already fetched" do
      IO.inspect("updating docs for Hex package '#{dir_name}'")
    end
  end
end
