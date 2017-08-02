# git-topics-setup(1) -- Configure git-topics

## SYNOPSIS

`git topics setup` [-f|--force]

## DESCRIPTION

Interactively configures the current git repository so you can use all the
other `git topics` commands. Because branches are manipulated, running this
command requires a clean work tree with at least one commit (i.e., not a repo
you just initialized; make an initial commit first).

The setup will prompt for the following pieces of information:

1. The name of the _master_ branch. This must either be the name of an existing
   local branch or the name of exactly one remote's branch. If the latter, a
   local version of the branch is created to track the remote branch. This is
   the same "do what I mean" behavior as if you'd used `git checkout <master>`,
   except that we don't actually checkout _master_.

2. The name of the _develop_ branch. This can be the name of an existing local
   branch or the name of exactly one remote's branch, same as the setup for the
   _master_ branch. However, if no local or remote branch exists, a new branch
   is automatically created with _master_ as the start-point (i.e., `git branch
   <develop> <master>`). At any rate, the branch named or created must have a
   merge-base in common with _master_ (i.e., `git merge-base <develop>
   <master>` must exist), guaranteeing that topic branches can be merged
   cleanly into both.

You should only need to run this command once, since the above options will be
persisted to the repository's local git config. The other `git topics` commands
reference these config values to carry out their operations.

## OPTIONS

* -f, --force:
  Under normal circumstances, if there's already a value in the git config, you
  won't be re-prompted for that value. But if there was an error while setting
  up the repository, or you just want to change the values, you can pass the
  `--force` flag to prompt for all the configuration values regardless.

## SEE ALSO

git-topics(1), git-branch(1), git-checkout(1), git-config(1),
git-check-ref-format(1), git-merge-base(1)
