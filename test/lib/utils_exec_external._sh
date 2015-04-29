#!/bin/bash
RVAL=1
INPUT_FILE=${1}
echo "Input file=${INPUT_FILE}"
if [ -n "${INPUT_FILE}" ]
then
    if [ -f ${INPUT_FILE} ]
    then
        cat "${INPUT_FILE}"
        RVAL=$?
    fi
fi
exit ${RVAL}
