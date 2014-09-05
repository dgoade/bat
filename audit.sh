#!/bin/bash
UTILS_LOGIT_LOG_LEVEL=0

declare -A FILES

FILES[/path/to/file1]=''
FILES[/another/path/to/file2]=''
FILES[/tmp/thisfile]=''

baf_libdir ()
{

    declare -i rval=0

    BASE_NAME=$(basename $0)
    BASE_DIR=$( cd $(dirname ${BASE_NAME}) ; pwd -P )

    echo "BASE_NAME=${BASE_NAME}"
    echo "BASE_DIR=${BASE_DIR}"

    # Is there a lib subdirectory?
    if [ -d ${BASE_DIR}/lib ]
    then
        # use it
        BAF_LIB_DIR=${BASE_DIR}/lib
    else
        # otherwise, look in the current dir
        BAF_LIB_DIR=${BASE_DIR}
    fi

    return ${rval}

}

init()
{

    declare -i rval=0
    declare logMsg

    declare opts=$@

    baf_libdir
    rval=$? 

    if [ -f ${BAF_LIB_DIR}/utils.sh ]
    then
        source ${BAF_LIB_DIR}/utils.sh
    else
        echo "Unable to source utils.sh"
        rval=1
    fi

    if [ $rval -eq 0 ]
    then

        SSH_USER=jdoe
        SSH_KEY=~/.ssh/id_rsa
        SSH_HOST=host@domain.com

        HELP=0
        LOG_LEVEL=1
        NO_OP=0
        VERBOSE=0

        LOG_DIR=${BASE_DIR}/logs

        mkdir -p ${LOG_DIR}
        if utils_dirReady ${LOG_DIR} 
        then
            UTILS_LOGIT_LOG_FILE=${LOG_DIR}/audit.log

            if utils_fileWriteable ${UTILS_LOGIT_LOG_FILE} 
            then
                if utils_rotate ${UTILS_LOGIT_LOG_FILE}  10 "" 
                then
                    utils_logit 0 "Log was rotated" 
                else
                    utils_logit 4 "Failed to rotate log"
                    rval=1
                fi
            fi
        else
            utils_logit 4 "Unable to create log dir: ${LOG_DIR}" 
            rval=1
        fi

        if [ ${rval} -eq 0 ]
        then
            SNAPSHOT_FILE=${LOG_DIR}/audit-snapshot.log
        fi

        utils_logit 0 "Parsing opts: '${opts}'"

        OPTIND=1
        while getopts a:k:s:l:o:hnu:v option ${opts}
        do
            case ${option} in
                a) ACTION=${OPTARG}
                ;;
                k) SSH_KEY=${OPTARG}
                ;;
                s) SSH_HOST=${OPTARG}
                ;;
                u) SSH_USER=${OPTARG}
                ;;
                h) HELP=1
                ;;
                l) LOG_LEVEL=${OPTARG}
                ;;
                n) NO_OP=1
                ;;
                o) SNAPSHOT_FILE=${OPT_ARG}
                ;;
                v) VERBOSE=1
                ;;
                *) 
                ;;
            esac
            shift $(($OPTIND - 1)) 
        done    

        if [ ${VERBOSE} -eq 1 ]
        then
            logMsg="Options parsed:"
            utils_logit 0 "${logMsg}"
            utils_logit 0 "${logMsg}"
            utils_logit 0 "ACTION=${ACTION}"
            utils_logit 0 "SSH_HOST=${DEST_SERVER}"
            utils_logit 0 "SSH_USER=${SSH_USER}"
            utils_logit 0 "SSH_KEY=${SSH_KEY}"
            utils_logit 0 "SNAPSHOT_FILE=${SNAPSHOT_FILE}"
            utils_logit 0 "HELP=${HELP}"
            utils_logit 0 "LOG_LEVEL=${LOG_LEVEL}"
            utils_logit 0 "NO_OP=${NO_OP}"
            utils_logit 0 "VERBOSE=${VERBOSE}"
        fi

        if [ -n ${SSH_HOST} ]
        then
            :
        else
            logMsg="SSH_HOST  is required"
            utils_logit 4 "${logMsg}"
            rval=1
        fi

    fi

    return ${rval}

}
audit_file () 
{

    declare -i rval=0
	declare file_to_audit=${1}	
    declare ret_string=${2}

	echo "file_to_audit=${file_to_audit}"

	file_ls=$(ssh -i ${SSH_KEY} ${SSH_USER}@${SSH_HOST} "ls -l --time-style=+'%Y-%m-%d %H:%M:%S' ${file_to_audit}" 2>/dev/null)
	file_cksum=$(ssh -i ${SSH_KEY} ${SSH_USER}@${SSH_HOST} "cksum ${file_to_audit}" 2>/dev/null)

    file_info1=$(echo ${file_cksum} | perl -lane 'if(/^(\d+)\s.*/){print "$1"}') 
    file_info2=$(echo ${file_ls} | perl -lane 'if(/(\d+)\s(\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2})\s(.*)$/){print "$1|$2|$3"}') 

    file_info="${file_info1}|${file_info2}"

    utils_logit 0 "file:  ${file_ls}"
    utils_logit 0 "cksum: ${file_cksum}"
    #utils_logit 0 "file_info: ${file_info}"

    eval "${ret_string}=\"${file_info}\""

    return ${rval}

}

audit_files ()
{

    declare -i rval=0
    declare file_name

	for file_name in "${!FILES[@]}"
	do
        audit_file ${file_name} file_info
        rval=$? 
        if [ ${rval} -eq 0 ]
        then
            utils_logit 0 "file_info: ${file_info}"
            FILES[${file_name}]=${file_info}
        fi
	done

    return ${rval}
}

report_files ()
{
    declare -i rval=0
    declare file_name

    if [ -f ${SNAPSHOT_FILE} ]
    then
        CONTROL_CKSUM=$(cksum ${SNAPSHOT_FILE} | awk '{print $1}')
        utils_logit 1 "Snapshot file exists, control cksum=${CONTROL_CKSUM}"
        if utils_rotate ${SNAPSHOT_FILE}  10 "" 
        then
            utils_logit 1 "Snapshot file was rotated" 
        else
            utils_logit 4 "Failed to rotate snapshot file"
            rval=1
        fi
    else
        utils_logit 1 "No pre-existing snapshot file."
    fi

    if [ ${rval} -eq 0 ]
    then 

        for file_name in "${!FILES[@]}"
        do
            echo ${FILES[${file_name}]} | tee -a ${SNAPSHOT_FILE}
        done

        if [ -f ${SNAPSHOT_FILE} ]
        then
            NEW_CKSUM=$(cksum ${SNAPSHOT_FILE} | awk '{print $1}')
            utils_logit 1 "New snapshot file exists, control cksum=${CONTROL_CKSUM}"
        else
            utils_logit 1 "No pre-existing snapshot file."
        fi

        if [ "${NEW_CKSUM}" = "${CONTROL_CKSUM}" ]
        then
            utils_logit 1 "No changes have been made to audited files."
        else
            utils_logit 1 "Changes have been made to audited files."
        fi
    fi

}


if init
then
    if audit_files
    then
        report_files
    fi
fi
