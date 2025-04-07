# khan academy git-workflow

> Collection of scripts used to enable the [git workflow][git-at-ka]
at Khan Academy. (see also: [arcanist])

[git-at-ka]: https://khanacademy.org/r/git-at-ka
[arcanist]:  https://github.com/khan/arcanist

> ### NOTE: As of Spring 2025, the scripts in _*this*_ repository are no longer in use at Khan Academy. They have been combined with Our Lovely CLI, so please make any future changes in that repo. This repo is preserved here for historical purposes.

#### git deploy-branch
Creates a remote _deploy branch_ for use with GitHub-style deploys.

For GitHub-style deploys, all work must branch off a deploy branch.

#### git review-branch
Creates a new local branch ensuring that it's not based off master.
Such a branch is called a _review branch_.

All review branches should be based off a deploy branch.

#### git recursive-grep
Runs git grep recursively through submodules, showing file paths
relative to cwd.

#### git find-reviewers
Find the best reviewer(s) for a given changeset. The idea is that if one user
has modified all the lines you are editing, they are a good candidate to review
your change.
