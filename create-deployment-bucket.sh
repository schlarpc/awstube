#!/bin/bash

set -xeuo pipefail

ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
REGION=$(aws configure get default.region)
DEPLOY_BUCKET=sam-deployment-$ACCOUNT_ID-$REGION
BUCKET_ARGS=$(if [ "$REGION" != "us-east-1" ]; then echo "--create-bucket-configuration LocationConstraint=$REGION"; fi)
aws s3api create-bucket --bucket $DEPLOY_BUCKET $BUCKET_ARGS || true
aws s3api put-bucket-lifecycle-configuration --bucket $DEPLOY_BUCKET --lifecycle-configuration '{"Rules": [{"Expiration": {"Days": 3}, "Status": "Enabled", "Filter": {"Prefix": ""}}]}'
