#!/bin/bash

init ()
{

	PORTS=$*
	BASENAME=`basename $0`
	AWK=/bin/awk
	DIRNAME=`dirname $0`
	APP_OWNER=appowner
    LOG_STORE=/apps/logs

    # make sure there's enough space for heap dumps
    DUMP_FILE_NAME_PREFIX="tomcat"
    DUMP_DIR=/tmp

	DUMP_ITERATIONS=3
	DUMP_INTERVAL=30

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
	rval=`ps -ef | egrep "^$1.*-Dapp=[A-Z]+_$2 " | egrep -v "egrep" | egrep -v $BASENAME | awk '{print \$2}'`
        echo $rval
}

getJmapBin ()
{
        rval=`ps -ef | grep $1 | grep $2 | grep java | grep -v grep | awk {'print $8'} | sed -e 's/\/bin\/java/\/bin\/jmap/'`
        echo $rval;
}

runheapDump ()
{
        logIt "Running heap dump on $1..." $MYLOG
        JMAP_BIN=`getJmapBin $APP_OWNER $1`
        PID=`getPid $APP_OWNER $1`
        if [ "x$PID" = "x" ]
        then
                logIt "$1 is not running -- skipping this thread dump." $MYLOG
        else
                $JMAP_BIN -dump:format=b,file=${DUMP_DIR}/${DUMP_FILE_NAME_PREFIX}-$1.`date +'%Y%m%d-%T'`.heap.hprof $PID
        fi

}

runThreadDump ()
{

	logIt "Running thread dump on $1..." $MYLOG
        PID=`getPid $APP_OWNER $1`

        if [ "x$PID" = "x" ]
        then
                logIt "$1 is not running -- skipping this thread dump." $MYLOG
        else

                logIt "PID for $1 is $PID" $MYLOG
                LOOP=1
                DONE=""
                while [ "x$DONE" = "x" ]
                do
                        logIt "Running thread dump $LOOP of $DUMP_ITERATIONS (output will be in $1's stdout file)..." $MYLOG
                        kill -3 $PID
                        if [ "$LOOP" -ge $DUMP_ITERATIONS ]
                        then
                                DONE="TRUE"
                        else
                                logIt "Waiting $DUMP_INTERVAL seconds before running next thread dump..." $MYLOG
                                sleep $DUMP_INTERVAL
                        fi
                        LOOP=`expr $LOOP + 1`
                done
                find $LOG_STORE/tomcat-$1 -name "catalina.*.out" -mmin -3 -exec cp '{}' /share/prod/tools/dumps/tomcat-$1.thread.`date +'%Y%m%d-%T'`.dump \;
        fi

}

init $*
for THIS_PORT in $PORTS
do
        runheapDump $THIS_PORT
	runThreadDump $THIS_PORT
done
