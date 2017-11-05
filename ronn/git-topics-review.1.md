# git-topics-review(1) -- Push a topic branch upstream for review

## SYNOPSIS

`git topics review` <topic>

## DESCRIPTION

Pushes the topic branch named <topic> to an upstream branch and attempts to
open a pull request.

The first part of this command is equivalent to

    $ git push --set-upstream <origin> <topic>

To determine which remote to use as <origin>, we look at git config values for
`branch.<name>.pushRemote`, `remote.pushDefault`, and/or `branch.<name>.remote`
(see git-config(1)) for various branches. In order:

1. Try to find the push remote for the topic branch. For instance, this would
   exist if you have some global `remote.pushDefault` or already set an
   upstream for the topic branch.

2. Try to find the push remote for the _develop_ branch. Since the next logical
   step in the workflow is for the topic branch to be merged to _develop_ for
   integration, it probably makes sense to push the topic branch to the same
   remote as _develop_ (if any).

3. Try to find the push remote for the _master_ branch. _develop_ and _master_
   would likely be tracked on the same remote (which would typically just be
   `origin`), but if we can't find any push remote for _develop_, we may as
   well try _master_ in case it's any different.

4. All else fails, default to `origin`.

With the topic branch pushed upstream, it should now be available to other
people with access to the same remote. That way, before merging a topic branch
into _develop_ or _master_, you may ask for feedback from others.

On [GitHub](https://github.com), this means using their web interface to open a
pull request that people can then leave comments on. If <origin>'s URL appears
to be from GitHub (i.e., it takes the form of one of the standard clone URLs -
`https://github.com/*` or `git@github.com:*`), then `git web--browse` will be
used to open the GitHub pull request form in your browser.

In this scenario, the second part of this command is equivalent to

    $ git web--browse https://github.com/<user>/<repo>/compare/<develop>...<topic>?expand=1

Of course, not every repository is hosted on GitHub. In this scenario, the
command uses the builtin `git request-pull` to format a pull request message to
stdout. You could then copy this text into, say, an email.

In this scenario, the second part of this command is equivalent to

    $ git branch --edit-description <topic>
    $ git request-pull <develop> <origin> <topic>

## SEE ALSO

git-topics(1), git-config(1), git-remote(1), git-branch(1), git-web--browse(1),
git-request-pull(1)
