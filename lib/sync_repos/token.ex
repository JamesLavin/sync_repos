defmodule SyncRepos.Token do
  def new do
    %{
      default_git_dir: nil,
      sync_dir: "~/.sync_repos",
      halt: false,
      to_process: [],
      processing: nil,
      processed: [],
      invalid_dirs: nil
    }
  end
end
