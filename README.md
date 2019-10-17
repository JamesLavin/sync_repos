# SyncRepos

Keep all your local `Git` repos in sync with remote `Git` repos by running a single command (which you can run periodically in a `cron` job if you want)

## Usage

Create a YAML file specifying the `Git` directories on your local machine that you wish to keep synched up with remote `Git` repos:

```
git:
  - ~/Git/absinthe
  - ~/Git/ecto
  - ~/Git/elixir
  - ~/Git/phoenix
  - ~/.calcurse
  - ~/Git/sync_repos
```



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

## TODO

* Don't hardcode /Users/jameslavin
* Add documentation
* Log output to file (default location should be inside ~/.sync_repos directory? Save all runs with timestamps or just last run?)
* Add option to use non-standard file location
* Add option to process remaining unprocessed repos on failure in single repo (should probably be default) by making `:halt` a repo-level value
* Default output should be a summary of the full `--debug` output
* Add option to suppress attempts to pull --rebase
* Currently assumes master branch is checked out: Check this assumption.
* Currently assumes master branch is checked out: Make this work with non-master branches