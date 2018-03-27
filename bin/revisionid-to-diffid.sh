#!/bin/sh

# This script converts a git revision-id (like D1234) to the most recent
# git diff-id (like 192259).  A "diff-id" is an identifier that refers
# to the most recent version of a revision (that is, the state of the
# repo after running the most recent `arc diff`), and phabricator creates
# a git tag for every diff-id, that looks like `phabricator/diff/192259`.
# We can use this with `git checkout` and any other git tool.  But it's
# nice to be able to convert the revision-id to the diff-id automatically,
# which this does.
#
# You need to be able to run `arc` for this to work, which any KA
# employee should already be able to do.  If the input does not look
# like a revision-id, or we can't find a diff-id for it, we return
# the input unchanged.

[ -z "$1" ] && {
    echo "USAGE: $0 <revision-id, e.g. 'D1234'>"
    exit 1
}

revision_id=`echo "$1" | sed -ne 's/^D\([0-9][0-9]*\)$/\1/p'`
[ -z "$revision_id" ] && {
    echo "$1"
    exit 0
}

diff_phid=`echo '{"constraints": {"ids": ['"$revision_id]}}" \
    | arc call-conduit differential.revision.search \
    | grep -o '"diffPHID":"[^"]*"' \
    | cut -d'"' -f4`
[ -z "$diff_phid" ] && {
    echo "$1"
    exit 0
}

diff_id=`echo '{"constraints": {"phids": ["'"$diff_phid"'"]}}' \
    | arc call-conduit differential.diff.search \
    | grep -o '"id":[0-9]*' \
    | cut -d: -f2`
[ -z "$diff_id" ] && {
    echo "$1"
    exit 0
}

echo "$diff_id"
