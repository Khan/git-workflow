#!/bin/sh

# This script converts a phabriactor revision-id (like D1234) or
# a github pull-request id (like 1234 or #1234) to a tag or
# branch that refers to that revision.
#
# For phabricator, the output is a git tag that looks like
# `phabricator/diff/192259`.  A "diff-id" is an identifier that refers
# to the most recent version of a revision (that is, the state of the
# repo after running the most recent `arc diff`), and phabricator
# creates a git tag for every diff-id.  We can use this with `git
# checkout` and any other git tool.  But it's nice to be able to
# convert the revision-id to the diff-id automatically, which this
# does.
#
# For github, the output is the branch that the pull-request was
# pushed to.
#
# For phabricator, you need to be able to run `arc` for this to work,
# which any KA employee should already be able to do.  For github,
# you need to install github's `gh` commandline tool, which is not
# done by default.
#
# If the input does not look like a revision-id, or we can't find a
# diff-id for it, we return the input unchanged.

# We used to distinguish `--tag` mode from normal mode, but don't anymore.
[ "$1" = "--tag" ] && shift

[ -z "$1" ] && {
    echo "USAGE: $0 <github PR or phabricator revision id>"
    echo "       github PRs should look like, e.g., '1234' or '#1234'."
    echo "       phabricator revision-id's should look like, e.g., 'D1234'."
    exit 1
}

resolve_phabricator() {
    diff_phid=`echo '{"constraints": {"ids": ['"$revision_id]}}" \
        | arc call-conduit -- differential.revision.search \
        | grep -o '"diffPHID": *"[^"]*"' \
        | cut -d'"' -f4`
    [ -z "$diff_phid" ] && {
        echo "$1"
        return
    }

    diff_id=`echo '{"constraints": {"phids": ["'"$diff_phid"'"]}}' \
        | arc call-conduit -- differential.diff.search \
        | grep -o '"id": *[0-9]*' \
        | cut -d: -f2 \
        | sed 's/^ *//'`
    [ -z "$diff_id" ] && {
        echo "$1"
        return
    }

    full_tag="phabricator/diff/$diff_id"
    # Make sure the tag exists locally, too.
    git show-ref "$full_tag" >/dev/null 2>&1 \
        || git fetch origin "refs/tags/$full_tag:refs/tags/$full_tag" >&2 \
        || echo "WARNING: unable to fetch '$full_tag'; perhaps it was never pushed?" >&2
    echo "$full_tag"
}

resolve_github() {
    which gh >/dev/null 2>&1 || {
        echo "You must install the 'gh' tool to resolve a github PR." >&2
        exit 1
    }

    json=`gh pr view --json headRefName "$1"`
    # Don't bother with jq -- it's another dep, and this is easy enough
    # to parse manually.
    branch=`echo "$json" | sed -ne 's/.*"headRefName": *"\([^"]*\)".*/\1/p'`
    # Make sure the branch exists locally, too.
    git fetch origin "$branch" >&2 \
        || echo "WARNING: unable to fetch '$branch'; perhaps it was never pushed?" >&2
    echo "$branch"
}

revision_id=`echo "$1" | sed -ne 's/^D\([0-9][0-9]*\)$/\1/p'`
[ -n "$revision_id" ] && {
    resolve_phabricator "$1"
    exit 0
}

pr=`echo "$1" | sed -ne 's/^#*\([0-9][0-9]*\)$/\1/p'`
[ -n "$pr" ] && {
    resolve_github "$1"
    exit 0
}

# Return the input unchanged.  This is important for `git co`, which
# just calls `revisionid-to-diffid.sh` unconditionally, and depends
# on it returning its output (e.g. a branchname) unchanged if it
# doesn't look like a revision-id.
echo "$1"
