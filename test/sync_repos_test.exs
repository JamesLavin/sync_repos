defmodule SyncReposTest do
  use ExUnit.Case
  import ExUnit.CaptureIO

  setup do
    initial_dir = File.cwd!()
    File.cwd!()
    on_exit(fn -> File.cd!(initial_dir) end)
  end

  test "git dir" do
    output = capture_io(fn -> SyncRepos.CLI.main(["-d", "./test/support/sync_dir"]) end)
    # IO.inspect(output)
    assert String.match?(output, ~r/sync_dir: \".*\/test\/support\/sync_dir\"/)
    assert output =~ "SyncRepos script completed"
    assert output =~ "Notable repos: []"
  end

  test "updating an unchanged Git repo" do
    # We'll test this using a Git repo I haven't touched in 7 years, JamesLavin/HtmlsToPdf
    output =
      capture_io(fn ->
        SyncRepos.CLI.main(["-d", "./test/support/HtmlsToPdf_sync_dir"])
      end)

    IO.inspect(output, label: "output")

    assert String.match?(output, ~r/---- syncing git@github.com:JamesLavin\/HtmlsToPdf\.git ---/)
    assert output =~ "invalid_dirs: nil"
    assert output =~ "halt: false"

    assert String.match?(
             output,
             ~r/ processed: \[\n.*%{dir: \".*\/test\/support\/git_dir\/HtmlsToPdf\"}\n.*\]/s
           )

    assert output =~ "SyncRepos script completed"
    # TODO: This is actually a bug... New repo should be included:
    # assert output =~ "Notable repos: []"
    assert String.match?(
             output,
             ~r/---- finished syncing git@github.com:JamesLavin\/HtmlsToPdf\.git ---/
           )

    # confirm dir & files exist
    "./README.markdown" |> Path.expand() |> IO.inspect() |> File.exists?() |> assert
    assert File.exists?("./htmls_to_pdf.gemspec")
    assert File.dir?("./examples")
    assert File.dir?("./lib")
    assert File.exists?("./lib/htmls_to_pdf.rb")

    # remove temp test directory
    :ok = ".." |> Path.expand() |> File.cd()
    System.cmd("rm", ["-rf", "HtmlsToPdf"])
  end

  test "invalid Git repos" do
    output =
      capture_io(fn ->
        catch_exit(SyncRepos.CLI.main(["-d", "./test/support/invalid_git_dirs"]))
      end)

    # IO.inspect(output)

    assert output =~
             "*** ERROR: SyncRepos terminated because the config file specifies one or more invalid :git directories, '[\"Joe/Smith/Bob\", \"wyle_e_coyote\"]' ***"
  end

  test "invalid sync_dir" do
    output =
      capture_io(fn ->
        catch_exit(SyncRepos.CLI.main(["-d", "./test/support/non_existent_sync_dir"]))
      end)

    # IO.inspect(output)

    assert String.match?(
             output,
             ~r/\*\*\* ERROR: SyncRepos terminated because the sync_repos directory \('.*\/test\/support\/non_existent_sync_dir'\) does not exist \*\*\*/
           )
  end

  test "invalid default_git_dir" do
    output =
      capture_io(fn ->
        catch_exit(SyncRepos.CLI.main(["-d", "./test/support/invalid_default_git_dir"]))
      end)

    assert output =~
             "*** ERROR: SyncRepos terminated because the config file specifies an invalid :default_git_dir, 'not_a_real_dir' ***"
  end
end
