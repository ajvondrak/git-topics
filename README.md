# git-topics

A collection of [git](https://git-scm.com/) commands to manage independent topic branches. The branching model is a simplified version of the concepts described in [gitworkflows(7)](https://git-scm.com/docs/gitworkflows).

## Installation

Using [Homebrew](https://brew.sh/):

```
$ brew install ajvondrak/tap/git-topics
```

## Quick Start

```
$ cd /path/to/your/repo
$ git topics setup # follow the prompts
$ git topics help
```

## Basic Usage

You can setup git-topics on any git repository with at least one commit. In this example, we'll initialize a new one.

```
$ git init repo
Initialized empty Git repository in /private/tmp/repo/.git/
$ cd repo
$ git commit --allow-empty -m 'Initial commit'
[master (root-commit) d234655] Initial commit
```

There are two long-running branches in this workflow. You can just accept the
default branch names by hitting `<enter>` at the `git topics setup` prompts. The first branch must already exist, but the second branch will be created if missing.

```
$ git topics setup
You need a branch that tracks stable releases for your repository.
Commits here may be shipped at any time. Versions are defined by tags.

What should the stable branch be named (default: 'master')? <enter>
Your master branch is named 'master'.

You need a branch to integrate and test unstable topics that are not
yet ready to be merged to 'master'.

What should the integration branch be named (default: 'develop')? <enter>
No local branch develop.
No remote branch develop.
Branching develop off of master.
Your develop branch is named 'develop'.

git-topics is setup! See 'git help topics' to get started.
```

Create topic branches with `git topics start` then commit to them as usual.

```
$ git topics start complex-feature
Switched to a new branch 'complex-feature'
$ echo 'complex' >> features
$ git add features
$ git commit -m 'add complex feature'
[complex-feature fe7b3bd] add complex feature
 1 file changed, 1 insertion(+)
 create mode 100644 features
```

```
$ git topics start simple-feature
Switched to a new branch 'simple-feature'
$ echo 'simple' >> features
$ git add features
$ git commit -m 'add simple feature'
[simple-feature 2c4fdd1] add simple feature
 1 file changed, 1 insertion(+)
 create mode 100644 features
```

```
$ git topics
Topics not yet merged:
  (use 'git topics integrate' to promote to develop)

    complex-feature
    simple-feature

```

When a topic is ready for testing, stage it to the integration branch with `git topics integrate`.

```
$ git topics integrate complex-feature
Switched to branch 'develop'
Merge made by the 'recursive' strategy.
 features | 1 +
 1 file changed, 1 insertion(+)
 create mode 100644 features
```

```
$ git log --oneline develop
130eab9 (HEAD -> develop) Merge branch 'complex-feature' into develop
fe7b3bd (complex-feature) add complex feature
d234655 (master) Initial commit
```

```
$ git log --oneline master
d234655 (master) Initial commit
```

```
$ git topics
Topics merged to develop:
  (use 'git topics finish' to promote to master)

    complex-feature

Topics not yet merged:
  (use 'git topics integrate' to promote to develop)

    simple-feature

```

:bulb: **Pro Tip**: [`git log --first-parent`](https://www.git-scm.com/docs/git-log#git-log---first-parent) is useful for looking at `master` and `develop` logs.

You can freely integrate whatever topics are ready to be tested. Just resolve merge conflicts inline.

```
$ git topics integrate simple-feature
Auto-merging features
CONFLICT (add/add): Merge conflict in features
Automatic merge failed; fix conflicts and then commit the result.
```

```
$ git status
On branch develop
You have unmerged paths.
  (fix conflicts and run "git commit")
  (use "git merge --abort" to abort the merge)

Unmerged paths:
  (use "git add <file>..." to mark resolution)

	both added:      features

no changes added to commit (use "git add" and/or "git commit -a")
```

```
$ cat features
<<<<<<< HEAD
complex
=======
simple
>>>>>>> simple-feature
```

```
$ vim features # fix the conflict...
$ git add features
$ git commit # conclude the merge
[develop 488d196] Merge branch 'simple-feature' into develop
```

```
$ git log --oneline --first-parent develop
488d196 (HEAD -> develop) Merge branch 'simple-feature' into develop
130eab9 Merge branch 'complex-feature' into develop
d234655 (master) Initial commit
```

```
$ git log --oneline master
d234655 (master) Initial commit
```

```
$ git topics
Topics merged to develop:
  (use 'git topics finish' to promote to master)

    complex-feature
    simple-feature

```

Once a topic has been tested, it may be promoted to the stable branch independently with `git topics finish`. Because of this independence, merge conflicts may present themselves differently in `master` vs `develop`, so beware of hidden topic dependencies!

```
$ git topics finish complex-feature
Switched to branch 'master'
Merge made by the 'recursive' strategy.
 features | 1 +
 1 file changed, 1 insertion(+)
 create mode 100644 features
```

```
$ git log --oneline --first-parent develop
488d196 (develop) Merge branch 'simple-feature' into develop
130eab9 Merge branch 'complex-feature' into develop
d234655 Initial commit
```

```
$ git log --oneline --first-parent master
861e039 (HEAD -> master) Merge branch 'complex-feature'
d234655 Initial commit
```

```
$ git topics
Topics merged to master:
  (use 'git topics release' to tag a new version)

    complex-feature

Topics merged to develop:
  (use 'git topics finish' to promote to master)

    simple-feature

```

:bulb: **Pro Tip**: [git-rerere](https://git-scm.com/docs/git-rerere) may help avoid having to resolve the same merge conflicts on `master` as you had on `develop`.

When your finished topics are ready to be pushed upstream, tag a new release version with `git topics release`.

```
$ git topics release major # fill out the tag message
Branch complex-feature is not tracking a remote branch.
Deleted branch complex-feature (was fe7b3bd).
```

```
$ git log --oneline --first-parent develop
488d196 (develop) Merge branch 'simple-feature' into develop
130eab9 Merge branch 'complex-feature' into develop
d234655 Initial commit
```

```
$ git log --oneline --first-parent master
861e039 (HEAD -> master, tag: v1.0.0) Merge branch 'complex-feature'
d234655 Initial commit
```

```
$ git topics
Topics merged to develop:
  (use 'git topics finish' to promote to master)

    simple-feature

```

```
$ git tag -n
v1.0.0          First version ever!
```

:bulb: **Pro Tip**: set [`git config tag.sort version:refname`](https://git-scm.com/docs/git-config#git-config-tagsort) so that `git tag -n` outputs tags in the right order.

Check out further features and documentation via the builtin help.

```
$ git topics help
```

## Further Reading

* [Git Branching](https://git-scm.com/book/en/v2/Git-Branching-Branches-in-a-Nutshell)
* [How the Creators of Git Do Branching](https://hackernoon.com/how-the-creators-of-git-do-branches-e6fcc57270fb)
* [gitworkflows(7)](https://git-scm.com/docs/gitworkflows)
* [Markdown versions of the git-topics man-pages](ronn)
* Other git branching models
  * [GitFlow](http://nvie.com/posts/a-successful-git-branching-model/)
  * [GitHub Flow](http://scottchacon.com/2011/08/31/github-flow.html)
  * [GitLab Flow](https://about.gitlab.com/2014/09/29/gitlab-flow/)
  * [OneFlow](http://endoflineblog.com/oneflow-a-git-branching-model-and-workflow)
* [Why git-topics?](RATIONALE.md)
