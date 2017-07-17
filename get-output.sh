#!/bin/bash

set -xeuo pipefail

RESULT=$(aws cloudformation describe-stacks --stack-name awstube --query "Stacks[0].Outputs[?OutputKey==\`$1\`] | [0].OutputValue" --output text)

if [ "$RESULT" = "None" ]; then
    exit 1
else
    echo $RESULT
fi
