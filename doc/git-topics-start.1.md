# git-topics-start(1) -- Start a new topic branch

## SYNOPSIS

`git topics start` <name>

## DESCRIPTION

Starts a new topic branch with the given <name> forked off of _master_. If so
configured by `git topics setup`, <name> will be automatically prefixed to
adhere to branch naming conventions. If _master_ is tracking a remote branch,
`git topics start` makes an effort to ensure your local _master_ branch is up
to date first. This avoids starting your topic based on old code and having to
rebase it later.

To keep _master_ up to date, this command will `git fetch` the remote branch
for any pending commits. If the local branch is behind, the topic branch will
not be created. If the fetch itself fails, the topic branch will still be
created, but there will be a warning. That way, transient issues like internet
connection problems won't get in the way of your development.

Essentially, this command is equivalent to

    $ git checkout <master>
    $ git pull
    $ git checkout -b <prefixed-name>

except that it only does a `git fetch`, not a full `git pull`. If a `git merge`
is required, it'll stop short of the actual branch creation.

## SEE ALSO

git-topics(1), git-topics-setup(1), git-checkout(1), git-fetch(1),
git-merge(1), git-pull(1)
