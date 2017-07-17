#!/bin/bash

set -xeuo pipefail

ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
REGION=$(aws configure get default.region)
DEPLOY_BUCKET=sam-deployment-$ACCOUNT_ID-$REGION
FRONTEND_PATH=$(head -c16 < <(tr -dc 'a-z' < /dev/urandom))

if FRONTEND_BUCKET=$(./get-output.sh FrontendBucketName); then
    INITIAL_DEPLOY=false
    aws s3 sync ./frontend s3://$FRONTEND_BUCKET/$FRONTEND_PATH
else
    INITIAL_DEPLOY=true
fi

aws cloudformation package --template-file template.yaml --s3-bucket $DEPLOY_BUCKET > template-packaged.yaml
aws cloudformation deploy --template-file template-packaged.yaml --stack-name awstube --capabilities CAPABILITY_IAM \
    --parameter-overrides FrontendOriginPath=$FRONTEND_PATH

if [ "$INITIAL_DEPLOY" = "true" ]; then
    FRONTEND_BUCKET=$(./get-output.sh FrontendBucketName)
    aws s3 sync ./frontend s3://$FRONTEND_BUCKET/$FRONTEND_PATH
fi

aws configure set preview.cloudfront true
aws cloudfront create-invalidation --distribution-id $(./get-output.sh FrontendDistributionId) --paths '/*'
