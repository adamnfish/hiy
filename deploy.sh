#!/usr/bin/env bash

# build API
sbt test "project api" assembly || exit

# build frontend
pushd frontend || exit
#elm-app test || exit
elm-app build || exit
popd || exit

# build CDK app
pushd cdk || exit
npm run build || exit
# do CDK deployment
cdk deploy --profile "$1" 2>&1 | tee cdk-output.log || exit
WEBROOT_BUCKET_NAME=$(cat cdk-output.log | grep webrootbucket | cut -d ' ' -f 3) || exit
DISTRIBUTION_ID=$(cat cdk-output.log | grep distributionid | cut -d ' ' -f 3) || exit
echo "Webroot bucket: $WEBROOT_BUCKET_NAME"
echo "Distribution ID: $DISTRIBUTION_ID"
rm cdk-output.log
popd || exit

# deploy frontend and decache
pushd frontend/build || exit
aws s3 sync . s3://$WEBROOT_BUCKET_NAME --profile "$1" || exit
aws cloudfront create-invalidation --distribution-id $DISTRIBUTION_ID --paths "/*" --profile "$1" || exit
popd || exit
