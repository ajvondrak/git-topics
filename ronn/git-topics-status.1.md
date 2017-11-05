# git-topics-status(1) -- Show the status of existing topic branches

## SYNOPSIS

`git topics`

`git topics status` [options]

## DESCRIPTION

Display the topic status of branches that are based off of _master_. The topic
status depends on where the branch has been merged:

* If merged to _master_ (presumably by way of `git topics finish`), the topic
  is finished and waiting to go out in the next release.

* If merged to _develop_ (presumably by way of `git topics integrate`), the
  topic is integrated and waiting to be finished.

* Otherwise, the topic has only been started (presumably by way of `git topics
  start`), so it's still in development and waiting to be integrated.

By default, the status of each local branch is shown.

## OPTIONS

* -r, --remotes:
  Display the statuses of remote-tracking branches only.

* -a, --all:
  Display the statuses of both local and remote-tracking branches.

* -s, --short:
  Give the output in a short format. See the [OUTPUT][] section below.

* -p, --porcelain:
  Give the output in a machine-readable format. See the [OUTPUT][] section
  below.

## OUTPUT

### Long Format

The default output from this command is in a long format that's designed to be
human-readable. Its contents and format are subject to change at any time.

### Short Format

In the short format, the status of each topic branch is shown as a separate
line that looks like:

    X TOPIC

`X` is a single-character status code and `TOPIC` is the shortened refname of
the branch. The status code and refname are separated by a single space. `X`
has three possible values:

* `*` for finished topics
* `+` for integrated topics
* `-` for started topics

### Porcelain Format

The porcelain format is the same as the short format, except:

1. The user's color configuration is not honored. Output is never colorized.

2. The short format may possibly change in future releases, whereas the
   porcelain format is guaranteed not to change in a backwards-incompatible
   way.

 This makes it ideal for use by scripts.

## CONFIGURATION

Like most other git commands, this command's output will be colorized when
displayed in a terminal. Colorization honors the following configuration
variables.

* `color.topics`:
  Dictates whether/when output is colorized altogether. It behaves the same way
  as `color.ui` (see git-config(1)). If missing, it will default to the value
  of `color.ui`.

* `color.topics.header`:
  The color of the long format's descriptive headers (default: normal).

* `color.topics.finished`:
  The color of finished topic branches (default: green).

* `color.topics.integrated`:
  The color of integrated topic branches (default: yellow).

* `color.topics.started`:
  The color of topic branches that have just started (default: red).

## SEE ALSO

git-topics(1), git-config(1)
