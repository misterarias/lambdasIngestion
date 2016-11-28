#!/bin/sh

error() {
  echo "$* :(" && exit 1
}

SCRIPTDIR=$(cd $(dirname $0) ; pwd)
ENDPOINT_NAME="$1"
[ -z "$ENDPOINT_NAME" ] && \
  error "Function name to upload is needed"

CODEDIR="${SCRIPTDIR}/../functions/${ENDPOINT_NAME}/code"
[ ! -d ${CODEDIR} ] && \
  error  "Function directory does not exist"

# If there is a requirements.txt file, install it along the code
if [ -f ${CODEDIR}/requirements.txt ] ; then
  pip install -r ${CODEDIR}/requirements.txt -t ${CODEDIR}
  [ $? -ne 0 ] && error "Unable to install or update requirements"
fi

# XXX: Node.js might require a local package.json file

# Make sure Alias is named like this in AWS Lambda Console
ENDPOINT_ALIAS_NAME="${ENDPOINT_NAME}Alias"
LOWER_CASE_NAME=$(echo $ENDPOINT_NAME | tr '[:upper:]' '[:lower:]')
ZIPFILE="$SCRIPTDIR/${LOWER_CASE_NAME}.zip"

# Needs the AWS CLI tools installed
COMMAND="aws lambda"

# Code needs to be deployed directly, no directories in the middle
(cd "${CODEDIR}" ; zip -r ${ZIPFILE} * > /dev/null)
[ $? -ne 0 ] && error "Unable to zip code into a package"

$COMMAND update-function-code --function-name ${ENDPOINT_NAME} --zip-file "fileb://$ZIPFILE"
[ $? -ne 0 ] && \
  rm -rf $ZIPFILE  &&  error "Unable to update code"

VERSION=$($COMMAND publish-version --function-name ${ENDPOINT_NAME} | jq -c .Version | tr -d '"')
[ -z "$VERSION" ] && \
  rm -rf $ZIPFILE  &&  error "Unable to publish version"

$COMMAND update-alias --function-name ${ENDPOINT_NAME}  --name ${ENDPOINT_ALIAS_NAME} --function-version $VERSION

rm -rf $ZIPFILE
echo "Super :)"
