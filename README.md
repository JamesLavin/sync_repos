# SyncRepos

With a single command (which you can run periodically in a `cron` job):

1. Keep all your local `Git` repos in sync with their remote counterparts; and,

2. (If you use Elixir) Keep your `Hex` package documentation up to date. (Currently, this pulls down the most recent documentation for any already installed `Hex` packages if you add `hex_docs_dir: ~/.hex/docs/hexpm` to your `~/.sync_repos/config` file. I will add the ability to specify in `config` new packages to pull documentation for.)

## Git Sync Functionality

You can sync any existing repo(s) with their remote Github counterparts by listing the local repos' locations under `git:` in your `~/.sync_repos/config` *YAML* file, as follows:

```
git:
  - ~/Git/my_tech_resources
```

* If a `Git` repo has unstaged or uncommitted work (except in untracked files), `SyncRepos` will skip that repo, leaving it untouched.

* If a `Git` repo is clean, `SyncRepos` will pull down remote changes.

* If a `Git` repo has committed changes that haven't been pushed to Github, `SyncRepos` will pull down any remote commits and rebase your local unpushed commits on top of the latest remote branch. Unless unresolvable merge conflicts arise, `SyncRepos` will then push your changes up to the remote repo. When this happens, you'll see both pulls and pushes for that repo:

* If `SyncRepos` pulls down remote commits and unsuccessfully attempts to rebase your local commits on top (due to an unresolvable merge conflict), it will warn you and leave the repo for you to either resolve the conflicts or revert the unsuccessful merge.

```
  %{
    changes_pulled: true,
    changes_pushed: true,
    dir: "/Users/jameslavin/Git/my_tech_resources"
  }
```

You can also easily clone repos from Github and keep them in sync. To do so, specify a `:default_git_dir` (the root directory where new `Git` directories cloned from Github will be placed) and a list of Github repos in your `~/.sync_repos/config` file, like this:

```
default_git_dir: ~/Git
git:
  - ninenines/cowboy
  - ninenines/ranch
```

`SyncRepos` will then create the `~/Git/cowboy` and `~/Git/ranch` directories and clone `cowboy` and `ranch` into them:

```
  %{
    dir: "/Users/jameslavin/Git/ranch",
    new_repo_location: "/Users/jameslavin/Git/ranch",
    repo_cloned: true
  }
```

Each time `SyncRepos` runs, it displays command-line output and logs richer debugging information in a timestamped log file each time.

##  HexDocs Updating Functionality

If you use Elixir, `SyncRepos` will also keep your `Hex` package documentation up to date. (Currently, this pulls down the most recent documentation for any already installed `Hex` packages if you add `hex_docs_dir: ~/.hex/docs/hexpm` to your `~/.sync_repos/config` file. I will add the ability to specify in `config` new packages to pull documentation for.)

If you put into your `~/.sync_repos/config` file something like:

```
hex_docs_dir: ~/.hex/docs/hexpm
hexdoc_packages:
  - telemetry_metrics
  - plug
  - cors_plug
```

At the end of `SyncRepo`'s output, you should see something like:

```
Updated Hex package docs: ["telemetry_metrics", "plug", "cors_plug"]
```

Also, if a newer version of that package's documentation is ever published to HexDocs, `SyncRepos` will automatically pull it down for you.

## Why Did You Automate Something That Takes Seconds? Are You Stupid?

Updating a Git repo takes just seconds, so why did I bother creating `SyncRepos`? `SyncRepos` addresses three time sucks that cumulatively waste a ton of my time, given how extensively I use Git:
  1) Time wasted manually pulling changes from remote Git repos;
  2) Time wasted looking at out-of-date local caches of remote repos; and,
  3) Time wasted reconciling merge conflicts I could have avoided had I kept my local Git repos in sync with their remote counterparts rather than adding new commits to a stale branch.

As the great cartoon [`xkcd`](https://xkcd.com/1205/) put it:

![how_long_can_you_work_on_making_routine_task_efficient](https://imgs.xkcd.com/comics/is_it_worth_the_time.png)

Keeping my Git repos in sync is especially challenging because I develop on three different machines.

I imagine other devs also waste tons of time keeping their Git repos in sync, so this will hopefully benefit you too.

**WARNING**: Use at your own risk! I'm currently using this on my Git repos (on my Mac & Linux laptops... I have no idea about Windows), so I feel confident it works for my use cases, but I recommend you try it out on just a few repos until you feel confident it meets your needs. I started creating this October 16, 2019, so it's definitely *not* battle-tested! I offer a money-back guarantee, but that's all!

This script may require modification to work with different versions of Git. If you encounter a problem, please open an `Issue` in `https://github.com/JamesLavin/sync_repos/issues` and paste in the problematic log output, then I will try to update this script.

## Usage

To use the `SyncRepos` escript:

1) Install it (see [Installation](#installation))

2) Create a `~/.sync_repos` directory.

3) Create a `~/.sync_repos/config` YAML file specifying the `Git` directories on your local machine that you wish to keep synched up with remote `Git` repos, like this:

```
git:
  - rusterlium/rustler
  - plataformatec/broadway
  - ~/Git/absinthe
  - ~/Git/ecto
  - ~/Git/elixir
  - ~/Git/phoenix
  - ~/.calcurse
  - ~/Git/sync_repos
```

NOTE: If you specify the Github location (e.g., `plataformatec/broadway`), `SyncRepos` will automatically clone the repo for you. Once the repo exists locally, it doesn't matter whether your `config` file specifies the Github location or the local location (e.g., `~/Git/broadway`) unless the Github repository location ever changes (e.g., if `plataformatec/broadway` moved to `elixir-lang/broadway`).

4) Run `sync_repos` to sync all your Git repos. You will see output like the following:

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
    %{dir: "/Users/jameslavin/Git/conduit",
      halt_reason: "*** FAILURE: Branch 'my_feature' is currently checked out ***"},
    %{dir: "/Users/jameslavin/Git/commanded"},
    %{dir: "/Users/jameslavin/Git/absinthe"}
  ],
  processing: nil,
  sync_dir: "~/.sync_repos",
  timestamp: "20191017144242",
  to_process: []
}
SyncRepos script completed

Notable repos: [
  %{
    changes_pushed: true,
    dir: "/Users/jameslavin/Git/tech_management"
  },
  %{
    dir: "/Users/jameslavin/Git/sync_repos",
    halt_reason: "*** FAILURE: Cannot sync because Git repo has unstaged changes ***"
  },
  %{dir: "/Users/jameslavin/Git/conduit",
    halt_reason: "*** FAILURE: Branch 'my_feature' is currently checked out ***"
  }
]
```

5) To view the log file produced by any `SyncRepos` run (which contains additional debugging information not displayed by default), visit `~/.sync_repos/logs/`. Log files are timestamped like `~/.sync_repos/logs/sync_repos_20191017133716`

*NOTE*: `SyncRepos` currently skips any Git repo with a checked-out branch other than `master`. If the checked-out branch of any repo you added to `~/.sync_repos/config` isn't `master`, `SyncRepos` should skip that repo. (I hope to generalize this tool to work with non-`master` branches.)

*NOTE*: `SyncRepos` attempts to sync every repo, regardless of what happens while attempting to sync other repos. I may add an option to halt on any failure.

## Options

* To use a non-standard directory instead of the default of `~/.sync_repos`, you can indicate this by passing your directory with the `-d` flag (e.g., `./sync_repos -d ~/my/sync_repos/dir`) or, equivalently, the `--sync-dir` flag.

* To view full debugging output in your console, run `./sync_repos --debug`. (Whether you use the `--debug` flag or not, full debugging information is recorded after each run in a timestamped file within `./sync_repos/logs`.)

## Installation

*NOTE*: `SyncRepos` currently runs only as an Erlang `escript`. It's apparently possible to package `escript`s with the Erlang Runtime System (ERTS) into platform-specific executable binaries. If you would like me to do so, please email me at "#{my_first_name}@#{my_first_name}#{my_last_name}.com".

Installation steps:

1) To run an `escript`, *you must have Erlang/OTP installed on your machine*. You *don't* need Elixir (a language built on top of Erlang), but [installing Elixir](https://elixir-lang.org/install.html) may be easier -- as easy as `brew install elixir`, if you're on a Mac -- than installing Erlang/OTP. Besides, Elixir is a cool language that you should play around with, so why not just install it?!?!

* [More on escripts](https://hexdocs.pm/mix/Mix.Tasks.Escript.Build.html). 

2) Install the executable by running `mix escript.install github jameslavin/sync_repos` (or an equivalent command, see: [Escript.Install instructions](https://hexdocs.pm/mix/Mix.Tasks.Escript.Install.html)).

3) You should now be able to run the script with just `~/.mix/escripts/sync_repos`... but I currently have a misbehaving [asdf](https://github.com/asdf-vm/asdf) install and must invoke this as `~/.asdf/installs/elixir/1.9.1-otp-22/.mix/escripts/sync_repos`. YMMV.

Alternatively, you could pull down the executable from [`sync_repos`](https://github.com/JamesLavin/sync_repos/raw/master/sync_repos) OR build and install it by pulling down this repo and running `mix do escript.build, escript.install` in this directory... for which you'll need `Elixir` and `Mix` installed). You could then put the executable somewhere on your `$PATH` (or else execute it directly -- as `./sync_repos` -- from within the same directory) OR install it via `mix` with `mix escript.install sync_repos`

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/sync_repos](https://hexdocs.pm/sync_repos).

## TESTS

I've created some tests, and they're green (yay!).

You run them the normal way:
```
mix test
```

## IDEAS FOR FUTURE

* Test *all* the "FAILURE" cases
* Test *all* the cases where we want to skip processing a repo
* Better success message when successfully installing new HexDoc package
* Better error message when searching for non-existent HexDoc package: "Couldn't find docs for package with name hackney or version 1.15.2" or "Couldn't find docs for package with name metrics or version 2.5.0"
* Improve documentation
* Upload to Hex
* User-enabled, per-repo notifications when new commits are pulled
* Add option to halt on failure in single repo. (Current default behavior is to attempt to sync every directory, regardless of whether any repo fails)
* Enable optional per-repo committing of uncommitted changes
* Add strategies for syncing other resources (besides Git repos and Hex packages)
* Enable auto-updating of DevDogs, Dash, Zeal, etc. documentation/code browsers
* Add option to update only Hex docs or only Git repos
* Add option to auto-delete outdated Hex docs
* Enable user to specify non-default Hex docs directory
* Add option to suppress attempts to `git pull --rebase` (option could work globally or on a per-repo basis)
* Currently works only when `master` branch is checked out: Make this work with non-`master` branches
* Option to suppress saving all log files and instead save only the latest log file (or the last N log files?)