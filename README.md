# khan academy git-workflow

Collection of scripts in order to enable the [git workflow][git-at-ka]
at Khan Academy. (see also: [arcanist])

[git-at-ka]: https://khanacademy.org/r/git-at-ka
[arcanist]:  https://github.com/khan/arcanist

## Tools

#### git deploy-branch
Creates a remote deploy branch for use with GitHub-style deploys.

For GitHub-style deploys, all work must branch off a deploy branch.

#### git review-branch
Creates a new local branch ensuring that it's not based off master.
Such a branch is called a 'review branch'.

All review branches should be based off a deploy branch.

#### git recursive-grep
Runs git grep recursively through submodules, showing file paths
relative to cwd.
