Git Powercommit
===============

This repo contains the end-user [shell script](./git-powercommit) implementing
`git powercommit` command for commiting and pushing the changes to your Git
repository. The script uses meaningless commit messages, performs pulls/stashes
as required and supports git submodules. Thus we try to automate a typical work
scenario of a lazy developer.

**Disclamer: the Author tried to make this script clean and simple and even
provided a [test](./test.sh). But you know, Git is a complex thing, something
may not work as expected. Use this script at your own risk.**

The script's algorithm in a nutshell:

1. Check for changes, exit if there are none.
2. Mark the current head with a branch `powercommit`. Exit if the branch already
   exists.
3. Call `git stash`
4. Call `git pull --rebase`
5. Apply the stash
6. Call itself recusively for every git-submodule, unless `--no-recursive` is
   given
7. Commit every changed submodule
8. Commit every changed regular file or folder, aggregating the files that
   share a folder into a single commit.
9. Push the repo upstream
10. Remove the `powercommit` marker branch.

Usage
-----

1. Drop this [git-powercommit](./git-powercommit) script into one of your PATH
   folders.
2. `cd your-git-repo`
3. `git powercommit --dry-run`
4. `git powercommit`

If something goes wrong
-----------------------

As one of its first steps, powercommit script pins the current state of the repo with the `powercommit` branch. On the tip of this branch, it creates the stash capturing the currently modified files. If the automation magic fails for some reason, you are advised to recover the starting state manually by using the following commands:

5. `git reset --hard "powercommit"; git stash pop; git branch -D "powercommit"`

You may need to repeat the above sequence for all submodules. The script will refuse to run if the `powercommit` branch already exists.

Also it is recommended to run the [test](./test.sh) script to check the script compatibility on mock repos.
