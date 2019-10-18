defmodule SyncRepos.Validator do
  def exit_if_invalid_sync_dir(token) do
    sync_dir = token[:sync_dir]

    if !File.dir?(token[:sync_dir]) do
      display_sync_dir_error_and_terminate(token)
    end

    token
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
