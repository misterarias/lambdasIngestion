#!/bin/bash

export AWS_REGION="us-east-1"
export AWS_ACCESS_KEY_ID="123456789"
export AWS_SECRET_ACCESS_KEY="supersecret"

SCRIPTDIR=$(cd $(dirname $0) && pwd)
BASEDIR=$(cd $SCRIPTDIR/.. && pwd)

EVENT_FILE="${BASEDIR}/events/register.js"
EVENT_CODE="${BASEDIR}/code/register.py"

[ ! -f $(which python-lambda-local) ] && \
  sudo pip2.7 install -r ${SCRIPTDIR}/requirements.txt

LOG_FILE=$(mktemp /tmp/.event.log.XXXX)
python-lambda-local ${EVENT_CODE} ${EVENT_FILE} > $LOG_FILE

if [ "$(cat ${LOG_FILE} | grep -c -i "error")" -gt 0 ] ; then
  echo "[ERROR] Errors while sending events"
else
  echo "Finished !"
fi

cat ${LOG_FILE}
rm -rf ${LOG_FILE}

exit 0
