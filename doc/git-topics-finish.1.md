# git-topics-finish(1) -- Merge a topic branch to the stable branch

## SYNOPSIS

`git topics finish` <topic>

## DESCRIPTION

Merges a stable topic branch named <topic> to the _master_ branch for future
release. This must be done after the topic has been merged into _develop_ for
integration testing, which can be done using `git topics integrate`.

The merge is done with the `--no-ff` flag, ensuring that a merge commit is
always created. When the topic branch gets deleted, you'll still be able to
recover its history from this merge commit.

After successfully merging, the topic branch WILL be deleted. If it has an
upstream set, the remote branch will be deleted too.

If _master_ is tracking a remote branch, `git topics finish` makes an effort to
ensure your local branch is up to date first. This avoids conflicts when you
later push upstream. This is done with a `git fetch` of the corresponding
remote branch. If the local branch is behind, the topic will not be merged. If
the fetch itself fails, the topic will still be merged, but there will be a
warning. That way, transient issues like internet connection problems won't get
in the way of your development.

Essentially, this command is equivalent to

    $ git checkout <master>
    $ git pull
    $ git merge --no-ff <topic>
    $ git push <origin> --delete <topic>
    $ git branch --delete <topic>

except that it only does a `git fetch`, not a full `git pull`, and only if
there's a remote tracking branch. If a `git merge` from the upstream _master_
is required, this command will stop short of actually merging the topic.

The same sort of `git fetch` sanity check is run against the _develop_ branch
when checking if the topic has been integrated.

## MERGE CONFLICTS

`git topics finish` will only try to delete the topic branch after a SUCCESSFUL
merge. Conflicts (or anything else that causes `git merge` to exit non-zero)
will make `git topics finish` stop short of cleaning up the topic branch. Merge
conflicts may be resolved in the usual ways, but this command will be none the
wiser. To finish the branch cleanup after a merge conflict, you may run `git
topics finish` again.

Alternatively, you could use a post-commit hook that runs this command if it
looks like you're making a merge commit on _master_. This way, after you fix a
merge conflict and `git commit` the result, `git topics finish` will
automatically be reinvoked to pick up where it left off.

The general notes about merge conflicts in the git-topics-integrate(1) manual
apply here, too. Additionally, note that merging a topic into _master_ may not
be exactly the same as merging into _develop_. For example, features A & B
might be merged to _develop_ for testing, and they may have conflicts with each
other. But then if you decide to only release feature A, these conflicts won't
exist on _master_. So be careful about how you coordinate dependencies between
multiple topics (e.g., see git-topics-use(1)).

## SEE ALSO

git-topics(1), git-merge(1), git-checkout(1), git-fetch(1), git-pull(1), githooks(5)
