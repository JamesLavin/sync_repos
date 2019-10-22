defmodule SyncReposTest do
  use ExUnit.Case
  import ExUnit.CaptureIO

  test "git dir" do
    output = capture_io(fn -> SyncRepos.CLI.main(["-d", "./test/support/sync_dir"]) end)
    assert output =~ "sync_dir: \"./test/support/sync_dir\""
    assert output =~ "SyncRepos script completed"
    assert output =~ "Notable repos: []"
  end

  test "invalid sync_dir" do
    output =
      capture_io(fn ->
        catch_exit(SyncRepos.CLI.main(["-d", "./test/support/non_existent_sync_dir"]))
      end)

    assert output =~
             "*** ERROR: SyncRepos terminated because the sync_repos directory ('./test/support/non_existent_sync_dir') does not exist ***"

    output
  end

  test "invalid default_git_dir" do
    output =
      capture_io(fn ->
        catch_exit(SyncRepos.CLI.main(["-d", "./test/support/invalid_default_git_dir"]))
      end)

    assert output =~
             "*** ERROR: SyncRepos terminated because the config file specifies an invalid :default_git_dir, 'not_a_real_dir' ***"

    output
  end
end
