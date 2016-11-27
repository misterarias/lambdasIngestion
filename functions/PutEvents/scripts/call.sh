#!/bin/bash

get_api_data_file() {
  if [ -f "$API_DATA_FILE" ] ; then
    echo "$API_DATA_FILE"
  else
    local relative_file="$BASEDIR/$API_DATA_FILE"
    [ ! -f "$relative_file" ] && error "Cannot find '$API_DATA_FILE' neither globally or relative to '$BASEDIR'" && exit 1
    echo "$relative_file"
  fi
}

do_curl() {
  local api_file=$(get_api_data_file)

  curl -sS -X POST \
    -H "Content-Type: application/json" \
    -H "Cache-Control: no-cache" \
    -H "x-api-key: ${API_KEY}" \
    --data-binary "@${api_file}" \
    "${API_ENDPOINT_URL}/${ENDPOINT_NAME}"
}

put_events() {

  local event_type=$EVENT_TYPE

  local configuration_file="${BASEDIR}/conf/${event_type}.conf"
  local environment_configuraton_file="${ENVDIR}/${ENVIRONMENT}.conf"

  load_configuration_file "$configuration_file" "$environment_configuraton_file"
  do_curl
}

help_and_exit() {
  echo
  echo "Syntax:"
  echo "$SCRIPTNAME <event_type> <environment_name>"
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
source ${LIBDIR}/helpers.sh

export ENDPOINT_NAME="PutEvents"
export ENVIRONMENT=$1
export EVENT_TYPE=$2

VALID_EVENTS="$(ls ${BASEDIR}/conf | sed -e 's/.conf//g' | xargs)"
[ -z "$EVENT_TYPE" ] || [ -z "$(echo "$VALID_EVENTS" | grep -o ${EVENT_TYPE})" ] && \
  error "Invalid event type. Valid events are: $VALID_EVENTS" && help_and_exit

VALID_ENVIRONMENTS=$(ls "${ENVDIR}" | sed -e 's/.conf//g' | xargs)
[ -z "$ENVIRONMENT" ] || [ -z "$(echo "$VALID_ENVIRONMENTS" | grep -o ${ENVIRONMENT})" ] && \
  error "Invalid environment: Valid environemnts are $VALID_ENVIRONMENTS" && help_and_exit

put_events
