#!/bin/bash

HOSTNAME=$(hostname -f)
SHORT_HOSTNAME=$(hostname)

APP_OWNER=appowner

# override BIN_DIR
BIN_DIR=$( cd $(dirname $0) ; pwd -P )

export APP_HOME=/apps/stash
export APP_DIR=${APP_HOME}/atlassian-stash
export APP_START_SCRIPT=${APP_DIR}/bin/start-stash.sh
export APP_STOP_SCRIPT=${APP_DIR}/bin/stop-stash.sh

export LOG_DIR="$(dirname ${BIN_DIR})/logs"
export LOG_FILE=${LOG_DIR}/${SHORT_HOSTNAME}-stash-monitor.log

export APP_PORT=7990
export PIDFILE=${BIN_DIR}/${SHORT_HOSTNAME}-stash-monitor.pid

setenv_showVars()
{
    echo "HOSTNAME=${HOSTNAME}"
    echo "SHORT_HOSTNAME=${SHORT_HOSTNAME}"
    echo "BIN_DIR=${BIN_DIR}"

    echo "APP_OWNER=${APP_OWNER}"
    echo "APP_HOME=${APP_HOME}"
    echo "APP_DIR=${APP_DIR}"
    echo "APP_START_SCRIPT=${APP_START_SCRIPT}"
    echo "APP_STOP_SCRIPT=${APP_STOP_SCRIPT}"

    echo "LOG_DIR=${LOG_DIR}"
    echo "LOG_FILE=${LOG_FILE}"

    echo "APP_PORT=${APP_PORT}"
    echo "PIDFILE=${PIDFILE}"
}

#setenv_showVars
