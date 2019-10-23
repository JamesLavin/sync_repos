defmodule SyncRepos.Git do
  alias SyncRepos.Github

  @successful_pull_msg "Successfully pulled new changes from master"
  @no_remote_changes_msg "No new changes on master"

  def sync(%{halt: true} = token), do: token

  def sync(%{to_process: []} = token), do: token

  def sync(%{to_process: [dir | more_dirs]} = token) do
    IO.puts("----- syncing #{display(dir)} -----")

    new_token =
      token
      |> Map.put(:to_process, more_dirs)
      |> Map.put(:processing, %{dir: dir, halt: false})
      |> Github.create_missing_github_dir()
      |> cd_to_git_dir()
      |> get_branch()
      |> halt_unless_master()
      # |> ls_files()
      |> git_status()

    new_token =
      new_token
      |> Map.put(:processed, [new_token[:processing] | new_token[:processed]])
      |> Map.put(:processing, nil)

    IO.puts("----- finished syncing #{display(dir)} -----")
    IO.puts("")
    sync(new_token)
  end

  defp cd_to_git_dir(%{processing: %{dir: dir}} = token) when is_binary(dir) do
    :ok = File.cd(dir)
    token
  end

  defp cd_to_git_dir(%{processing: %{dir: %Github{local_dir: dir}}} = token)
       when is_binary(dir) do
    :ok = File.cd(dir)
    token
  end

  defp ls_files(token) do
    {:ok, files} = File.ls()
    files |> IO.puts()
    token
  end

  defp get_branch(token) do
    {branch, 0} = System.cmd("git", ["rev-parse", "--abbrev-ref", "HEAD"])

    token
    |> put_in([:processing, :branch], branch |> String.trim())
  end

  defp halt_unless_master(%{processing: %{branch: "master"}} = token) do
    token
  end

  defp halt_unless_master(%{processing: %{branch: branch}} = token) do
    token
    |> put_in([:processing, :halt], true)
    |> put_in(
      [:processing, :halt_reason],
      "*** FAILURE: Branch '#{branch}' is currently checked out ***"
    )
  end

  defp git_status(token) do
    {status_string, 0} = System.cmd("git", ["status"])
    # status_string |> IO.inspect(label: "status_string")

    token
    |> put_in([:processing, :status], status_string)
    |> fail_if_unstaged_changes()
    |> fail_if_uncommitted_changes()
    |> pull_and_rebase_changes()
    |> push_if_ahead_of_master()
  end

  defp fail_if_unstaged_changes(%{processing: %{halt: true}} = token), do: token

  defp fail_if_unstaged_changes(%{processing: %{status: status_string}} = token)
       when is_binary(status_string) do
    new_token =
      case Regex.match?(~r/Changes not staged for commit:/, status_string) do
        true ->
          msg = "*** FAILURE: Cannot sync because Git repo has unstaged changes ***"
          IO.puts(msg)

          put_in(token, [:processing, :halt], true)
          |> put_in([:processing, :halt_reason], msg)

        false ->
          token
      end

    new_token
  end

  defp fail_if_uncommitted_changes(%{processing: %{halt: true}} = token), do: token

  defp fail_if_uncommitted_changes(%{processing: %{status: status_string}} = token)
       when is_binary(status_string) do
    new_token =
      case Regex.match?(~r/Changes to be committed:/, status_string) do
        true ->
          msg = "*** FAILURE: Cannot sync because Git repo has staged, uncommitted changes ***"
          IO.puts(msg)

          put_in(token, [:processing, :halt], true)
          |> put_in([:processing, :halt_reason], msg)

        false ->
          token
      end

    new_token
  end

  defp push_if_ahead_of_master(%{processing: %{halt: true}} = token), do: token

  defp push_if_ahead_of_master(%{processing: %{status: status_string}} = token)
       when is_binary(status_string) do
    case Regex.match?(~r/Your branch is ahead of 'origin\/master'/, status_string) do
      true ->
        IO.puts("  *** Pushing changes to remote repo ***")
        push_changes(token)

      false ->
        # IO.puts("No need to push changes")
        token
    end
  end

  defp push_changes(%{processing: %{halt: true}} = token), do: token

  defp push_changes(token) do
    System.cmd("git", ["push", "origin", "master"])
    put_in(token, [:processing, :changes_pushed], true)
  end

  defp pull_and_rebase_changes(%{processing: %{halt: true}} = token), do: token

  defp pull_and_rebase_changes(%{processing: %{status: status_string}} = token)
       when is_binary(status_string) do
    {pull_rebase_output, exit_code} = System.cmd("git", ["pull", "--rebase", "origin", "master"])

    new_token =
      token
      |> put_in([:processing, :pull_rebase_output], pull_rebase_output)
      |> put_in([:processing, :pull_rebase_exit_code], exit_code)

    handle_pull_and_rebase_changes_output(new_token, exit_code)
  end

  defp handle_pull_and_rebase_changes_output(%{processing: %{halt: true}} = token, _exit_code),
    do: token

  defp handle_pull_and_rebase_changes_output(token, 0) do
    output = token[:processing][:pull_rebase_output]

    cond do
      # ~r/.../s is `dotall`, which  "causes dot to match newlines and also set newline to anycrlf"
      Regex.match?(~r/Updating.*Fast-forward/s, output) ->
        IO.puts(@successful_pull_msg)
        put_in(token, [:processing, :changes_pulled], true)

      Regex.match?(~r/Fast-forwarded master to/s, output) ->
        IO.puts(@successful_pull_msg)
        put_in(token, [:processing, :changes_pulled], true)

      Regex.match?(~r/rewinding head to replay your work/, output) ->
        IO.puts(@successful_pull_msg)
        put_in(token, [:processing, :changes_pulled], true)

      Regex.match?(~r/Already up to date/, output) ->
        put_in(token, [:processing, :info], @no_remote_changes_msg)

      Regex.match?(~r/Current branch master is up to date/, output) ->
        put_in(token, [:processing, :info], @no_remote_changes_msg)

      true ->
        msg = "*** WARNING: Something unexpected happened: #{output} ***"
        IO.puts(msg)

        put_in(token, [:processing, :halt], true)
        |> put_in([:processing, :halt_reason], msg)
    end
  end

  defp handle_pull_and_rebase_changes_output(token, _failure_exit_code) do
    output = token[:processing][:pull_rebase_output]

    new_token =
      cond do
        # ~r/.../s is `dotall`, which  "causes dot to match newlines and also set newline to anycrlf"
        Regex.match?(~r/Auto-merging.*CONFLICT/s, output) ->
          msg =
            "*** WARNING: Attempted 'git pull --rebase origin master', but there is a conflict"

          IO.puts(msg)

          put_in(token, [:processing, :halt_reason], msg)
          |> put_in([:processing, :changes_pulled], true)

        true ->
          msg = "*** WARNING: Something unexpected happened: #{output} ***"
          IO.puts(msg)
          put_in(token, [:processing, :halt_reason], msg)
      end

    put_in(new_token, [:processing, :halt], true)
  end

  defp display(dir) when is_binary(dir), do: dir
  defp display(%Github{local_dir: dir}) when is_binary(dir), do: dir

  # defp pull_if_behind_master(status_string) when is_binary(status_string) do
  #   case Regex.match?(~r/Your branch is ahead of 'origin\/master'/, status_string) do
  #     true -> IO.puts("Pushing changes"); push_changes()
  #     false -> IO.puts("No need to push changes")
  #   end
  #   status_string
  # end
end
