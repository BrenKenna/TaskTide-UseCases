#!/bin/bash

set -ex

ACTIVE="${ACTIVE:-}"

# Fail if not detected
if [ -z $ACTIVE ]
then
    echo "ERROR: No targeted detected"
    exit 1
fi


# Check if exists
if [[ ! -d "$ACTIVE" ]]
then
    echo "ERROR: active use-case does not exist: $ACTIVE"
    exit 1
fi


# Check if docker file exists
if [ `ls $ACTIVE/ | grep -c "Dockerfile$"` -eq 0 ]
    echo "ERROR: $ACTIVE/Dockerfile missing"
    exit 1
fi


# Check if test exists
if [ ! -f "$ACTIVE/test.sh" ] && [ -x "$ACTIVE/test.sh" ]
then
    echo "ERROR: $ACTIVE/test.sh missing or is not executable"
    exit 1
fi


# Evaluate the test
if [ `grep -c '^set -ex$' "$ACTIVE/test.sh"` -eq 0 ]
    echo "ERROR: test.sh must contain 'set -ex'"
    exit 1
fi


# Check that markdowns are present
if [ `find "$ACTIVE" -maxdepth 1 -type f -name '*.md' | wc -l` -eq 0 |
then
    echo "ERROR: use-case must contain Markdown documentation"
    exit 1
fi


# Otherwise good
echo "Use-case structure OK: $ACTIVE"