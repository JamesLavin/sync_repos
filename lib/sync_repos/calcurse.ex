defmodule SyncRepos.Calcurse do
  @calcurse_dir "/Users/jameslavin/.calcurse"

  def sync(args) do
    IO.inspect("*** syncing Calcurse ***")

    new_args =
      args
      |> Map.merge(%{calcurse_dir: @calcurse_dir})
      |> cd_to_calcurse_dir()
      # |> ls_files()
      |> git_status()

    IO.inspect("*** finished syncing Calcurse ***")
    new_args
  end

  defp cd_to_calcurse_dir(args) do
    :ok = File.cd(args[:calcurse_dir])
    # File.cwd() |> IO.inspect()
    args
  end

  defp ls_files(args) do
    {:ok, files} = File.ls()
    files |> IO.inspect()
    args
  end

  defp git_status(args) do
    {status_string, 0} = System.cmd("git", ["status"])
    # status_string |> IO.inspect(label: "status_string")

    args
    |> Map.merge(%{status: status_string})
    |> fail_if_unstaged_changes()
    |> fail_if_uncommitted_changes()
    |> pull_and_rebase_changes()
    |> push_if_ahead_of_master()
  end

  defp fail_if_unstaged_changes(%{halt: true} = args), do: args

  defp fail_if_unstaged_changes(%{status: status_string} = args) when is_binary(status_string) do
    new_args =
      case Regex.match?(~r/Changes not staged for commit:/, status_string) do
        true ->
          IO.inspect("FAILURE: Cannot sync because Calcurse has unstaged changes in Git")
          %{args | halt: true}

        false ->
          args
      end

    new_args
  end

  defp fail_if_uncommitted_changes(%{halt: true} = args), do: args

  defp fail_if_uncommitted_changes(%{status: status_string} = args)
       when is_binary(status_string) do
    new_args =
      case Regex.match?(~r/Changes to be committed:/, status_string) do
        true ->
          IO.inspect(
            "FAILURE: Cannot sync because Calcurse has staged, uncommitted changes in Git"
          )

          %{args | halt: true}

        false ->
          args
      end

    new_args
  end

  defp push_if_ahead_of_master(%{halt: true} = args), do: args

  defp push_if_ahead_of_master(%{status: status_string} = args) when is_binary(status_string) do
    case Regex.match?(~r/Your branch is ahead of 'origin\/master'/, status_string) do
      true ->
        IO.inspect("*** Pushing changes to remote repo ***")
        push_changes(args)

      false ->
        IO.inspect("No need to push changes")
        args
    end
  end

  defp push_changes(%{halt: true} = args), do: args

  defp push_changes(args) do
    System.cmd("git", ["push", "origin", "master"])
    %{args | changes_pushed: true}
  end

  defp pull_and_rebase_changes(%{halt: true} = args), do: args

  defp pull_and_rebase_changes(%{status: status_string} = args) when is_binary(status_string) do
    {pull_rebase_output, exit_code} = System.cmd("git", ["pull", "--rebase", "origin", "master"])

    new_args =
      Map.put(args, :pull_rebase_output, pull_rebase_output)
      |> Map.put(:pull_rebase_exit_code, exit_code)

    handle_pull_and_rebase_changes_output(new_args, exit_code)
  end

  defp handle_pull_and_rebase_changes_output(%{halt: true} = args, _exit_code), do: args

  defp handle_pull_and_rebase_changes_output(args, 0) do
    cond do
      Regex.match?(~r/Updating.*Fast-forward/, args[:pull_rebase_output]) ->
        IO.inspect("Successfully pulled new changes from master")
        args

      Regex.match?(~r/Already up to date/, args[:pull_rebase_output]) ->
        IO.inspect("No new changes on master")
        args

      Regex.match?(~r/Current branch master is up to date/, args[:pull_rebase_output]) ->
        IO.inspect("No new changes on master")
        args

      true ->
        IO.inspect("*** WARNING: Something unexpected happened: #{args[:pull_rebase_output]} ***")
        %{args | halt: true}
    end
  end

  defp handle_pull_and_rebase_changes_output(args, _failure_exit_code) do
    cond do
      # ~r/.../s is `dotall`, which  "causes dot to match newlines and also set newline to anycrlf"
      Regex.match?(~r/Auto-merging.*CONFLICT/s, args[:pull_rebase_output]) ->
        IO.inspect(
          "*** WARNING: Attempted 'git pull --rebase origin master', but there is a conflict"
        )

      true ->
        IO.inspect("*** WARNING: Something unexpected happened: #{args[:pull_rebase_output]} ***")
    end

    %{args | halt: true}
  end

  # defp pull_if_behind_master(status_string) when is_binary(status_string) do
  #   case Regex.match?(~r/Your branch is ahead of 'origin\/master'/, status_string) do
  #     true -> IO.inspect("Pushing changes"); push_changes()
  #     false -> IO.inspect("No need to push changes")
  #   end
  #   status_string
  # end
end
