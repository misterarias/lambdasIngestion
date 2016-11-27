#!/bin/sh

SCRIPTDIR=$(cd $(dirname $0) ; pwd)
ZIPFILE="$SCRIPTDIR/PutEvents.zip"
COMMAND="aws lambda"
FUNCTION_NAME="PutEvents"
ALIAS_NAME="PutEventAlias"

# Code needs to be deployed directly, no directories in the middle
(cd "${SCRIPTDIR}/../code" ; zip -r ${ZIPFILE} PutEvents.js)

$COMMAND update-function-code --function-name ${FUNCTION_NAME} --zip-file "fileb://$ZIPFILE"
[ $? -ne 0 ] && \
  echo "Unable to update code :(" && rm -rf $ZIPFILE && exit 1

VERSION=$($COMMAND publish-version --function-name ${FUNCTION_NAME} | jq -c .Version | tr -d '"')
[ -z "$VERSION" ] && \
  echo "Unable to publish-version :(" && rm -rf $ZIPFILE && exit 1

$COMMAND update-alias --function-name ${FUNCTION_NAME}  --name ${ALIAS_NAME} --function-version $VERSION

rm -rf $ZIPFILE
