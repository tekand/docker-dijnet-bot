#!/bin/sh

. /usr/local/bin/healthchecks_io.sh

is_dijnet_bot_running() {
  if [ $(lsof | grep $0 | wc -l | tr -d ' ') -gt 1 ]
  then
    return 0
  else
    return 1
  fi
}

dijnet_bot_cmd_exec() {
  CMD="node /usr/local/bin/dijnet-bot.cjs"

  echo "INFO: Executing: ${CMD}"
  set +e
  eval ${CMD}
  return_code=$?
  set -e

  return ${return_code}
}

set -e

echo "INFO: Starting $0 pid $$ $(date)"

if is_dijnet_bot_running
then
  echo "WARNING: A previous application instance is still running. Skipping command."
else
  echo $$ > ${PID_FILE}
  echo "INFO: PID file created successfuly: ${PID_FILE}"

  echo "INFO: Reading config file: ${CONFIG_FILE}"
  set -o allexport
  . ${CONFIG_FILE}
  set +o allexport

  healthchecks_io_start 

  dijnet_bot_cmd_exec

  healthchecks_io_end $?

  echo "INFO: Removing PID file"
  rm -f ${PID_FILE}
fi
