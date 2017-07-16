#!/bin/bash

set -xeuo pipefail

ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
REGION=$(aws configure get default.region)
DEPLOY_BUCKET=sam-deployment-$ACCOUNT_ID-$REGION
aws cloudformation package --template-file template.yaml --s3-bucket $DEPLOY_BUCKET > template-packaged.yaml
aws cloudformation deploy --template-file template-packaged.yaml --stack-name awstube --capabilities CAPABILITY_IAM
