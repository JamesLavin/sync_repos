defmodule SyncRepos.Token do
  alias SyncRepos.ValidRepoDir

  defstruct [
    :default_git_dir,
    :hex_docs_dir,
    :sync_dir,
    :halt,
    :hexdoc_packages,
    :notable_repos,
    :only_git,
    :only_hex,
    :to_process,
    :processing,
    :processed,
    :invalid_dirs,
    :updated_hex_docs,
    :timestamp,
    debug: false
  ]

  # TODO: Make a type for the map()
  @type t() :: %__MODULE__{
          default_git_dir: nil | String.t(),
          hex_docs_dir: nil | String.t(),
          sync_dir: String.t(),
          halt: boolean(),
          hexdoc_packages: [String.t()],
          notable_repos: [String.t()],
          only_git: boolean(),
          only_hex: boolean(),
          to_process: [ValidRepoDir.t()],
          processing: nil | ValidRepoDir.t(),
          processed: [ValidRepoDir.t()],
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
      only_git: false,
      only_hex: false,
      to_process: [],
      processing: nil,
      processed: [],
      invalid_dirs: [],
      updated_hex_docs: [],
      timestamp: ""
    }
  end
end
