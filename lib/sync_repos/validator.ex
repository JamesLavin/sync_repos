defmodule SyncRepos.Validator do
  def exit_if_invalid_sync_dir(token) do
    sync_dir = token[:sync_dir] |> Path.expand() |> IO.inspect()

    if File.dir?(sync_dir) do
      token
    else
      display_sync_dir_error_and_terminate(token)
    end
  end

  defp display_sync_dir_error_and_terminate(token) do
    IO.puts("")

    IO.puts(
      "*** ERROR: SyncRepos terminated because the sync_repos directory ('#{token[:sync_dir]}') does not exist ***"
    )

    IO.puts("SyncRepo's default directory is ~/.sync_repos")

    IO.puts(
      "You can specify an alternative SyncRepo directory by calling '~/.sync_repos --sync-dir ~/my_sync_dir'"
    )

    IO.puts(
      "You can also specify an alternative directory by calling '~/.sync_repos -d ~/my_sync_dir'"
    )

    System.halt(0)
  end
end
