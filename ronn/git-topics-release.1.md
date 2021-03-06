# git-topics-release(1) -- Tag the stable branch with a new version

## SYNOPSIS

`git topics release` [major|minor|patch]

## DESCRIPTION

Tags the current tip of the _master_ branch with a new semantic version of the
format `vX.Y.Z`, where `X` is the major version, `Y` is the minor version, and
`Z` is the patch version.

The tag name is automatically generated by parsing the last tag on _master_ for
the latest version number, then incrementing it based on the given option. If
the last tag doesn't look like a version number, you'll have to use `git tag
-a` by hand. "Looking" like a version number means the tag has an optional
non-numeric prefix followed by between one & three dot-separated numbers;
trailing characters are ignored. For example, `v1`, `1.0-alpha2`, `1.0.0`, and
`version-1.0.0.1` are all treated essentially the same as `v1.0.0`. However,
any prefix used in the last tag is preserved for the next tag. This way, you
don't have to start using `v` if you weren't doing so prior to using
git-topics.

If no prior tag exists (i.e., this is the first release), the tag `v0.0.0` will
be used as the base before incrementing. Note that this makes the prefix `v` by
default.

The tag must be annotated. An editor is started for you to enter a tag message
describing the release. The message will be pre-populated with a comment
showing the topics that have been merged to _master_ since the last release,
which is helpful for coming up with a meaningful summary. It's suggested that
you craft the summary (i.e., the first line of this tag message) with care, to
maximize the usefulness of `git tag -n`.

If _master_ is tracking a remote branch, `git topics release` makes an effort
to ensure your local branch is up to date first. This avoids conflicts when you
later push upstream. This is done with a `git fetch` of the corresponding
remote branch. If the local branch is behind, the tag will not be created. If
the fetch itself fails, the tag will still be created, but there will be a
warning. That way, transient issues like internet connection problems won't get
in the way of your development (beware of pushing this new tag upstream,
though).

Essentially, this command is equivalent to

    $ git checkout <master>
    $ git pull
    $ git tag -a vX.Y.Z <master>

except that it only does a `git fetch`, not a full `git pull`, and only if
there's a remote tracking branch. If a `git merge` from the upstream _master_
is required, this command will stop short of making the new tag.

## OPTIONS

* major:
  Increments the major version number. For example, if the latest tag is
  `v1.2.3`, the new tag would be `v2.0.0`. Use this option when the release
  contains incompatible API changes.

* minor:
  Increments the minor version number. For example, if the latest tag is
  `v1.2.3`, the new tag would be `v1.3.0`. Use this option when the release
  contains new, backwards-compatible functionality.

* patch:
  Increments the patch version number. For example, if the latest tag is
  `v1.2.3`, the new tag would be `v1.2.4`. Use this option when the release
  contains backwards-compatible bug fixes.

## SEE ALSO

git-topics(1), git-tag(1), git-checkout(1), git-fetch(1)

[Semantic Versioning](http://semver.org/)
