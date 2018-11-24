# git-topics-reintegrate(1) -- Rewind & rebuild an integration branch

## SYNOPSIS

`git topics reintegrate` [--onto <branch>] [--allow-empty]

`git topics reintegrate` (--continue | --skip | --abort | --quit | --edit-todo)

## DESCRIPTION

Resets the given branch (by default, _develop_) to be even with _master_, then
re-merges topic branches that had previously been integrated. One use case for
this is described in git-topics-management(7).

The interface is much the same as `git rebase --interactive`. When you start a
reintegration, a todo list will be opened containing instructions of the form

    pick <topic>
    drop <topic>

The `pick` instructions are automatically filled in with the branches that are
currently merged into _develop_ but not _master_ (i.e., integrated topics, but
not finished topics).

The `drop` instructions are automatically filled in with the branches that have
yet to be merged to _develop_ or _master_. That way it's easy to edit them into
`pick`s if you so choose.

These instructions are initially put in the todo list in an arbitrary order.
When you exit the editor, the target branch will be rewound & the todo list
will be executed from top to bottom. Topics given in `pick`s will be merged
while topics given in `drop`s are ignored, in effect rebuilding the integration
branch. Thus, you should edit the todo list to merge the desired branches into
<branch> in the desired order.

Essentially, this is equivalent to

    $ git checkout <branch>
    $ git reset --hard <master>
    $ git merge --no-ff <pick-a>
    $ git merge --no-ff <pick-b>
    $ git merge --no-ff <pick-c>
    $ ...

By default, <branch> will be _develop_, but you can reintegrate onto a
different branch with `git topics reintegrate --onto`. For example, you might
want to experiment on some unstable branch to see if certain topics merge
together cleanly. If the given branch does not exist, it will automatically be
created and based off of _master_.

Merge conflicts and other errors might interrupt the execution of the todo
list. When this happens, it's your responsibility to resolve the issue and
resume the reintegration using the flags listed in the [ACTIONS][] section
below.

## OPTIONS

* --onto <branch>:
  Reintegrate topics onto the specified branch. If not supplied, the target
  branch will default to _develop_.

* --allow-empty:
  Normally, you can abort a reintegration by saving an empty todo list (whether
  literally empty or containing nothing but `drop` instructions). However, if
  you give this option, the reintegration will still run without re-merging any
  topics. Effectively, this is equivalent to just doing `git reset --hard
  <master>` by hand.

## ACTIONS

* --continue:
  Resumes executing the todo list after you've resolved a merge conflict.

* --skip:
  Discards any changes to the working tree or index, then resumes executing the
  todo list.

* --abort:
  Stops executing the todo list and resets <branch> to its original HEAD from
  before the reintegration started.

* --quit:
  Stops executing the todo list, but leaves any changes made to <branch>
  intact. The index and working tree are also left unchanged as a result.

* --edit-todo:
  Opens the todo list of remaining instructions. You're free to edit it just as
  you did at the beginning of the reintegration. However, no action will be
  taken after you exit the editor; you'll have to use `git topics reintegrate
  --continue` or such explicitly.

## CONFIGURATION

* sequence.editor:
  Text editor to use for the todo list. This is the same configuration value
  used by `git rebase --interactive`, and behaves just as described in
  git-config(1).

* rerere.enabled:
  This variable is also just the one described in git-config(1). But it might
  be particularly useful to enable when handling repetitive reintegrations, so
  you don't get stuck resolving the same conflicts over & over again. Note that
  merges made while reintegrating are automatically done with the
  `--rerere-autoupdate` flag; see git-merge(1).

* core.commentchar:
  This variable controls which character is used to comment out lines in the
  todo list. See git-config(1).

## TROUBLESHOOTING

At most one reintegration can be in progress at any given time. In the simplest
case, you start a reintegration and the automatic execution finishes cleanly.
But when merge conflicts and other errors happen, they interrupt the original
process.

To keep track of where we are in the middle of a reintegration, there are
several files stored under the `$GIT_DIR/git-topics-reintegrate` directory.

* `$GIT_DIR/git-topics-reintegrate/onto`:
  Contains the name of the branch we're reintegrating onto (i.e., the value of
  the `--onto` flag).

* `$GIT_DIR/git-topics-reintegrate/orig`:
  Contains the SHA-1 reference to the commit originally pointed to by the HEAD
  of the `--onto` branch. This is used for `git topics reintegrate --abort`.

* `$GIT_DIR/git-topics-reintegrate/todo`:
  Contains the sanitized todo list. The only lines that should be in this file
  are `pick`s or `drop`s (although `drop`s are also scrubbed out
  automatically). In particular, there should be no empty lines or comments.
  `git topics reintegrate --edit-todo` will actually edit a temporary version
  of this file amended with instructional comments. When the editor is closed,
  whatever you wrote is automatically sanitized and written back here.

* `$GIT_DIR/git-topics-reintegrate/done`:
  As todo lines are processed, they are removed from the head of the above file
  and written to the tail of this file before any actions are taken. Thus, if
  there's a merge conflict or error, the last line here should be the todo step
  we're stuck on.

This organization is subject to change and should be treated as an
implementation detail. However, if you encounter some bug while reintegrating,
it may pay to know what this temporary state looks like.

In general, `git topics reintegrate` tries to make sure you never have to worry
directly about this state. But (a) bugs happen and (b) we're exposed to the
possibility of weird scenarios whenever we break in the middle of a
reintegration.

To avoid some of the obvious issues:

* When reintegration is interrupted, stay on the same branch. Actions like
  `--continue`, `--skip`, and `--abort` use git commands that operate relative
  to the current HEAD (for example, `git merge <next-pick>`). If you checkout
  some other branch in the middle of the reintegration, we wouldn't want to run
  those commands relative to somewhere other than intended.

* When you get a merge conflict, fix it as simply as possible: just edit the
  files with conflicts and `git add` them to mark their resolution. The todo
  line that led to this merge conflict won't be retried or anything - the line
  is already on the end of the "done" list. So this is your one shot to fix the
  issues.

* Don't edit the todo file directly, use `git topics reintegrate --edit-todo`.
  It will automatically scrub out comments, empty lines, and `drop`s, which the
  rest of the reintegration engine relies on.

* You CAN do crazy things in the middle of a merge conflict, but consider your
  warranty voided and tread with caution. For example, there's nothing
  technically stopping you from running `git reset --hard <master>` or deleting
  <branch> in the middle of a merge conflict, but `git topics reintegrate
  --continue` would be none the wiser.

If you find yourself in a truly weird scenario, stuck in the middle of a
reintegration you can't get out of, you can inspect the temporary state in
`$GIT_DIR/git-topics-reintegrate`. If there's nothing of value, just delete the
whole directory by hand. This should wipe the slate clean and let you try some
other reintegration. Note that the entire directory must be gone: even if you
leave an empty directory, we'll still think we're in the middle of a
reintegration.

## SEE ALSO

git-topics(1), git-topics-management(7), git-rebase(1), git-config(1),
git-merge(1), git-rerere(1), gitrepository-layout(5)
