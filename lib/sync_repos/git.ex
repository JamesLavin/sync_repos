defmodule SyncRepos.Git do
  alias SyncRepos.{Github, Token, ValidRepoDir}

  @successful_pull_msg "Successfully pulled new changes from master"
  @no_remote_changes_msg "No new changes on master"

  @spec sync(Token.t()) :: Token.t()
  def sync(%Token{only_hex: true} = token), do: token
  def sync(%Token{halt: true} = token), do: token

  def sync(%Token{to_process: []} = token), do: token

  def sync(%Token{to_process: [dir | more_dirs]} = token) do
    IO.puts("----- syncing #{display(dir)} -----")

    new_token =
      token
      |> Map.put(:to_process, more_dirs)
      |> Map.put(:processing, %{dir: dir, halt: false})
      |> Github.create_missing_github_dir()
      |> cd_to_git_dir()
      |> get_branch()
      |> halt_unless_master()
      |> git_status()

    new_processed = [new_token.processing | new_token.processed]
    new_token = put_in(new_token.processed, new_processed)
    new_token = put_in(new_token.processing, nil)

    IO.puts("----- finished syncing #{display(dir)} -----")
    IO.puts("")
    sync(new_token)
  end

  @spec cd_to_git_dir(%Token{processing: %{dir: ValidRepoDir.t()}}) :: %Token{
          processing: %{dir: ValidRepoDir.t()}
        }
  def cd_to_git_dir(%Token{processing: %{dir: %Github{local_dir: dir}}} = token)
      when is_binary(dir) do
    :ok = File.cd(dir)
    token
  end

  def cd_to_git_dir(%Token{processing: %{dir: dir}} = token) when is_binary(dir) do
    :ok = File.cd(dir)
    token
  end

  def cd_to_git_dir(%Token{processing: %{dir: {:invalid, _dir}}}) do
    exit(:invalid_directory)
  end

  defp get_branch(token) do
    {branch, 0} = System.cmd("git", ["rev-parse", "--abbrev-ref", "HEAD"])

    new_branch = branch |> String.trim()
    new_processing = token.processing |> Map.put_new(:branch, new_branch)
    put_in(token.processing, new_processing)
  end

  defp halt_unless_master(%{processing: %{branch: "master"}} = token) do
    token
  end

  defp halt_unless_master(%{processing: %{branch: branch}} = token) do
    new_processing =
      token.processing
      |> Map.put_new(:halt, true)
      |> Map.put_new(
        :halt_reason,
        "*** FAILURE: Branch '#{branch}' is currently checked out ***"
      )

    put_in(token.processing, new_processing)
  end

  defp git_status(token) do
    {status_string, 0} = System.cmd("git", ["status"])
    # status_string |> IO.inspect(label: "status_string")

    new_processing =
      token.processing
      |> Map.put_new(:status, status_string)

    token = put_in(token.processing, new_processing)

    token
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
          halt_with_msg(token, msg)

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
          halt_with_msg(token, msg)

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
    new_processing = token.processing |> Map.put_new(:changes_pushed, true)
    put_in(token.processing, new_processing)
  end

  defp pull_and_rebase_changes(%{processing: %{halt: true}} = token), do: token

  defp pull_and_rebase_changes(%{processing: %{status: status_string}} = token)
       when is_binary(status_string) do
    {pull_rebase_output, exit_code} = System.cmd("git", ["pull", "--rebase", "origin", "master"])

    new_processing =
      token.processing
      |> Map.put_new(:pull_rebase_output, pull_rebase_output)
      |> Map.put_new(:pull_rebase_exit_code, exit_code)

    new_token = put_in(token.processing, new_processing)

    handle_pull_and_rebase_changes_output(new_token, exit_code)
  end

  defp handle_pull_and_rebase_changes_output(%{processing: %{halt: true}} = token, _exit_code),
    do: token

  defp handle_pull_and_rebase_changes_output(token, 0) do
    output = token.processing[:pull_rebase_output]

    cond do
      # ~r/.../s is `dotall`, which  "causes dot to match newlines and also set newline to anycrlf"
      Regex.match?(~r/Updating.*Fast-forward/s, output) ->
        IO.puts(@successful_pull_msg)
        update_with_changes_pulled(token)

      Regex.match?(~r/Fast-forwarded master to/s, output) ->
        IO.puts(@successful_pull_msg)
        update_with_changes_pulled(token)

      Regex.match?(~r/rewinding head to replay your work/, output) ->
        IO.puts(@successful_pull_msg)
        update_with_changes_pulled(token)

      Regex.match?(~r/Already up to date/, output) ->
        update_with_no_remote_changes(token)

      Regex.match?(~r/Current branch master is up to date/, output) ->
        update_with_no_remote_changes(token)

      true ->
        msg = "*** WARNING: Something unexpected happened: #{output} ***"
        halt_with_msg(token, msg)
    end
  end

  defp handle_pull_and_rebase_changes_output(token, _failure_exit_code) do
    output = token.processing[:pull_rebase_output]

    cond do
      # ~r/.../s is `dotall`, which  "causes dot to match newlines and also set newline to anycrlf"
      Regex.match?(~r/Auto-merging.*CONFLICT/s, output) ->
        msg = "*** WARNING: Attempted 'git pull --rebase origin master', but there is a conflict"

        IO.puts(msg)

        new_processing =
          token.processing
          |> Map.put_new(:halt_reason, msg)
          |> Map.put_new(:halt, true)
          |> Map.put_new(:changes_pulled, true)

        put_in(token.processing, new_processing)

      true ->
        msg = "*** WARNING: Something unexpected happened: #{output} ***"
        halt_with_msg(token, msg)
    end
  end

  defp display(dir) when is_binary(dir), do: dir
  defp display(%Github{local_dir: dir}) when is_binary(dir), do: dir

  defp update_with_changes_pulled(token) do
    new_processing = Map.put(token.processing, :changes_pulled, true)
    put_in(token.processing, new_processing)
  end

  defp update_with_no_remote_changes(token) do
    new_processing = Map.put(token.processing, :info, @no_remote_changes_msg)
    put_in(token.processing, new_processing)
  end

  defp halt_with_msg(token, msg) do
    IO.puts(msg)

    new_processing =
      token.processing
      |> Map.put_new(:halt, true)
      |> Map.put_new(:halt_reason, msg)

    put_in(token.processing, new_processing)
  end

  # defp pull_if_behind_master(status_string) when is_binary(status_string) do
  #   case Regex.match?(~r/Your branch is ahead of 'origin\/master'/, status_string) do
  #     true -> IO.puts("Pushing changes"); push_changes()
  #     false -> IO.puts("No need to push changes")
  #   end
  #   status_string
  # end
end
