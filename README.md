# SyncRepos

Keep all your local `Git` repos in sync with remote `Git` repos by running a single command (which you can run periodically in a `cron` job if you want)

## Usage

1) Create a `~/.sync_repos` directory.

2) Create a `~/.sync_repos/config` YAML file specifying the `Git` directories on your local machine that you wish to keep synched up with remote `Git` repos, like this:

```
git:
  - ~/Git/absinthe
  - ~/Git/ecto
  - ~/Git/elixir
  - ~/Git/phoenix
  - ~/.calcurse
  - ~/Git/sync_repos
```

3) Run `./sync_repos` to sync all your Git repos. (If you want full debugging output, run `./sync_repos --debug`.)

4) To view the log file produced by any `SyncRepos` run, visit `~/.sync_repos/logs/`. Log files are timestamped like `~/.sync_repos/logs/sync_repos_20191017133716`

NOTE: The current behavior is to halt on the first failure, but I intend to change the default behavior to attempt to sync each repo, regardless of what happens while attempting to sync other repos.

NOTE: This should work on Linux & Mac machines. I have no idea about Windows.

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `sync_repos` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:sync_repos, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/sync_repos](https://hexdocs.pm/sync_repos).

## IDEAS FOR FUTURE

* Improve documentation
* Upload to Hex
* Add option to use non-standard file location
* Add option to process remaining unprocessed repos on failure in single repo (should probably be default) by making `:halt` a repo-level value
* Default output should be a summary of the full `--debug` output
* Add option to suppress attempts to `git pull --rebase`
* Currently assumes master branch is checked out: Check this assumption before pulling.
* Currently assumes master branch is checked out: Make this work with non-master branches
* Option to suppress save only the latest log file (or keep only the last N log files), rather than saving all logs?