#!/bin/bash

shell=/bin/sh
app_name=${APP_NAME}
app_version=${APP_VERSION}
executable=/usr/bin/${app_name}-sync.sh
directories=(/data ${CONFIG_DIR} ${RUN_DIR})
files=(/usr/bin/dijnet-bot-sync.sh /usr/bin/healthchecks_io.sh)

exec_on_startup() {
  set +e
  su "${USER}" -s ${shell} -c ${executable}
  set -e
}

init_config_file() {
  if [ ! -f ${CONFIG_FILE} ]
  then
    echo "INFO: Configuration file ${CONFIG_FILE} does not exists. Copyin template file to location"
    cp /usr/local/dijnet-bot/dijnet-bot.conf.template ${CONFIG_FILE}
    echo "WARNING: please initialize necessary environment variables in config file and restart the container. Exiting"
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

init_user() {
  PUID=${PUID:-$(id -u ${USER})}
  PGID=${PGID:-$(id -g ${GROUP})}

  groupmod -o -g "${PGID}" ${GROUP}
  usermod -o -u "${PUID}" ${USER}

  echo "INFO: Configuring directories ownership. PUID=${PUID}; PGID=${PGID};"
  for directory in ${directories[@]}; do
    echo "INFO: Modifying ownership of directory: ${directory}"
    chown ${USER}:${GROUP} ${directory}
  done

  echo "INFO: Change permissions of executable files"
  for file in ${files[@]}; do
    echo "INFO: Modifying ownership of file: ${file}"
    chown ${USER}:${GROUP} ${file}
  done
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

init_user

init_timezone

exec_on_startup
