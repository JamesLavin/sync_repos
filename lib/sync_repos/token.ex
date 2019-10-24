defmodule SyncRepos.Token do
  alias SyncRepos.Github

  defstruct [
    :default_git_dir,
    :hex_docs_dir,
    :sync_dir,
    :halt,
    :notable_repos,
    :to_process,
    :processing,
    :processed,
    :invalid_dirs,
    :updated_hex_docs,
    :timestamp
  ]

  # TODO: Make a type for the map()
  @type t() :: %__MODULE__{
          default_git_dir: nil | String.t(),
          hex_docs_dir: nil | String.t(),
          sync_dir: String.t(),
          halt: boolean(),
          notable_repos: [String.t()],
          to_process: [map()],
          processing: nil | map(),
          processed: [map()],
          invalid_dirs: [String.t()],
          updated_hex_docs: [String.t()],
          timestamp: nil | String.t()
        }

  def new do
    %__MODULE__{
      default_git_dir: nil,
      hex_docs_dir: nil,
      sync_dir: "~/.sync_repos",
      halt: false,
      notable_repos: [],
      to_process: [],
      processing: nil,
      processed: [],
      invalid_dirs: [],
      updated_hex_docs: [],
      timestamp: ""
    }
  end
end
