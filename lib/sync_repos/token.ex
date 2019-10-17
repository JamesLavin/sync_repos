defmodule SyncRepos.Token do
  def new do
    %{
      sync_dir: "~/.sync_repos",
      halt: false,
      to_process: [],
      processing: nil,
      processed: []
    }
  end
end
