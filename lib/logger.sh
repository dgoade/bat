#!/bin/bash

declare LOGGER_DEFAULT_LOG_LEVEL=1

logger_showVars ()
{
    logger_showVar LOGGER_DEFAULT_LOG_LEVEL
    logger_showVar LOGGER_BASE_NAME
    logger_showVar LOGGER_BASE_DIR
    logger_showVar LOGGER_LIB_DIR
    logger_showVar LOGGER_LOG_LEVEL
    logger_showVar LOGGER_DEFAULT_LOG_LEVEL
    logger_showVar LOGGER_VEROSE
    logger_showVar LOGGER_DATE_FORMAT
    logger_showVar LOGGER_LOG_DIR
    logger_showVar LOGGER_LOG_FILE
    logger_showVar LOGGER_SYSLOG
    logger_showVar LOGGER_SYSLOG_MSG_FORMAT
    logger_showVar LOGGER_SYSLOG_FACILITY
}

logger_libdir ()
{

    declare RVAL
    declare THIS_DIR="${1}"
    declare BASE_NAME
    declare BASE_DIR

    if [ "x${THIS_DIR}" = "x" ]
    then
        : # dir was not predefined 
    else
        if [ -d "${THIS_DIR}" ]
        then
            RVAL="${THIS_DIR}"
        fi
    fi

    if [ "x${RVAL}" = "x" ]
    then 
        BASE_NAME=$(basename $0)
        BASE_DIR=$( cd $(dirname ${BASE_NAME}) ; pwd -P )

        # Is there a lib subdirectory? 
        if [ -d ${BASE_DIR}/lib ]
        then    
            # use it
            RVAL=${BASE_DIR}/lib
        else
            # otherwise, default to the current dir 
            RVAL=${BASE_DIR}
        fi
    fi

    echo ${RVAL}

}

logger_init ()
{

    declare -i RVAL=0
    declare LOG_DIR

    LOGGER_BASE_NAME=$(basename $0)
    LOGGER_BASE_DIR=$( cd $(dirname ${LOGGER_BASE_NAME}) ; pwd -P )

    LOGGER_LIB_DIR=$(logger_libdir "${LOGGER_LIB_DIR}")

    if [ -f ${LOGGER_LIB_DIR}/utils.sh ] 
    then

        source ${LOGGER_LIB_DIR}/utils.sh
        
        utils_fileExecutable "${LOGGER_LIB_DIR}/log4bash.sh"
        RVAL=$?
        if [ $RVAL == 0 ] 
        then

            if logger_set_L4B_settings
            then
                :
            else
                RVAL=1
            fi

        else
            RVAL=1
        fi
    else
        echo "utils.sh not found at ${LOGGER_LIB_DIR}/utils.sh"        
        RVAL=1
    fi

    return $RVAL

}

logger_set_L4B_settings ()
{

    declare -i RVAL=0
    declare LOG_DIR
    declare DEFAULT_LOG

    L4B_DEBUGLVL=${LOGGER_LOG_LEVEL:-${LOGGER_DEFAULT_LOG_LEVEL}} # default log level 
    L4B_VERBOSE=${LOGGER_VERBOSE:-true}
    L4B_DATEFORMAT=${LOGGER_DATE_FORMAT:-"+%Y-%m-%d %H:%M:%S"}

    # L4B Log directory and filename -- can be overridden

    if utils_dirReady "${LOGGER_LOG_DIR}"
    then
        :
        # Get the fully-qualified path to the directory
        LOGGER_LOG_DIR=$( cd ${LOGGER_LOG_DIR} ; pwd -P )
    else
        :
        # The log dir will only be created if / when the first 
        # message is written to it. You cannot use the technique
        # above to get the fully-qualified name of a directory 
        # that doesn't exist so you'll just have to use relative
        # pathing until something triggers the script to create it.
        # logger_rotateLogs takes the opportunity to convert the
        # relative path to an absolute one too but I'm not sure
        # that will ever be necessary.
    fi 

    # Don't need to log all of these utils_dirReady calls
    utils_flushLogQ utils_dirReady

    LOG_DIR="${LOGGER_LOG_DIR:-${LOGGER_BASE_DIR}/logs}"
    DEFAULT_LOG="${LOGGER_BASE_NAME%.*}.log"

    LOGGER_LOG_FILE="${LOGGER_LOG_FILE:-${DEFAULT_LOG}}"

    L4B_LOGFILE="${LOG_DIR:-.}/${LOGGER_LOG_FILE}"
    #L4B_LOGFILE="${LOG_DIR:-.}/${LOGGER_LOG_FILE:-${DEFAULT_LOG}}"

    return ${RVAL}

}

logger_setLogDir()
{

    declare -i rval=0

    LOGGER_LOG_DIR="${1}"
    logger_set_L4B_settings

    return ${rval}
  
}

logger_getLogDir()
{

    declare rval

    rval="${LOGGER_LOG_DIR}"

    echo "${rval}"
  
}

logger_setLogFile()
{

    declare -i rval=0

    LOGGER_LOG_FILE="${1}"
    logger_set_L4B_settings

    return ${rval}
  
}

logger_getLogFile()
{

    declare rval

    #rval="${L4B_LOGFILE}"
    rval="${LOGGER_LOG_FILE}"

    echo "${rval}"
  
}

logger_getLogPath()
{

    declare rval

    #rval="${L4B_LOGFILE}"
    rval="${LOGGER_LOG_DIR}/${LOGGER_LOG_FILE}"

    echo "${rval}"
  
}

logger_globalLogLevelDesc()
{
    declare rval
    rval=$(logger_logLevelDesc ${LOGGER_LOG_LEVEL})
    echo ${rval}
}

logger_logLevelDesc()
{

    declare rval
    declare LOG_LEVEL="${1}" 

    case ${LOG_LEVEL} in 

        0)  rval="DEBUG" ;;
        1)  rval="INFO" ;;
        2)  rval="WARN" ;;
        3)  rval="ERROR" ;;
        4)  rval="CRITICAL" ;;
        5)  rval="FATAL" ;;
        *)  rval="UNKNOWN" ;;

    esac

    echo "${rval}"

}

logger_globalLogLevel()
{
    declare rval="${LOGGER_LOG_LEVEL}"
    echo "${rval}"
}

logger_logQ ()
{

    declare funcName=$1
    declare indexes
    declare ndx
    declare logLevel
    declare logMsg
    declare logLineNo
    declare logFuncName

    indexes=$(eval echo $(eval echo \${!${1}_LOG_LEVEL[@]}))
    #indexes=${!${funcName}_LOG_LEVEL[@]}

    #echo "indexes=${indexes}"

    for ndx in ${indexes}
    do

        logLevel=$(eval echo \${${1}_LOG_LEVEL[${ndx}]})
        logMsg=$(eval echo \${${1}_LOG_MSG[${ndx}]})
        logLineNo=$(eval echo \${${1}_LOG_LINENO[${ndx}]})
        logFuncName=$(eval echo \${${1}_LOG_FUNCNAME[${ndx}]})

        #logLevel=${!${funcName}_LOG_LEVEL[${ndx}]}
        #logMsg=${!${funcName}_LOG_MSG[${ndx}]}
        #logLineNo=${!${funcName}_LOG_LINENO[${ndx}]}
        #logFuncName=${!${funcName}_LOG_FUNCNAME[${ndx}]}

        #echo "logMsg=${LOG_MSG}"
        #echo "logFuncName=${LOG_FUNCNAME}"

        logger_logit "${logLevel}" "${logMsg}" "${logLineNo}" \
            "${logFuncName}"

    done

    if utils_flushLogQ "${1}"
    then
        :
    else
        :
    fi

}

logger_flushLogQ ()
{

    declare -i RVAL=0

    unset $(eval echo ${1}_LOG_LEVEL) 
    unset $(eval echo ${1}_LOG_MSG) 
    unset $(eval echo ${1}_LOG_LINENO) 
    unset $(eval echo ${1}_LOG_FUNCNAME) 

    return ${RVAL}

}


logger_syslogit () 
{

    declare -i RVAL
    #declare SYSLOG_LEVEL="${1}"
    declare SYSLOG_LEVEL="$(logger_logLevelDesc ${1})"
    declare SYSLOG_MSG="${2}"
    declare SYSLOG_LINENO="${3}"
    declare SYSLOG_FUNCNAME="${4}"
    declare SYSLOG_MSG_PREFIX="${LOGGER_SYSLOG_MSG_PREFIX}"
    declare SYSLOG_PROGRAM="${LOGGER_SYSLOG_PROGRAM:-logger}"
    declare SYSLOG_OPTIONS="${LOGGER_SYSLOG_OPTIONS:-"-p"}"
    declare SYSLOG_FACILITY="${LOGGER_SYSLOG_FACILITY:-"local0.info"}"
    declare FORMATTED_MSG=${LOGGER_SYSLOG_FORMAT}
    declare COMMAND

    if [ -n "${SYSLOG_MSG}" ]
    then

        COMMAND="${SYSLOG_PROGRAM} ${SYSLOG_OPTIONS} ${SYSLOG_FACILITY}\
            \"${FORMATTED_MSG}\""

        eval ${COMMAND}
        RVAL=$?
            
        if [ ${RVAL} == 0 ]
        then
            :
            #logger_logit ${L4B_DEBUG} "logger_syslogit succeeded -- message\ 
            #    was sent to syslogd." ${LINENO} ${FUNCNAME} 
        else
            logger_logit ${L4B_ERROR} "logger_syslogit failed -- message was \
                not sent to syslogd." ${LINENO} ${FUNCNAME} 
        fi
    fi

}


logger_logit ()
{

    declare -i RVAL=0
    declare LOG_LEVEL=${1}
    declare LOG_MSG="${2:-""}"
    declare LOG_LINENO=${3:-${BASH_LINENO[0]}}
    declare LOG_FUNCNAME=${4:-${FUNCNAME[1]}}
    declare LOG_DIR

    declare CALL_STACK=$(utils_callStack)

    if logger_set_L4B_settings
    then

        LOG_LEVEL=`utils_upper ${LOG_LEVEL}`
        case ${LOG_LEVEL} in
            0|DEBUG)  LOG_LEVEL=${L4B_DEBUG} ;;
            1|INFO)   LOG_LEVEL=${L4B_INFO} ;;
            2|WARN)   LOG_LEVEL=${L4B_WARN} ;;
            3|ERROR)  LOG_LEVEL=${L4B_ERROR} ;;
            4|CRITICAL)  LOG_LEVEL=${L4B_CRITICAL} ;;
            5|FATAL)  LOG_LEVEL=${L4B_FATAL} ;;
            *)  LOG_LEVEL=${L4B_FATAL} ;;
        esac

        if [ "${LOG_LEVEL}" -ge ${L4B_DEBUGLVL:-0} ]
        then
            # This is a message that will be logged
            if [ ${L4B_LOGFILE} = "/dev/null" ] 
            then
                # don't make a log dir if all
                # logging will be to stdout
                : 
            else
                LOG_DIR=`dirname ${L4B_LOGFILE}`
                mkdir -p $LOG_DIR
            fi

            if utils_true ${LOGGER_SYSLOG}
            then
                logger_syslogit "${LOG_LEVEL}" "${LOG_MSG}" "${LOG_LINENO}"\
                     "${LOG_FUNCNAME}"
            fi

        else
            :
            # This is a message that will not be logged            
        fi

        # Let log4bash figure-out whether and what to log
        log4bash "${LOG_LEVEL}" "${LOG_MSG}" "${LOG_LINENO}" "${LOG_FUNCNAME}"
        #log4bash "${LOG_LEVEL}" "${LOG_MSG}" "${LOG_LINENO}" "${CALL_STACK}"

    else
        RVAL=1
    fi

    return ${RVAL}

}

logger_defaultLogRotateConf ()
{

    declare -i RVAL=1
    declare CONF_FILE_NAME=${1}
    declare LOG_DIR=${2}
    declare LOGS_GLOB=${3:-*.log}
    declare LOG_MSG

    if [ -z ${CONF_FILE_NAME} ]
    then
        LOG_MSG="conf file name passed to logger_defaultLogRotateConf is null." 
        logger_logit "${L4B_ERROR}" "${LOG_MSG}" "${LINENO}" "${FUNCNAME}"
    else
        LOG_MSG="Creating default logrotate conf file: ${CONF_FILE_NAME}."
        logger_logit "${L4B_DEBUG}" "${LOG_MSG}" "${LINENO}" "${FUNCNAME}"

cat > ${CONF_FILE_NAME} <<End-of-logrotate.conf
compress

${LOG_DIR}/${LOGS_GLOB} {
    rotate 20
    copytruncate
    missingok
}
End-of-logrotate.conf

        if [ -f ${CONF_FILE_NAME} ]
        then
            LOG_MSG="Succesfully created default logrotate conf file:"
            LOG_MSG="${LOG_MSG} ${CONF_FILE_NAME}."
            logger_logit "${L4B_DEBUG}" "${LOG_MSG}" "${LINENO}" "${FUNCNAME}"
            RVAL=0
        else
            LOG_MSG="Failed to create default logrotate conf file"
            LOG_MSG="${LOG_MSG} ${CONF_FILE_NAME}." 
            logger_logit "${L4B_ERROR}" "${LOG_MSG}" "${LINENO}" "${FUNCNAME}"
        fi
    fi

    return ${RVAL}

}

logger_rotateLogs ()
{

    declare -i RVAL
    declare BASE_NAME
    declare BASE_DIR
    declare LOG_MSG
    declare LOG_DIR
    declare LOGROTATE_PROGRAM
    declare LOGROTATE_CONF
    declare LOGROTATE_LOG
    declare LOGROTATE_STATE
    declare LOGROTATE_OPTS
    declare COMMAND
    declare STDOUT=./logrotate.stdout

    RVAL=0

    BASE_NAME=${LOGGER_BASE_NAME}
    BASE_DIR=${LOGGER_BASE_DIR}
    LOG_DIR=`dirname ${L4B_LOGFILE}`
    LOGROTATE_PROGRAM=/usr/sbin/logrotate
    LOGROTATE_CONF="${LOG_DIR}/${BASE_NAME%.*}.logrotate"
    LOGROTATE_STATE="${LOG_DIR}/logrotate.state"
    #LOGROTATE_LOG="${LOG_DIR}/logrotate.log"
    LOGROTATE_LOG=${L4B_LOGFILE}
    LOGROTATE_OPTS="-s ${LOGROTATE_STATE} --force" 

    logger_set_L4B_settings

    if [ -d ${LOG_DIR} ]
    then

        # You know the log directory at least exists so
        # go ahead and convert it to fully-qualified. 
        #LOG_DIR=$( cd $(dirname ${LOG_DIR}) ; pwd -P )
        LOG_DIR=$( cd ${LOG_DIR} ; pwd -P )
        LOGGER_LOG_DIR=${LOG_DIR}

        if ! ls -1 ${LOG_DIR}/* >/dev/null 2>&1
        then
            : # echo "No logs to rotate"
        else

            logger_logit "${L4B_DEBUG}" "Rotating logs in ${LOG_DIR}"
    
            utils_fileExecutable "${LOGROTATE_PROGRAM}"
            RVAL=$?
            logger_logQ "utils_fileExecutable"
            if [ $RVAL == 0 ] 
            then 
                LOG_MSG="Found logrotate program file at:" 
                LOG_MSG="${LOG_MSG} ${LOGROTATE_PROGRAM}." 
                logger_logit "${L4B_DEBUG}" "${LOG_MSG}"
            else
                LOG_MSG="Failed to find logrotate program file at:"
                LOG_MSG=" ${LOGROTATE_PROGRAM}." 
                logger_logit "${L4B_ERROR}" "${LOG_MSG}"
                RVAL=1
            fi

            if [ $RVAL == 0 ] 
            then 
                if [ -f ${LOGROTATE_CONF} ]
                then 
                    LOG_MSG="Found logrotate conf file at: ${LOGROTATE_CONF}." 
                    logger_logit "${L4B_DEBUG}" "${LOG_MSG}"
                else
                    LOG_MSG="No logrotate conf file at: ${LOGROTATE_CONF}." 
                    logger_logit "${L4B_DEBUG}" "${LOG_MSG}"

                    logger_defaultLogRotateConf "${LOGROTATE_CONF}"\
                        "${LOG_DIR}"
                    RVAL=$?
                fi
            fi

            if [ $RVAL == 0 ] 
            then 

                if (( ${L4B_DEBUGLVL} < 1))
                then
                    #LOGROTATE_OPTS="${LOGROTATE_OPTS} -v" 
                    COMMAND="${LOGROTATE_PROGRAM} ${LOGROTATE_CONF}\
                         ${LOGROTATE_OPTS} > ${STDOUT}" 
                else
                    COMMAND="${LOGROTATE_PROGRAM} ${LOGROTATE_CONF}\
                         ${LOGROTATE_OPTS}" 
                fi

                COMMAND="${LOGROTATE_PROGRAM} ${LOGROTATE_CONF}\
                     ${LOGROTATE_OPTS}" 

                utils_exec "${COMMAND}"         
                RVAL=$?
                LOG_MSG="logrotate execution logged the following..."
                logger_logit ${L4B_DEBUG} "${LOG_MSG}"
                logger_logQ "utils_exec"
                    
                if (( ${L4B_DEBUGLVL} < 1))
                then
                    if [ -f ${STDOUT} ]
                    then
                        LOG_MSG="logrotate execution logged the following..."
                        LOG_MSG="${LOG_MSG} $(cat ${STDOUT})"
                        logger_logit ${L4B_DEBUG} "${LOG_MSG}"
                    fi
                fi

            else
                LOG_MSG="Cannot use logrotate due to previous errors."
                LOG_MSG="${LOG_MSG} Logs will not be rotated." 
                logger_logit "${L4B_ERROR}" "${LOG_MSG}"
            fi

        fi # [ ! -f ${LOG_DIR}/* ]

    fi # if [ -d ${LOG_DIR} ]

    return ${RVAL}

}

logger_showVar ()
{

    declare LOG_PRIORITY
    declare VAR

    if [ "x$2" =  "x" ]
    then
        LOG_PRIORITY=${LOG_LEVEL:-0}
        eval VAR="$1=\$$1"
    else
        LOG_PRIORITY=$1
        eval VAR="$2=\$$2"
    fi

    logger_logit "${LOG_PRIORITY}" "${VAR}" 

}


# Must source log4bash in main execution block because
# it declares a couple of arrays that need to have global
# scope and putting them in a function would localize them.
if logger_init
then
    source ${LOGGER_LIB_DIR}/log4bash.sh 
    logger_logQ "utils_fileExecutable"
    #logger_logit "${L4B_DEBUG}" "Rotating logs."
    #logger_rotateLogs
    logger_logit "${L4B_DEBUG}" "Initialization of logger is complete."
    if [ "${LOGGER_LOG_LEVEL:-${LOGGER_DEFAULT_LOG_LEVEL}}" -ge 0 ]
    then
        logger_showVars
    fi
else
    echo "logger can't initialize."        
fi
