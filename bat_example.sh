#!/bin/bash
BAT_RVAL=1

batlib_libdir ()
{

    declare rval
    declare base_name
    declare base_dir

    base_name=$(basename $0)
    base_dir=$( cd $(dirname ${base_name}) ; pwd -P )

    # Is BAT_PATH set?
    if [ "x${BAT_PATH}" = "x" ]
    then
        # Is there a lib subdirectory?
        if [ -d ${base_dir}/lib ]
        then
            # use it
            rval=${base_dir}/lib
        else
            # otherwise, look in the current dir
            rval=${base_dir}
        fi
    else
        # Use it
        rval=${BAT_PATH}/lib
    fi

    echo ${rval}

}

# Main program
BATLIB_LIB_DIR=$(batlib_libdir)

if [ -f ${BATLIB_LIB_DIR}/batlib.sh ]
then
    source ${BATLIB_LIB_DIR}/batlib.sh

    if batlib_init "$@"
    then
        :

        logger_logit "debug" "batlib_init returned good exit status"
#        if batlib_loadTasks "$@"
#        then
#            batlib_executeTasks
#        fi
#
#        batlib_getResults
#        BAT_RVAL=$?

    else
        logger_logit "debug" "batlib_init did not return good exit status"
    fi
else
    echo "Unable to source batlib.sh"
fi

exit ${BAT_RVAL}
