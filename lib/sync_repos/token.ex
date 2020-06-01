defmodule SyncRepos.Token do
  alias SyncRepos.ValidRepoDir

  defstruct all_the_things: false,
            debug: false,
            default_git_dir: nil,
            fetch_master: false,
            halt: false,
            hex_docs_dir: nil,
            hexdoc_packages: [],
            invalid_dirs: [],
            notable_repos: [],
            processing: nil,
            processed: [],
            rebase_push_head: false,
            sync_dir: "~/.sync_repos",
            sync_git: false,
            sync_hex: false,
            timestamp: "",
            to_process: [],
            updated_hex_docs: []

  @type t() :: %__MODULE__{
          all_the_things: boolean(),
          debug: boolean(),
          default_git_dir: nil | String.t(),
          fetch_master: boolean(),
          halt: boolean(),
          hex_docs_dir: nil | String.t(),
          hexdoc_packages: [String.t()],
          invalid_dirs: [String.t()],
          notable_repos: [String.t()],
          processing: nil | ValidRepoDir.t(),
          processed: [ValidRepoDir.t()],
          pull_master: boolean(),
          rebase_push_head: boolean(),
          sync_dir: String.t(),
          sync_git: boolean(),
          sync_hex: boolean(),
          timestamp: nil | String.t(),
          to_process: [ValidRepoDir.t()],
          updated_hex_docs: [String.t()]
        }

  # def new do
  #   %__MODULE__{
  #     debug: false,
  #     default_git_dir: nil,
  #     fetch_master: true,
  #     halt: false,
  #     hex_docs_dir: nil,
  #     hexdoc_packages: [],
  #     invalid_dirs: [],
  #     notable_repos: [],
  #     processing: nil,
  #     processed: [],
  #     pull_master: false,
  #     rebase_push_head: false,
  #     sync_dir: "~/.sync_repos",
  #     sync_git: true,
  #     sync_hex: true,
  #     timestamp: "",
  #     to_process: [],
  #     updated_hex_docs: []
  #   }
  # end
end
