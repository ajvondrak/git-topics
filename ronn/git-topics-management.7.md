# git-topics-management(7) -- How git-topics fits in with release management

## SYNOPSIS

Documentation around strategies for managing releases while using git-topics.

## DESCRIPTION

The normal usage described by git-topics(1) takes you through how topics are
managed right up until the release of a new version. But some projects have
extra steps required for each release, such as building a binary or uploading
documentation. Sometimes these changes may even require touching the source
code itself, such as updating the metadata for your ecosystem's package manager
(CPAN, RubyGems, PyPI, etc). How does git-topics play along with your release
workflow? There are many reasonable approaches, depending on your needs.

For the following discussion, consider an example where we have already
integrated topics `a`, `b`, and `c`:

    $ git topics integrate a
    $ git topics integrate b
    $ git topics integrate c

See git-topics-start(1) and git-topics-integrate(1).

Suppose we've tested the topics, and they're all ready to be released in a new
major version.

### Strategy: post-update hooks

The standard way to cut a new release is just to finish the topics and tag
_master_:

    $ git topics finish a
    $ git topics finish b
    $ git topics finish c
    $ git topics release major

See git-topics-finish(1) and git-topics-release(1).

If your release process requires extra steps that do not change the source
code, it would be reasonable to have post-update hooks carry out your tasks
(build binaries, generate documentation, etc) whenever you push a new tag
upstream. See githooks(5).

However, suppose you need to alter some file in your repository for each
release. For illustration, let's say you edit a VERSION file, although a
real-world example might be less trivial.

In this scenario, post-update hooks may not be appropriate: you would tag a
release, push upstream, then the hook's changes to the VERSION file would have
to be committed on top of the commit you just tagged. That is, the VERSION file
would not be up to date according to the commit pointed to by the tag, which
defeats the purpose of tagging the release in the first place.

### Strategy: commit directly

Instead of relying on automated hooks that react to new tags, it might make
sense to just commit release-related changes directly to _master_ before
running `git topics release`:

    $ git topics finish a
    $ git topics finish b
    $ git topics finish c
    $ vim VERSION
    $ git add VERSION
    $ git commit -m 'Prepare next major release'
    $ git topics release major

This has the advantage of being very straightforward, but it can be disorderly.
Any changes you make on _master_ don't have any "schedule" for being merged
back to _develop_. Under normal git-topics usage, you'll have to `git topics
start` a new branch after this release, then wait until you can `git topics
integrate` it before the VERSION changes get merged to _develop_.

### Strategy: commit directly, merge back

This is like the previous strategy, except we assume that the release-related
changes are important to have back on _develop_ immediately.

One way to bring _develop_ up to date is to simply merge _master_ back into it
after the release:

    $ git topics finish a
    $ git topics finish b
    $ git topics finish c
    $ git topics release major
    $ git checkout <develop>
    $ git merge --no-ff <master>

This maintains a literal history of _develop_, in that the merge commit records
when we synchronized with _master_. However, this can also make the history
messy and hard to follow. Furthermore, releases can be a natural point at which
we reconsider the state of the _develop_ branch: maybe some topics should be
reverted, reordered, rewritten, etc.

### Strategy: commit directly, reintegrate

Instead of merging after the `git topics release`, you could rewind _develop_
and re-merge the topics that were not part of the release. This is what the
`git topics reintegrate` command was made for:

    $ git topics finish a
    $ git topics finish b
    $ git topics finish c
    $ git topics release major
    $ git topics reintegrate

Basically, the last command would be equivalent to doing:

    $ git checkout <develop>
    $ git reset --hard <master>
    $ git topics integrate d
    $ git topics integrate e
    $ git topics integrate f
    $ ...

See git-topics-reintegrate(1).

Rebuilding the _develop_ branch keeps the history a lot cleaner. Plus, it gives
you the option of backing out topics that are no longer relevant after a
release, rather than cluttering the history up with reverts.

However, it does come with the usual caveats about rewriting history. It may
require some force-pushing and an announcement to other developers. This might
be a hassle to do on every release. Depending on your process, this "nuclear"
option could be reserved for as-needed usage, rather than as part of the normal
cycle. On the other hand, it may be preferable to set a consistent expectation
that releases imply reintegration; then it won't be surprising to other
developers.

### Strategy: inline changes

To avoid having to manage the _develop_ branch directly, you could roll the
release-related changes into one of the existing topic branches:

    $ git topics finish a
    $ git topics finish b
    $ git checkout c
    $ vim VERSION
    $ git add VERSION
    $ git commit -m 'Prepare next major release'
    $ git topics integrate c
    $ git topics finish c
    $ git topics release major

Because topic branches require integration before you're allowed to finish
them, this guarantees that the VERSION changes make their way to _develop_
immediately.

This makes sense if the VERSION changes logically belong in the topic, but odds
are this won't be the case. As such, this strategy isn't usually preferred: the
topic branch's history is sullied with commits concerning release management.

### Strategy: dedicated topic

As simple as it sounds, you could also just start a new topic every time you
have to do release-management tasks:

    $ git topics finish a
    $ git topics finish b
    $ git topics finish c
    $ git topics start release-management
    $ vim VERSION
    $ git add VERSION
    $ git commit -m 'Prepare next major release'
    $ git topics integrate release-management
    $ git topics finish release-management
    $ git topics release major

This plays along nicely with the rest of git-topics, seeing as how it's just
another topic. It's also very explicit about the release management process,
and guarantees all the changes make their way through _develop_. Using this
strategy, it would probably make sense to adopt a naming convention
specifically for release branches.

However, if your changes are trivial, it might be overkill to dedicate entire
topics to them on every release. The topic branches would be so short-lived as
to be nearly pointless. It would fill the history with merges that mean very
little - just administrative matters.

### Strategy: your own idea

Above all, git-topics tries not to be overly prescriptive. This document may
have given you some ideas and their pros/cons, but ultimately you know your
project's needs better than some dude who wrote a git plugin. Go forth and
conquer.

## SEE ALSO

git-topics(1), git-workflows(7)
