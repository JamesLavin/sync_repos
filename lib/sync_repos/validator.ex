defmodule SyncRepos.Validator do
  def exit_if_invalid_sync_dir(token) do
    sync_dir = token[:sync_dir] |> Path.expand()

    if File.dir?(sync_dir) do
      token
    else
      display_sync_dir_error_and_terminate(token)
    end
  end

  def exit_if_invalid_default_git_dir(%{default_git_dir: nil} = token), do: token

  def exit_if_invalid_default_git_dir(%{default_git_dir: default_git_dir} = token) do
    dgd = default_git_dir |> Path.expand()

    case File.dir?(dgd) do
      true -> %{token | default_git_dir: dgd}
      false -> display_default_git_dir_error_and_terminate(token)
    end
  end

  def exit_if_any_invalid_to_process_dirs(%{to_process: dirs} = token) do
    invalid = invalid_dirs(dirs)

    case invalid do
      [] -> token
      [_ | _] -> %{token | invalid_dirs: invalid} |> display_invalid_dir_error_and_terminate()
    end
  end

  defp invalid_dirs(dirs) do
    dirs
    |> Enum.filter(&invalid_dir/1)
    |> Enum.map(fn {:invalid, dir} -> dir end)
  end

  defp invalid_dir({:invalid, _path}), do: true
  defp invalid_dir(_path), do: false

  defp display_invalid_dir_error_and_terminate(token) do
    IO.puts("")

    IO.puts(
      "*** ERROR: SyncRepos terminated because the config file specifies one or more invalid :git directories, '#{
        inspect(token[:invalid_dirs])
      }' ***"
    )

    # NOTE: I want to use System.halt(0) but don't know how to test it
    #       I think I could test this by using mock to replace System.halt(0) with exit(:normal)
    exit(:normal)
    # System.halt(0)
  end

  defp display_default_git_dir_error_and_terminate(token) do
    IO.puts("")

    IO.puts(
      "*** ERROR: SyncRepos terminated because the config file specifies an invalid :default_git_dir, '#{
        token[:default_git_dir]
      }' ***"
    )

    # NOTE: I want to use System.halt(0) but don't know how to test it
    #       I think I could test this by using mock to replace System.halt(0) with exit(:normal)
    exit(:normal)
    # System.halt(0)
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

    # NOTE: I want to use System.halt(0) but don't know how to test it
    #       I think I could test this by using mock to replace System.halt(0) with exit(:normal)
    exit(:normal)
    # System.halt(0)
  end
end
