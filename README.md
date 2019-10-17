# SyncRepos

Keep all your local `Git` repos in sync with their remote counterparts by running a single command (which you can run periodically in a `cron` job if you want).

`SyncRepos` will pull down remote changes and -- if your local repo has unpushed commits -- rebase your local unpushed commits on top of the remote branch, then push your changes up to the remote repo.

`SyncRepos` won't try to sync a repo if the local repo contains any unstaged changes in tracked files.

`SyncRepos` provides command-line information and records richer debugging information in a timestamped log file each time it runs.

## Why Did You Automate Something That Takes Seconds? Are You Stupid?

Updating a Git repo takes just seconds, so why did I bother creating `SyncRepos`? `SyncRepos` addresses three time sucks that cumulatively waste a ton of my time:
  1) Time wasted manually pulling changes from remote Git repos;
  2) Time wasted looking at out-of-date local caches of remote repos; and,
  3) Time wasted reconciling merge conflicts that wouldn't have happened if I had kept my local Git repos in sync with their remote counterparts because I added my commits to a stale branch.

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
  - ~/Git/absinthe
  - ~/Git/ecto
  - ~/Git/elixir
  - ~/Git/phoenix
  - ~/.calcurse
  - ~/Git/sync_repos
```

4) Run `sync_repos` to sync all your Git repos. (If you want full debugging output, run `./sync_repos --debug`.) You will see output like the following:

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
```

5) To view the log file produced by any `SyncRepos` run (which contains additional debugging information not displayed by default), visit `~/.sync_repos/logs/`. Log files are timestamped like `~/.sync_repos/logs/sync_repos_20191017133716`

*NOTE*: `SyncRepos` currently skips any Git repo with a checked-out branch other than `master`. If the checked-out branch of any repo you added to `~/.sync_repos/config` isn't `master`, `SyncRepos` should skip that repo. (I hope to generalize this tool to work with non-`master` branches.)

*NOTE*: `SyncRepos` attempts to sync every repo, regardless of what happens while attempting to sync other repos. I may add an option to halt on any failure.

## Installation

1) To run an `escript`, *you must have Erlang/OTP installed on your machine*. [More on escripts](https://hexdocs.pm/mix/Mix.Tasks.Escript.Build.html). You *don't* need Elixir (a language built on top of Erlang), but [installing Elixir](https://elixir-lang.org/install.html) may be easier -- maybe as easy as `brew install elixir` -- than installing Erlang/OTP. Besides, Elixir is a cool language that you should play around with, so why not just install it?!?!

2) Install the executable by running `mix escript.install github jameslavin/sync_repos` (or an equivalent command, see: [Escript.Install instructions](https://hexdocs.pm/mix/Mix.Tasks.Escript.Install.html)).

3) You should now be able to run the script with just `~/.mix/escripts/sync_repos`... but I currently have a misbehaving [asdf](https://github.com/asdf-vm/asdf) install and must invoke this as `~/.asdf/installs/elixir/1.9.1-otp-22/.mix/escripts/sync_repos`. YMMV.

Alternatively, you could pull down the executable from [`sync_repos`](https://github.com/JamesLavin/sync_repos/raw/master/sync_repos) OR build and install it by pulling down this repo and running `mix do escript.build, escript.install` in this directory... for which you'll need `Elixir` and `Mix` installed). You could then put the executable somewhere on your `$PATH` (or else execute it directly -- as `./sync_repos` -- from within the same directory) OR install it via `mix` with `mix escript.install sync_repos`

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/sync_repos](https://hexdocs.pm/sync_repos).

## IDEAS FOR FUTURE

* Improve documentation
* Upload to Hex
* Add option to use non-standard file location
* Add option to halt on failure in single repo. (Current default behavior is to attempt to sync every directory, regardless of whether any repo fails)
* Add strategies for syncing other resources besides Git repos
* Add option to suppress attempts to `git pull --rebase` (option could work globally or on a per-repo basis)
* Currently works only when `master` branch is checked out: Make this work with non-`master` branches
* Option to suppress saving all log files and instead save only the latest log file (or the last N log files?)