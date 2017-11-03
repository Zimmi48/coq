#!/usr/bin/env bash

# This file should be called from the top-level directory of Coq!
export LC_ALL=C
COMPILE_DATE=`date`

echo_version_file() {
    cat <<EOF > version/coqversion.ml
type version = { describe : string; branch : string; hash : string }

let version = { describe = ${GIT_DESCRIBE}; branch = "${GIT_BRANCH}"; hash = "${GIT_HASH}" }

let compile_date = "${COMPILE_DATE}"
EOF
}

if [ -x `which git` ] && [ -d .git ]
then
    echo "We are in a git repository. Generating version/coqversion.ml."
    GIT_DESCRIBE=`git describe --first-parent --dirty | sed 's/^V\(.*\)$/"\1"/'`
    GIT_BRANCH=`git branch -a | sed -ne '/^\* /s/^\* \(.*\)/\1/p'`
    GIT_HASH=`git rev-parse HEAD`
    echo_version_file
elif [ -e version/coqversion.ml ]
then
    echo "File version/coqversion.ml already exists. Doing nothing."
elif "$Format:$" == ""
then
    echo "Files come from a git archive. Generating version/coqversion.ml."
    GIT_REF_NAMES="$Format:%D$"
    GIT_DESCRIBE=$(`echo $GIT_REF_NAMES | sed 's/, /\n/g' | grep tag | sed 's/tag: V\(.*\)$/"\1"/'`:-'"unknown version"')
    GIT_BRANCH=$(`echo $GIT_REF_NAMES | sed 's/, /\n/g' | grep HEAD | sed 's/HEAD ->//'`:-unknown branch)
    GIT_HASH="$Format:%H$"
    echo_version_file
else
    echo "Files come from an unknown source. Generating version/coqversion.ml using default version."
    GIT_DESCRIBE="Coq_config.version"
    GIT_BRANCH="unknown"
    GIT_HASH="unknown"
    echo_version_file
fi
