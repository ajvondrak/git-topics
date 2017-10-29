# git-topics-integrate(1) -- Merge a topic branch to the integration branch

## SYNOPSIS

`git topics integrate` <topic>

## DESCRIPTION

Merges an existing, "reasonably" stable topic branch named <topic> to the
_develop_ branch for testing & integration.

The merge is done with the `--no-ff` flag, ensuring that a commit is always
created to record the fact that this topic was integrated. When the topic
branch gets deleted, you'll still be able to recover its history from this
merge commit.

Note that the topic branch will NOT be deleted here, in case issues are found
while testing the code on _develop_. If there are issues, you should make
further commits on the topic branch and `git topics integrate` it again.

If _develop_ is tracking a remote branch, `git topics integrate` makes an
effort to ensure your local branch is up to date first. This avoids conflicts
if you later push upstream. This is done with a `git fetch` of the
corresponding remote branch. If the local branch is behind, the topic will not
be merged. If the fetch itself fails, the topic will still be merged, but there
will be a warning. That way, transient issues like internet connection problems
won't get in the way of your development.

Essentially, this command is equivalent to

    $ git checkout <develop>
    $ git pull
    $ git merge --no-ff <topic>

except that it only does a `git fetch`, not a full `git pull`, and only if
there's a remote tracking branch. If a `git merge` from the upstream _develop_
is required, this command will stop short of actually merging the topic.

## MERGE CONFLICTS

Aside from the sanity checks beforehand, `git topics integrate` is really just
equivalent to `git merge --no-ff`. Specifically, there are no further actions
that the command performs after doing the merge. So in the event of a merge
conflict (or any other condition that causes `git merge` to exit non-zero), you
may continue to resolve it the same way as if you'd simply used `git merge`.
You could even use `git merge --abort`.

It's worth noting that minor merge conflicts are a normal part of the workflow.
A common mistake is to think your topic branch MUST merge 100% cleanly into
_develop_ or _master_. This leads people to one of two "solutions" to preempt
merge conflicts:

1. Merge an upstream branch (_develop_ or _master_) into the topic branch. This
   is frowned upon, especially if done habitually for no real reason (as noted
   in gitworkflows(7)). You still get the same merge conflicts as if you'd just
   merged the topic to the upstream. But then, instead of having a single,
   independent history of the topic, you get a rat's nest of changes from the
   upstream branch. For example, say you merged _develop_ into your topic, then
   decided the topic was finished. If you were to merge the topic back to
   _master_, suddenly _master_ would contain all of _develop_'s changes!

2. Rebase the topic branch onto the latest _master_ (rebasing on top of
   _develop_ is just wrong, since topics should be based on _master_). This
   probably won't help with merge conflicts on _develop_ in the first place,
   and at any rate rebasing should always be treated with caution. If your
   topic's history is still completely local, by all means rebase away to make
   your history cleaner. But if you've already pushed your topic publicly
   (e.g., using `git topics review`), rewriting history may cause more
   headaches than it's worth.

The "real" solution is generally to resolve merge conflicts as they happen,
instead of trying to preempt them. As long as you're making the fixes already,
you might as well record those in the merge commit itself: it's part of the
history too. It's the most relevant place to record conflict resolutions (be
sure to explain them in the commit message!), and you're guaranteed a merge
commit via `--no-ff` regardless, which means the branch's history remains
intact.

As always, evaluate your needs on a case by case basis. There's no
one-size-fits-all solution:

* Perhaps topic A actually has a dependency on topic B, so you should merge B
  into A. See git-topics-use(1).

* Evil merges involve not just a simple textual conflict, but rather a more
  "semantic" one (e.g., someone has changed the name of a variable you depend
  on). One way to preempt such issues is to play with a throwaway branch before
  integrating your topic. See git-topics-experiment(1).

* Maybe in some narrow case merging the upstream to your topic is actually
  appropriate.

* It could be that rewriting commits (even public ones) is ultimately the way
  to go. Sometimes this is called a "reroll": to just write the feature over
  again with a cleaner patch set and/or history.

* Of course, you could always make additional commits to your topic before
  merging.

* In certain situations, you just need to copy over a certain commit with `git
  cherry-pick`. This should be infrequent with proper branch management,
  though.

* etc

Use your best judgement.

## SEE ALSO

git-topics(1), git-merge(1), git-checkout(1), git-fetch(1), git-pull(1)

[Linus Torvalds on git rebase and merge](http://www.mail-archive.com/dri-devel@lists.sourceforge.net/msg39091.html)
