# git-topics(1) -- Manage topic branches

## SYNOPSIS

`git topics` [<command>] [<options>]

## DESCRIPTION

`git topics` provides a collection of high-level commands that make it easy to
manage topic branches roughly as described in gitworkflows(7). [BRANCHING
MODEL][] gives an overview of the workflow in broad terms. The [COMMANDS][]
section provides a summary of available commands.

## BRANCHING MODEL

The core model is a simplification of the workflow described in
gitworkflows(7). There are two main branches:

* _master_:
  The primary, production-ready branch that tracks stable releases of the
  project. Commits here may be shipped at any time.

* _develop_:
  A staging branch based on _master_ that is used to test changes before their
  inclusion in _master_.

The names of these branches don't really matter. In fact, they are
configurable, since there are many reasonable options. The documentation will
refer to them by these canonical names, though.

Commits should NOT be made directly on either of the main branches. Instead,
each isolated topic (feature, bug fix, etc) should be worked on in its own
branch. Each topic branch should fork off of _master_, since the eventual goal
is to merge it back into a stable version. Each topic branch is named something
semantically meaningful, possibly with some conventional prefix. For example,
if John Doe is working on a topic "foo", he might reasonably name the branch
simply _foo_, prefix it by a keyword like _topic/foo_ or _feature-foo_, or
maybe prefix it by his initials like _jd/foo_. The important thing is that your
project's convention is consistent and useful.

The general life cycle of a topic branch then goes:

1. Fork your local topic branch off of _master_.

2. Work on your topic.

3. When you're ready, you may opt to push your topic branch remotely for others
   to review.

4. When the review is complete and your topic branch is reasonably stable, you
   can stage your changes by merging the topic branch into _develop_. This
   branch should then be used as a "playground" to test the new changes. Note
   that the topic branch DOES NOT get deleted at this point, in case testing
   reveals further changes you have to make.

5. If your topic requires further changes, add additional commits to the topic
   branch. Repeat 2-4 until your changes are completely stable.

6. When your topic is stable, you can merge it into _master_. The topic branch
   can then be deleted.

Releases of the project are cut from _master_ by simply tagging a particular
commit with a [semantic version](http://semver.org/).

While you can carry out all of the above "by hand" pretty easily with normal
git commands, `git topics` makes it slightly more convenient to follow this
practice while providing some other goodies.

## COMMANDS

* git topics help [<command>]:
  Displays in-depth help for <command> (or this page, if no command is given).

* git topics setup [-f|--force]:
  Interactively configures the current repository so you can use all the other
  `git topics` commands. You should only need to run this command once. If you
  misconfigured something or there was an error, you can start over with the
  `--force` flag.

* git topics start <topic>:
  Start a new topic branch.

* git topics review <topic>:
  Push a topic branch upstream for review.

* git topics stage <topic>:
  Merge a topic branch to the staging branch.

* git topics finish <topic>:
  Merge a topic branch to the production-ready branch.

* git topics release [major|minor|patch]:
  Tag the production-ready branch with a new version.

## SEE ALSO

git(1), gitworkflows(7)
