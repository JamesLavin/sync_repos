defmodule SyncReposTest do
  use ExUnit.Case
  import ExUnit.CaptureIO

  test "git dir" do
    output = capture_io(fn -> SyncRepos.CLI.main(["-d", "./test/support/sync_dir"]) end)
    assert output =~ "sync_dir: \"./test/support/sync_dir\""
    assert output =~ "SyncRepos script completed"
    assert output =~ "Notable repos: []"
  end

  # test "unchanged Git repo" do
  #   # We'll test this using a Git repo I haven't touched in 7 years, JamesLavin/HtmlsToPdf
  #   output =
  #     capture_io(fn ->
  #       catch_exit(SyncRepos.CLI.main(["-d", "./test/support/HtmlsToPdf_sync_dir"]))
  #     end)

  #   assert output =~
  #            "*** ERROR: SyncRepos terminated because the config file specifies one or more invalid :git directories, '[\"Joe/Smith/Bob\", \"wyle_e_coyote\"]' **"

  #   assert output =~ "sync_dir: \"./test/support/HtmlsToPdf_sync_dir\""
  #   assert output =~ "invalid_dirs: [\"Joe/Smith/Bob\", \"wyle_e_coyote\"]"
  # end

  test "invalid Git repos" do
    output =
      capture_io(fn ->
        catch_exit(SyncRepos.CLI.main(["-d", "./test/support/invalid_git_dirs"]))
      end)

    assert output =~
             "*** ERROR: SyncRepos terminated because the config file specifies one or more invalid :git directories, '[\"Joe/Smith/Bob\", \"wyle_e_coyote\"]' **"
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
