#!/bin/bash

shell=/bin/sh
app_name=${APP_NAME}
app_version=${APP_VERSION}
directories=(/data ${CONFIG_DIR} ${RUN_DIR})

exec_on_startup() {
  set +e
  /usr/local/bin/dijnet-bot-sync.sh
  set -e
}

init_config_file() {
  if [ ! -f ${CONFIG_FILE} ]
  then
    echo "INFO: Configuration file ${CONFIG_FILE} does not exists."
    exit 1
  fi
}

init_timezone() {
  # Set time zone if passed in
  if [ ! -z "${TZ}" ]
  then
    echo "INFO: Configuring timezone for: ${TZ}." 

    cp /usr/share/zoneinfo/${TZ} /etc/localtime
    echo ${TZ} > /etc/timezone
  fi
}

set -e

# Announce version
echo "INFO: Running ${app_name} version: ${app_version}"

if [ -z "${PGID}" -a ! -z "${PUID}" ] || [ -z "${PUID}" -a ! -z "${PGID}" ]; then
  echo "WARNING: Must supply both PUID and PGID or neither. Stopping."
  exit 1
elif [ ! -z "${TZ}" -a ! -f /usr/share/zoneinfo/${TZ} ]; then
  echo "WARNING: TZ was set '${TZ}', but corresponding zoneinfo file does not exist. Stopping."
  exit 1
fi

init_config_file

init_timezone

exec_on_startup
