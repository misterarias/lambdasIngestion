#!/bin/bash
# Send a request to the RequestEvents endpoint
# If a numeric parameter is present, it is considered the number of seconds to substract
# to current time, in order to get past events.
get_timestamp_seconds_ago() {
  local now=$(date +%s)
  local number_of_seconds=$1

  if [ ! -z "$number_of_seconds" ] ; then
    echo $(( 1000 * $(date +%s --date "@$(( now - number_of_seconds))") ))
  else
    echo "0"
  fi
}

do_curl() {
  local timestamp=$1

  curl -sS -X POST \
    -H 'Content-Type: application/json' \
    -H "Cache-Control: no-cache" \
    -H "x-api-key: ${API_KEY}" \
    -d "{ \"eventType\": \"${TABLE_EVENT_TYPE}\", \"recvTimestamp\": ${timestamp} }" \
    "${API_ENDPOINT_URL}/${ENDPOINT_NAME}"
}

request_events() {
  local event_type=$EVENT_TYPE
  local timestamp=$TIMESTAMP

  local configuration_file="${BASEDIR}/conf/${event_type}.conf"
  local environment_configuraton_file="${ENVDIR}/${ENVIRONMENT}.conf"

  load_configuration_file "$configuration_file" "$environment_configuraton_file"
  do_curl "$(get_timestamp_seconds_ago "$timestamp")"
}

help_and_exit() {
  echo
  echo "Syntax:"
  echo "$SCRIPTNAME <event_type> <environment_name> [<seconds_ago>]"
  echo "Valid event types: $VALID_EVENTS"
  echo "Valid environments: $VALID_ENVIRONMENTS"
  exit 1
}

# Stuff goes here
SCRIPT=$0
if readlink $0 > /dev/null; then SCRIPT=$(dirname $0)/$(readlink $0); else SCRIPT=$0; fi
export SCRIPTNAME=$(basename $SCRIPT)
export SCRIPTDIR=$(dirname $SCRIPT)
export BASEDIR=$(cd "$SCRIPTDIR/.." && pwd)
export LIBDIR=$(cd "$BASEDIR/../../lib" && pwd)
export ENVDIR=$(cd "$BASEDIR/../../environments" && pwd)

# Include helper functions
. ${LIBDIR}/helpers.sh

export ENDPOINT_NAME="RequestEvents"
export EVENT_TYPE=$1
export ENVIRONMENT=$2
export TIMESTAMP=${3:-0}

VALID_EVENTS="$(ls ${BASEDIR}/conf | sed -e 's/.conf//g' | xargs)"
[ -z "$EVENT_TYPE" ] || [ -z "$(echo "$VALID_EVENTS" | grep -o ${EVENT_TYPE})" ] && \
  error "Invalid event type. Valid events are: $VALID_EVENTS" && help_and_exit

VALID_ENVIRONMENTS=$(ls "${ENVDIR}" | sed -e 's/.conf//g' | xargs)
[ -z "$ENVIRONMENT" ] || [ -z "$(echo "$VALID_ENVIRONMENTS" | grep -o ${ENVIRONMENT})" ] && \
  error "Invalid environment: Valid environemnts are $VALID_ENVIRONMENTS" && help_and_exit

request_events
