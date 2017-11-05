# git-topics

A collection of [git](https://git-scm.com/) commands to manage topic branches. The branching model is a simplified version of the concepts described in [gitworkflows(7)](https://git-scm.com/docs/gitworkflows).

## Installation

## Quick Start

## Background

Teams using git typically standardize their process for incorporating changes into their projects. Git itself doesn't enforce any particular practice, but there are several popular approaches:

* [GitFlow](http://nvie.com/posts/a-successful-git-branching-model/)
* [GitHub Flow](http://scottchacon.com/2011/08/31/github-flow.html)
* [GitLab Flow](https://about.gitlab.com/2014/09/29/gitlab-flow/)
* [OneFlow](http://endoflineblog.com/oneflow-a-git-branching-model-and-workflow)

My team has used GitFlow as a sane default for years. It's a very popular branching model, and there is even a cool [git plugin](https://github.com/nvie/gitflow/) that makes adoption very easy. I have no doubt that it's successful with many teams.

However, GitFlow has certain idiosyncrasies. In the beginning, I chalked problems up to user error or "facts of life" rather than the model itself. But years of dealing with the same minor problems over & over again got me thinking: maybe GitFlow (or at least the plugin) just didn't really mesh with my team's exact workflow.

* By default, feature branches are forked off of `develop` and deleted once they're merged back (unless you explicitly use `git flow feature finish -k`). Merging, however, often isn't the end of a feature. My team's `develop` branch gets deployed to the QA environment, so we must merge features to do end-to-end tests. Depending on the outcome, further fixes may still be needed. In practice, these fixes occur either as direct commits on `develop` or as extra feature branches, both of which "lose" the line of history to the original feature.

* Due to the above, GitFlow has limited options for doing "partial" releases. My team would often run into the situation where many independent features are being tested, but naturally not all of them are ready to deploy at the same time. Therefore, `develop` often can't be merged wholesale into `master` on a regular basis. With the original feature branches gone (and based off of the unstable `develop` branch at any rate), your options are either to specify a specific base for a release branch (which only works if features were merged in the "right" order) or start a hotfix and cherry-pick from `develop` (which duplicates commits).

* Hotfix branches are another artifact of features forking off of `develop`, since otherwise you'd just as well use regular feature branches. Moreover, testing a hotfix in the QA environment is clunky when using the git plugin, since `git flow hotfix finish` merges into `develop` *and* `master` at the same time. If any problems are found with the hotfix in `develop`, you have to fix them with yet another hotfix branch + tag.

* While the different types of branches are intuitive, they're more complicated than they have to be. Release branches have never really been necessary for my team (even when `develop` _can_ be cleanly merged into `master`). My team's projects typically involve no extra release steps, so the whole process amounts to `git flow release start <version> && git flow release finish <version>`. The interim branch goes unused and the plugin generates a redundant merge commit. The tags are useful (of course), but the extra branching is unwarranted.

Popular alternatives to GitFlow present their own challenges, especially when migrating a team shaped by GitFlow for so long. Most (like GitHub Flow or OneFlow) eschew the `develop` & `master` separation in favor of continuous integration. For such teams, feature branches can be deployed in independent environments and/or `master` is deployed so often that bugs can be resolved directly in production. But for my team, various factors (operational support, interdependent projects/features, QA process, etc) leave us invested in the two-branch split where `develop` corresponds to the QA environment and `master` corresponds to production.

It took me an embarrassingly long time to hap across the man page sitting right under my nose, [gitworkflows(7)](https://git-scm.com/docs/gitworkflows). And I only found it by way of [a blog post](https://hackernoon.com/how-the-creators-of-git-do-branches-e6fcc57270fb), no less. It too me a little bit longer to grok the four-branch layout described, but it became a lot clearer with some simplification:

* `maint` is unnecessary for my use case. Since my team's projects are generally just web apps with only one version ever running in production, we don't need to backport any fixes to old codebases - just use `master`.
* `master` becomes the most stable branch if we ditch `maint`. Versions are still cut using the same tagging practices I know & love from GitFlow.
* `next` corresponds to `develop` in GitFlow terminology.
* `pu` is optional in the first place, but still a good idea for "playing around" with merging together multiple features before pushing to `next`. It doesn't otherwise factor into the workflow too heavily, so its use can be relegated to a side utility (i.e., `git topics reintegrate --onto pu`).

Effectively, GitFlow's `master` and `develop` are still the key players. All that's left is a straightforward approach that leverages exactly what git is good at: topic branches.

* Fork topics off of `master` to avoid the main problems of GitFlow.
* Merge topics into `develop` (without deleting) to integrate, test, and fix.
* Merge & delete finished topics into `master`.
* Deploy a new version of the project by tagging a commit on `master`.

This simplified version of the gitworkflows model combines the ease of GitHub Flow with the two-branch approach of GitFlow, while recognizing merges as a useful & integral part of git (unlike OneFlow's primary philosophy).

This practice is so vanilla that it can be accomplished pretty easily using standard commands. But, as noted in the very [blog post](https://hackernoon.com/how-the-creators-of-git-do-branches-e6fcc57270fb) that sparked `git-topics`, there are some ways it could be more convenient:

> In addition, an open source toolset around gitworkflow to help with things like rebuilding *pu* and *next*, and tracking the graduation status of topics would be useful — git.git has its "cooking" tools for this purpose, but tooling that is less git.git specific would be nice. As a start, I have created a [few useful aliases](https://gist.github.com/rocketraman/1fdc93feb30aa00f6f3a9d7d732102a9)[1].
>
> But in short, gitworkflow is an excellent Git branching model / workflow for many use cases, and deserves to be more popular than it is. It does require a strong understanding of advanced Git features and concepts, but the effort is well worth it.
>
> [1] See especially the aliases `lgp`, `topics`, `topiclg`, `mergedtopiclg`, `branchnote`, and `where`

`git-topics` is my submission to this call for action. It doesn't implement the *entire* git.git model (which itself is pretty specialized), but it does maintain the core concepts: make topics the center of attention, use long-lived branches with increasing levels of stability, and embrace the power of merging (to the right places!). The model is simple enough that I think `git-topics` essentially amounts to training wheels. But maybe advanced users can still find it useful without being overly prescriptive.
