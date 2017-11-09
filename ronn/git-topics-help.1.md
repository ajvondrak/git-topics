# git-topics-help(1) -- Display help for a git-topics command

## SYNOPSIS

`git topics help` [<command>]

## DESCRIPTION

Displays the manual page for the given git-topics <command> via `git help
--man`. If no <command> is given, shows the top-level git-topics(1) page, just
as `git help topics` would.

The current page can be displayed with `git topics help help`.

## CONFIGURATION

The environment variable `GIT_MAN_VIEWER` and/or the configuration variables
`man.viewer`, `man.<tool>.path`, and `man.<tool>.cmd` may be used to specify
which program you use to view manual pages. See git-help(1).

However, `help.format` is not honored; the git-topics help is currently only
available in _man_ format.

## SEE ALSO

git-topics(1), git-help(1)
