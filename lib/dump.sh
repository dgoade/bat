#!/bin/bash


init ()
{

    declare -i rval=0
    declare logMsg

    # technique to get the fully-qualified directory this script is in 
    BIN_DIR=$( cd $(dirname $0) ; pwd -P )
    SETENV=${BIN_DIR}/setenv.sh

    OPTIND=1
    while getopts d:hl:m:o:t:v option
    do
        case ${option} in
            d|t) DUMP_TYPE="${OPTARG}"
            ;;
            h) rval=2
            ;;
            m) METHOD="${OPTARG}"
            ;;
            l) MY_LOG_ARG="${OPTARG}"
            ;;
            o) OUTPUT_FILE="${OPTARG}"
            ;;
            v) VERBOSE="-v"
            ;;
            *)
            ;;
        esac
    done
    shift $(($OPTIND - 1)) # this is why we must initialize OPTIND

    if [ -f ${SETENV} ]
    then
        . ${SETENV}
        if [ "${VERBOSE}" = "-v" ]
        then
            setenv_showVars
        fi
    else
        logMsg="No ${SETENV} found to source."
        rval=1
    fi

    if [ ${rval} -eq 0 ]
    then
        DUMP_ITERATIONS=3
        DUMP_INTERVAL=30

        # set / validate these
        JSTACK=jstack
        JMAP=/apps/stash/jdk1.7/bin/jmap
    fi

    return ${rval}

}

logIt ()
{

        logIt_MSG=$1
        logIt_BASENAME=`basename $0`
        logIt_LOG_PREFIX="<`date`> $0 - "

        if [ $# -ge 2 ]
        then
                logIt_LOG=$2
        else
                logIt_LOG=${MY_LOG}
        fi

        if [ "x$logIt_LOG" =  "x" ]
        then
                echo "${logIt_LOG_PREFIX}${logIt_MSG}"
        else
                echo "${logIt_LOG_PREFIX}${logIt_MSG}" | tee -a ${logIt_LOG}
        fi

}

getPid ()
{

    declare rval
    declare appName=${1:-stash}

    rval=$(ps -f -u ${APP_OWNER} | grep -v perl | perl -slane \
        'if( m{^\w+\s+(\d+)\s.*-DappName=$appName.*} ){print $1}' \
        -- --appName=${appName})

    echo $rval

}


runThreadDump ()
{

    declare rval=0
    declare logMsg

    declare sabreApp=${1} 
    declare method=${2:-jstack}

	logIt "Running thread dump on ${1} using ${method} method." ${MY_LOG}
    PID=$(getPid ${1})

    if [ "x${PID}" = "x" ]
    then
        logIt "${1} is not running -- skipping this thread dump." ${MY_LOG}
        rval=1
    else
        logIt "PID for ${1} is ${PID}" ${MY_LOG}
        LOOP=1
        DONE=""
        while [ "x${DONE}" = "x" ]
        do
            case ${method} in 
            jstack)
                logMsg="Running thread dump ${LOOP} of ${DUMP_ITERATIONS}..."
                logIt "${logMsg}" ${MY_LOG}
                ${JSTACK} ${PID} | tee -a ${MY_LOG}
                ;;
            *)
                logMsg="Running thread dump ${LOOP} of ${DUMP_ITERATIONS}"
                logMsg="${logMsg} (output will be in ${1}'s stdout file)..." 
                logIt "${logMsg}" ${MY_LOG}
                kill -3 ${PID}
                ;;
            esac

            if [ "${LOOP}" -ge ${DUMP_ITERATIONS} ]
            then
                DONE="TRUE"
            else
                logMsg="Waiting ${DUMP_INTERVAL} seconds before"
                logMsg="${logMsg} running next thread dump..."
                logIt "${logMsg}" ${MY_LOG}
                sleep ${DUMP_INTERVAL}
            fi
            LOOP=$(expr ${LOOP} + 1)
        done

    fi

    return ${rval}

}

runHeapDump ()
{

    declare rval=0
    declare logMsg

    declare appName=${1} 
    declare method=${2:-jmap}

    declare outputFile=${OUTPUT_FILE:-${LOG_DIR:-.}/heap.bin}

	logIt "Running heap dump on ${1} using ${method} method." ${MY_LOG}
    PID=$(getPid ${1})

    if [ "x${PID}" = "x" ]
    then
        logIt "${1} is not running -- skipping this heap dump." ${MY_LOG}
        rval=1
    else
        logIt "PID for ${1} is ${PID}" ${MY_LOG}
        ${JMAP} -dump:format=b,file=${outputFile} ${PID}
    fi

    return ${rval}

}

showUsage ()
{

    msg="Usage: $0 [-t(ype) [thread|heap]"
    msg="${msg} [-l(og file) path/to/logfile.log]"
    msg="${msg} [-o(utput) path/to/heapDump.bin]"
    msg="${msg} [-m(ethod) [jstack|kill]]"
    msg="${msg} [-v(erbose) ]"

    echo "${msg}"

}

init ${*}
RVAL=$?

case ${RVAL} in
    0)
        MY_LOG=${MY_LOG_ARG:-${LOG_DIR:-.}/dump.log}
        case ${DUMP_TYPE} in
            heap) runHeapDump stash
            ;;
            *) runThreadDump stash ${METHOD} 
            ;;
        esac
    ;;
    1)
        echo "Failed to initialize." 
    ;;
    2)
        showUsage
    ;; 
esac
