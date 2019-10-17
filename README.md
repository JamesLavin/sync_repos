# SyncRepos

Keep all your local `Git` repos in sync with remote `Git` repos by running a single command (which you can run periodically in a `cron` job if you want).

`SyncRepos` will attempt to pull down remote changes and -- if your local repo has unpushed commits -- rebase your local unpushed commits on top of the remote branch, then push your changes up to the remote repo.

## Usage

**WARNING**: `SyncRepos` currently works only with `master` Git branches. *Don't add a repo to `~/.sync_repos/config` unless you have the `master` branch checked out.* (I hope to generalize this in the future.)

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

3) Run `./sync_repos` to sync all your Git repos. (If you want full debugging output, run `./sync_repos --debug`.) You will see output like the following:

```
Jamess-MacBook-Pro:sync_repos jameslavin$ ./sync_repos
----- syncing /Users/jameslavin/Git/absinthe -----
From github.com:absinthe-graphql/absinthe
 * branch            master     -> FETCH_HEAD
----- finished syncing /Users/jameslavin/Git/absinthe -----

----- syncing /Users/jameslavin/Git/commanded -----
From github.com:commanded/commanded
 * branch            master     -> FETCH_HEAD
----- finished syncing /Users/jameslavin/Git/commanded -----

----- syncing /Users/jameslavin/Git/conduit -----
From github.com:slashdotdash/conduit
 * branch            master     -> FETCH_HEAD
----- finished syncing /Users/jameslavin/Git/conduit -----

----- syncing /Users/jameslavin/Git/ecto -----
From github.com:elixir-ecto/ecto
 * branch              master     -> FETCH_HEAD
----- finished syncing /Users/jameslavin/Git/ecto -----

----- syncing /Users/jameslavin/Git/elixir -----
From github.com:elixir-lang/elixir
 * branch                master     -> FETCH_HEAD
----- finished syncing /Users/jameslavin/Git/elixir -----

----- syncing /Users/jameslavin/Git/eventstore -----
From github.com:commanded/eventstore
 * branch            master     -> FETCH_HEAD
----- finished syncing /Users/jameslavin/Git/eventstore -----

----- syncing /Users/jameslavin/Git/guardian -----
From github.com:ueberauth/guardian
 * branch            master     -> FETCH_HEAD
----- finished syncing /Users/jameslavin/Git/guardian -----

----- syncing /Users/jameslavin/Git/phoenix -----
From github.com:phoenixframework/phoenix
 * branch              master     -> FETCH_HEAD
----- finished syncing /Users/jameslavin/Git/phoenix -----

----- syncing /Users/jameslavin/.calcurse -----
From github.com:JamesLavin/calcurse_calendar
 * branch            master     -> FETCH_HEAD
----- finished syncing /Users/jameslavin/.calcurse -----

----- syncing /Users/jameslavin/Git/sync_repos -----
*** FAILURE: Cannot sync because Git repo has unstaged changes ***
----- finished syncing /Users/jameslavin/Git/sync_repos -----

----- syncing /Users/jameslavin/Git/tech_management -----
From github.com:JamesLavin/tech_management
 * branch            master     -> FETCH_HEAD
  *** Pushing changes to remote repo ***
Enumerating objects: 11, done.
Counting objects: 100% (11/11), done.
Delta compression using up to 12 threads
Compressing objects: 100% (6/6), done.
Writing objects: 100% (6/6), 1.16 KiB | 1.16 MiB/s, done.
Total 6 (delta 5), reused 0 (delta 0)
remote: Resolving deltas: 100% (5/5), completed with 5 local objects.
To github.com:JamesLavin/tech_management.git
   5f6bae1..6dc5085  master -> master
----- finished syncing /Users/jameslavin/Git/tech_management -----

%{
  halt: false,
  processed: [
    %{changes_pushed: true, dir: "/Users/jameslavin/Git/tech_management"},
    %{
      dir: "/Users/jameslavin/Git/sync_repos",
      halt_reason: "*** FAILURE: Cannot sync because Git repo has unstaged changes ***"
    },
    %{dir: "/Users/jameslavin/.calcurse"},
    %{dir: "/Users/jameslavin/Git/phoenix"},
    %{dir: "/Users/jameslavin/Git/guardian"},
    %{dir: "/Users/jameslavin/Git/eventstore"},
    %{dir: "/Users/jameslavin/Git/elixir"},
    %{dir: "/Users/jameslavin/Git/ecto"},
    %{dir: "/Users/jameslavin/Git/conduit"},
    %{dir: "/Users/jameslavin/Git/commanded"},
    %{dir: "/Users/jameslavin/Git/absinthe"}
  ],
  processing: nil,
  sync_dir: "~/.sync_repos",
  timestamp: "20191017144242",
  to_process: []
}
```

4) To view the log file produced by any `SyncRepos` run (which contains additional debugging information not displayed by default), visit `~/.sync_repos/logs/`. Log files are timestamped like `~/.sync_repos/logs/sync_repos_20191017133716`

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

* Currently assumes master branch is checked out: Check this assumption before pulling.
* Improve documentation
* Upload to Hex
* Add option to use non-standard file location
* Add option to halt on failure in single repo. (Current default behavior is to attempt to sync every directory, regardless of whether any repo fails)
* Add option to suppress attempts to `git pull --rebase` (option could work globally or on a per-repo basis)
* Currently assumes master branch is checked out: Make this work with non-master branches
* Option to suppress saving all log files and instead save only the latest log file (or the last N log files?)