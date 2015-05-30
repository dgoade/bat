#!/bin/bash

batlib_showVars()
{

    logger_showVar BAT_VERSION
    logger_showVar BATLIB_ACTION
    logger_showVar BATLIB_REMOTE_HOSTNAME
    logger_showVar BATLIB_BASE_NAME
    logger_showVar BATLIB_BASE_DIR
    logger_showVar BATLIB_LIB_DIR
    logger_showVar BATLIB_WORK_DIR
    logger_showVar BATLIB_TEMP_DIR
    logger_showVar BATLIB_FALLBACK_DIR
    logger_showVar BATLIB_EMAIL_ON_NONCHANGE
    logger_showVar BATLIB_EMAIL_ON_ERROR
    logger_showVar BATLIB_EMAIL_MSG_FILE
    logger_showVar BATLIB_MAIL_SCRIPT
    logger_showVar BAT_MODULE_VERSION
    logger_showVar BATLIB_PRECEDING_TASKS_MUST_SUCCEED
    logger_showVar BATLIB_TASK1_ACTION
    logger_showVar BATLIB_TASK1_RELOAD_COM
    logger_showVar BATLIB_EVENT_LOG_DIR
    logger_showVar BATLIB_EVENT_LOG_FILE

}

batlib_parseOpts()
{

    while getopts a:h:s:v: option ${BAT_OPTS}
    do
        case ${option} in
            a) BATLIB_ACTION="${OPTARG}"
            ;;
            h) BATLIB_REMOTE_HOSTNAME="${OPTARG}"
            ;;
            s) BATLIB_MODULE_NAME="${OPTARG}"
            ;;
            v) LOGGER_LOG_LEVEL="${OPTARG}"
            ;;
            *) 
            ;;
        esac
    done    
    shift $(($OPTIND - 1))

}

batlib_setGlobals()
{

    declare rval=0
    declare d # short for "default"

    batlib_parseOpts ${BAT_OPS}

    if [ "x${BATLIB_REMOTE_HOSTNAME}" = "x" ]
    then
        : 
    else
        if batlib_VerifyMode
        then 

            if [ ${BATLIB_REMOTE_HOSTNAME} = $(hostname) ]
            then

                msg="BATLIB_REMOTE_HOSTNAME was specifed but it is" 
                msg="${msg} the current host so this argument will" 
                msg="${msg} be ignored." 
                logger_logit warn "${msg}"

                : # unset this arg -- everything is local
                unset BATLIB_REMOTE_HOSTNAME

            else

                msg="BATLIB_REMOTE_HOSTNAME was specified." 
                msg="${msg} A remote transfer of source files"
                msg="${msg} will be attempted."
                logger_logit info "${msg}"

                # we'll be pulling the source files from
                # remote hosts and transforming them here
                # for verification purposes only.

            fi 
        else
            : # not supporting remote engagements yet 
        fi
    fi

    if [ -n ${BATLIB_MODULE_NAME} ]
    then    
        :
    else
      # To allow for a single command line paramters
      # without having to specify the -s as an option
      BATLIB_MODULE_NAME="${1}"
    fi

  # used for transformation
  BATLIB_XSLTPROC=${BATLIB_XSLTPROC:-/usr/bin/xsltproc}

  # used for validation after the transformation
  d="/usr/bin/xmllint"
  BATLIB_XMLLINT=${BATLIB_XMLLINT:-${d}}

  # comments-out the DTD and "hides" the entity references
  d="${BATLIB_LIB_DIR}/hideEntities.pl"
  BATLIB_HIDE_ENTITIES_SCRIPT=${BATLIB_HIDE_ENTITIES_SCRIPT:-${d}}

  # uncommments the DTD and restores the entity references
  d="${BATLIB_LIB_DIR}/restoreEntities.pl"
  BATLIB_RESTORE_ENTITIES_SCRIPT=${BATLIB_RESTORE_ENTITIES_SCRIPT:-${d}}

  # for sending emails only when either a change 
  # has occurred or some error ocurred while
  # attempting a change.
  # when BATLIB_EMAIL_ON_NONCHANGE is false
  BATLIB_CHANGE_OCCURRED="false"
  BATLIB_ERROR_OCCURRED="false"
  BATLIB_VERIFY_FAILED="false"

    return ${rval}

}

batlib_init()
{

    declare -i rval=1

    batlib_setGlobals
    rval=$?

    if [ ${rval} -eq 0 ]
    then

        if [ ${rval} -eq 0 ]
        then
            utils_fileExecutable "${BATLIB_MAIL_SCRIPT}"
            rval=$?
            logger_logQ utils_fileExecutable
        fi

        # Rotate old and prepare new working directories
        if [ ${rval} -eq 0 ]
        then
            utils_rotate "${BATLIB_TEMP_DIR}" 5
            rval=$?
            logger_logQ utils_rotate
        fi

        if [ ${rval} -eq 0 ]
        then
            utils_exec "mkdir -p \"${BATLIB_TEMP_DIR}\""
            rval=$?
            logger_logQ utils_exec
        fi

        if [ ${rval} -eq 0 ]
        then
            utils_dirReady "${BATLIB_EVENT_LOG_DIR}"
            rval=$?
            logger_logQ utils_dirReady
        fi

    fi

    return ${rval}

}

batlib_loadModules()
{

    declare -i rval=0
    declare -a modules
    declare -i numModules
    declare -i stop
    declare -i ndx 
    declare msg
    declare msgLevel

    if [ ${rval} -eq 0 ]
    then
        utils_dirReady "${BATLIB_MODULES_DIR}" 
        rval=$?
        logger_logQ utils_dirReady
    fi

    if [ ${rval} -eq 0 ]
    then

        if [ -n "${BATLIB_MODULE_NAME}" ]
        then
            utils_dirReady "${BATLIB_MODULE_NAME}" 
            rval=$?
            logger_logQ utils_dirReady
            if [ ${rval} -eq 0 ]
            then
                # Assume not really running from a package
                # but in test mode so set the package name
                # to the module name. 
                BATLIB_MODULE_PACKAGE_NAME=$(basename ${BATLIB_MODULE_NAME})
                modules="${BATLIB_MODULE_NAME}"
                numModules=1
            else
                msg="Can't find module: ${BATLIB_MODULES_DIR}"
                logger_logit error "${msg} "
            fi
        else
            modules=($(ls -d ${BATLIB_MODULES_DIR}/*))
            numModules=${#modules[*]}
            msg="Number of dirs beneath ${BATLIB_MODULES_DIR}:"
            msg="${msg} ${numModules}"
            logger_logit debug "${msg}"
   
            if [ "${numModules}" -le 0 ]
            then
                msg="No module dirs found beneath ${BATLIB_MODULES_DIR}."
                logger_logit info "${msg}"
                rval=1
                BATLIB_VERIFY_FAILED="true"
            else
                if [ "${numModules}" -gt 1 ]
                then
                    msg=""
                    msg="${msg}Expected only 1 dir beneath"
                    msg="${msg} ${BATLIB_MODULES_DIR}"
                    msg="${msg} but found ${numModules}."
                    msg="${msg} Don't know which one to load."
                    logger_logit error "${msg}"
                    rval=1
                fi # [ "${numModules}" -gt 1 ]
            fi # [ "${numModules}" -lt 0 ]
        fi # [ -n "${BATLIB_MODULE_NAME}" ]
    fi

    if [ ${rval} -eq 0 ]
    then
        logger_logit debug "Looking for modules-specific bat.conf files."
        stop=$(expr ${numModules} - 1)
        for ndx in $( seq 0 ${stop} )
        do
            logger_logit debug "Checking modules#${ndx}: ${modules[${ndx}]}"
            
            utils_fileReadable "${modules[${ndx}]}/bat.conf" 
            rval=$?
            logger_logQ utils_fileReadable

            if [ ${rval} -eq 0 ]
            then
                msg="Found bat.conf file in ${modules[${ndx}]}, sourcing it."
                logger_logit debug "${msg}"
                BATLIB_MODULE_DIR="${modules[${ndx}]}"
                utils_includeSource "${BATLIB_MODULE_DIR}/bat.conf"
                rval=$?
                logger_logQ utils_includeSource
            else
                logger_logit error "No bat.conf file in ${modules[${ndx}]}"
            fi

            if [ ${rval} -eq 0 ]
            then
                logger_logit debug "Reinitializing for any overrides."
                if batlib_init
                then
                    msg="Reinitialization of batlib is complete."
                    logger_logit debug "${msg}"

                    # Now, reset module name after the reintitalization 
                    BATLIB_MODULE_NAME=$(basename ${BATLIB_MODULE_DIR})

                    if [ "${LOGGER_LOG_LEVEL:-${LOGGER_DEFAULT_LOG_LEVEL}}" -ge 0 ]
                    then
                        logger_showVars
                        batlib_showVars
                    fi

                    if utils_versionSupported "${BAT_VERSION}" "${BAT_MODULE_VERSION}"
                    then
                        msgLevel="debug"
                        msg="Module ${modules[${ndx}]}, version" 
                        msg="${msg} ${BAT_MODULE_VERSION} is supported"
                        msg="${msg} by BAT version ${BAT_VERSION}"
                        logger_logit ${msgLevel} "${msg}"
                        rval=0
                    else
                        msgLevel="fatal"
                        msg="Module ${modules[${ndx}]}, version" 
                        msg="${msg} ${BAT_MODULE_VERSION} is not supported"
                        msg="${msg} by BAT version ${BAT_VERSION}." 
                        msg="${msg} Not executing this module." 
                        rval=1

                        logger_logit ${msgLevel} "${msg}"

                        # log this failure to the email queue 
                        utils_qLogMsg ${msgLevel} "${msg}" "${LINENO}" "${FUNCNAME}"
                        batlib_logResults

                    fi

                else
                    rval=1
                fi 

            fi 
        done
    else
        logger_logit info "No modules found. Nothing to do."
    fi

    return ${rval}

}

batlib_cleanup ()
{

    declare -i rval=0

    return $rval
}

batlib_copyFile()
{

    declare -i rval=0

    declare src_file="${1}"
    declare dest_dir="${2}"
    declare com

    if [ ${rval} -eq 0 ]
    then
        utils_fileReadable "${src_file}"
        rval=$?
        logger_logQ utils_fileReadable
    fi

    if [ ${rval} -eq 0 ]
    then
        utils_dirReady "${dest_dir}" 
        rval=$?
        logger_logQ utils_dirReady
    fi

    if [ ${rval} -eq 0 ]
    then

        com="cp -fpr ${src_file} ${dest_dir}"
        utils_exec "${com}"
        rval=$?
        logger_logQ utils_exec

        if [ ${rval} -eq 0 ]
        then
            msg="Successfully copied ${src_file} to ${dest_dir}" 
            #logger_logit info "${msg}" 
        else
            msg="Failed to copy ${src_file} to ${dest_dir}"
            #logger_logit error "${msg}"
        fi
    fi

    return ${rval}

}

batlib_diff()
{

    declare rval=0
    declare left_file="${1}"
    declare right_file="${2}"
    declare com="${BATLIB_DIFF_COM}"
    declare msg

    declare diff_file=$(utils_workFileNameDifferentExt "${right_file}" \
        "diff" "${BATLIB_TEMP_DIR}")

    BATLIB_DIFF_FILE="${diff_file}"

    if [ -z $"{com}" ]
    then
        rval=1
        logger_logit error "No diff command defined for BATLIB_DIFF_COM" 
    fi
        
    if [ ${rval} -eq 0 ]
    then
        utils_fileReadable "${left_file}"
        rval=$?
        logger_logQ utils_fileReadable
    fi

    if [ ${rval} -eq 0 ]
    then
        utils_fileReadable "${right_file}"
        rval=$?
        logger_logQ utils_fileReadable
    fi

    if [ ${rval} -eq 0 ]
    then
        com="${com} ${left_file} ${right_file} > ${diff_file}"
        utils_exec "${com}"
        rval=$?
        if [ $rval -eq 1 ]
        then 
            # we will discard the logging messages here
            # because utils_exec always treats non-zero
            # as an error and in this case, '1' simply
            # means there is a difference
            utils_flushLogQ utils_exec
            BATLIB_DIFF_FILE="${diff_file}"
        else
            logger_logQ utils_exec
        fi
    fi

    return ${rval}

}

batlib_pullFileFromHost()
{

    declare -i rval=0
    declare srcPath=$1
    declare destPath=$2
    declare scpOpts="-o 'StrictHostKeyChecking=no'";
    declare scpCom
    declare msg
    declare msgLevel

    if [ -z ${srcPath} ]
    then
        msgLevel="error"
        msg="srcPath is null"
        rval=1
    fi
    
    if [ ${rval} -eq 0 ]
    then
        if [ -z ${destPath} ]
        then
            msgLevel="error"
            msg="destPath is null"
            rval=1
        fi
    fi
    
    if [ ${rval} -eq 0 ]
    then

        scpCom="scp ${scpOpts} ${srcPath} ${destPath}"

        utils_exec "${scpCom}"
        rval=$?
        logger_logQ utils_exec

        if [ ${rval} -eq 0 ]
        then
            msgLevel="info"
            msg="Successfully scp'd ${srcPath} to ${destPath}" 
        else
            msgLevel="error"
            msg="Failed to scp file"
        fi

    fi

    logger_logit ${msgLevel} "${msg}"

    return ${rval}
}

batlib_VerifyMode()
{

    declare -i rval=1

    if [ "${BATLIB_ACTION}" = "verify" ]
    then
        rval=0
    fi

    return ${rval}

}

batlib_runsed()
{

    declare -i rval=0

    declare src_file="${1}"
    declare sed_script="${2}"

    # will be used for diffing and fallback
    declare orig_src_file

    declare msg
    declare msgLevel

    utils_fileReadable "${src_file}"
    rval=$?
    if [ ${rval} -ne 0 ]  
    then
        # q-up the error for the email
        utils_qMsgsFrom utils_fileReadable "false"
    fi 
    logger_logQ utils_fileReadable 
   
    if [ ${rval} -eq 0 ]  
    then
        utils_fileReadable "${sed_script}"
        rval=$?
        if [ ${rval} -ne 0 ]  
        then
            # q-up the error for the email
            utils_qMsgsFrom utils_fileReadable "false"
        fi
        logger_logQ utils_fileReadable 
    fi
   
    if batlib_VerifyMode
    then
        : # no need to make a fallback copy in verify mode
    else

        # Make a fallback copy
        if [ ${rval} -eq 0 ]
        then

            batlib_copyFile "${src_file}" "${BATLIB_FALLBACK_DIR}"
            rval=$?
            if [ ${rval} -eq 0 ]
            then
                msgLevel="info"
                msg="Fallback copy made of ${src_file}."
                logger_logit ${msgLevel} "${msg}"
                orig_src_file="${BATLIB_FALLBACK_DIR}/$(basename ${src_file})"
            else
                msgLevel="error"
                msg="Failed to make fallback copy of ${src_file}."
                logger_logit ${msgLevel} "${msg}"
            fi
        fi
    fi

    if [ ${rval} -eq 0 ]
    then

        msgLevel="info"
        msg="Attempting sed edits to ${src_file}."
        logger_logit ${msgLevel} "${msg}"

        # Execute the sed script
        utils_runsed "${sed_script}" "${src_file}" \
            "${src_file}" 

        rval=$?
        utils_qMsgsFrom utils_execsed "false"
        logger_logQ utils_execsed 

        if [ ${rval} -eq 0 ]
        then

            msgLevel="info" 
            msg="sed edits successful ${src_file}."
            logger_logit ${msgLevel} "${msg}"

            msgLevel="debug"
            msg="Diffing original ${orig_src_file} and ${src_file}"
            logger_logit ${msgLevel} "${msg}"

            batlib_diff "${orig_src_file}" \
                "${src_file}"
            rval=$?

            if batlib_VerifyMode
            then
                # In verify mode, you're asserting that there 
                # should be no differences between the baseline
                # and the transformation 
                # so a non-zero return value from the diff is  
                # a verification failure. Let rval remain 
                # non-zero to indicate this as overall failure.
                msgLevel="info"
                msg="Verification of ${src_file} failed."
                logger_logit ${msgLevel} "${msg}"
            else    
                # In normal engage mode, when you're expecting
                # to change something, a '1' return value from 
                # the diff good because that means there is a 
                # difference between the baseline
                # and the transformation. Set rval to zero 
                # to indicate overall success.
                if [ ${rval} -eq 1 ]
                then
                    msgLevel="info"
                    msg="sed edits successful and diff"
                    msg="${msg} file generated."
                    logger_logit ${msgLevel} "${msg}"

                    # Add the diff file to email attachments array
                    BATLIB_EMAIL_ATTACHMENTS=("${BATLIB_EMAIL_ATTACHMENTS[@]}"\
                        "${BATLIB_DIFF_FILE}")

                    # now, set function return value to 0 for success
                    rval=0

                else
                    msgLevel="warn"
                    msg="sed edits completed successfully"
                    msg="${msg} but failed to generate a diff file to"
                    msg="${msg} include in the email notification."
                    logger_logit ${msgLevel} "${msg}"
                fi 
            fi # batlib_VerifyMode

        else

            if [ ${rval} -eq 2 ]
            then
                if batlib_VerifyMode
                then
                    msg="${msg} Verification of ${src_file} successful." 
                    logger_logit ${msgLevel} "${msg}"
                    rval=0
                else
                    msgLevel="error"
                    msg="${src_file} was not changed by sed script."
                    logger_logit ${msgLevel} "${msg}"
                fi
            else
                msgLevel="error"
                msg="utils_execsed failed: ${sed_script}."
                logger_logit ${msgLevel} "${msg}"
            fi
        fi
    fi

    # Here is where you log the sha1sum of each src_file in the module
    batlib_logTaskEvent "${BATLIB_MODULE_NAME}"\
        "${BATLIB_ACTION}"\
        "batlib_runsed"\
        "${src_file}"\
        "${rval}"\
        "${BATLIB_EVENT_LOG_FILE}"

    # Queue-up the outcome message for emailing  
    # after all tasks have been processed
    utils_qLogMsg ${msgLevel} "${msg}" "${LINENO}" "${FUNCNAME}"

    return $rval

}


batlib_libdir ()
{

    declare rval
    declare this_dir="${1}"
    declare BASE_NAME
    declare BASE_DIR

    if [ "x${this_dir}" = "x" ]
    then
        # Is BAT_PATH set?
        if [ "x${BAT_PATH}" = "x" ]
        then
            :
        else
            # Use it
            rval=${BAT_PATH}/lib
        fi 
    else
        if [ -d "${this_dir}" ]
        then
            rval="${this_dir}"
        fi
    fi

    if [ "x${rval}" = "x" ]
    then
        BASE_NAME=$(basename $0)
        BASE_DIR=$( cd $(dirname ${BASE_NAME}) ; pwd -P )

        # Is there a lib subdirectory?
        if [ -d ${BASE_DIR}/lib ]
        then
            # use it
            rval=${BASE_DIR}/lib
        else
            # otherwise, default to the current dir
            rval=${BASE_DIR}
        fi
    fi

    echo ${rval}

}

batlib_executeTasks()
{

    declare -i rval
    declare conf_setting
    declare conf_value
    declare -i task_num=1
    declare continue
    declare task_type
    declare tasks_must_succeed="${BATLIB_PRECEDING_TASKS_MUST_SUCCEED:-true}"
    declare execs_must_succeed="${BATLIB_PRECEDING_EXECS_MUST_SUCCEED:-true}"
    declare msg
    declare reloadCom

    logger_logit debug "batlib_executeTasks begins"

    continue="true" # prime the loop
    while utils_true "${continue}"
    do

        continue="false"
        conf_setting="BATLIB_TASK${task_num}_ACTION" 
        #logger_logit debug "Looking for ${conf_setting}"
        #conf_value=$(eval echo $(eval echo \${${conf_setting}}))
        #conf_value=$(eval echo \${${conf_setting}})
        conf_value=${!conf_setting}

        if [ -n "${conf_value}" ]
        then

            logger_logit debug "Value for ${conf_setting} is '${conf_value}'."

            # queue-up the task # for emailing
            msg="----------- ${conf_setting} -------------"
            utils_qLogMsg info "${msg}" "${LINENO}" "${FUNCNAME}"
            msg="${conf_value}"
            utils_qLogMsg info "${msg}" "${LINENO}" "${FUNCNAME}"

            # if you even need a way to parse the task into it's
            # space-delimitted components, this will do the trick.
            # They will be parsed into an array.
            #unset taskArray
            #declare -a taskArray=(${conf_value})
            #logger_logit debug "taskArray[1]=${taskArray[1]}"

            continue="true"
            eval "${conf_value}"
            rval=$?

            if batlib_VerifyMode
            then
                if [ ${rval} -eq 0 ]
                then
                    : # successful verification
                    # but don't try to reload anything because 
                    # nothing was changed in verify mode
                else
                    BATLIB_VERIFY_FAILED="true"
                    msg="Last verification failed."
                    logger_logit debug "${msg}" 
                    #continue="false"
                fi
            else

                if [ ${rval} -eq 0 ]
                then
                            
                    batlib_triggerAppReload "${task_num}"
                    rval=$?

                    # log what you have now so that
                    # if the fallback has to run, it
                    # won't queue-up _triggerAppReload's 
                    # logged messages as it's own and obscure 
                    # the logged function name 
                    batlib_logResults

                    if [ ${rval} -eq 0 ]
                    then
                        # success -- at least one change has been made
                        BATLIB_CHANGE_OCCURRED="true"
                    else

                        # Something happened when trying
                        # to trigger the reload. This is
                        # an error condition.
                        BATLIB_ERROR_OCCURRED="true"

                        batlib_fallback ${conf_value}
                        rval=$?

                        if utils_true "${tasks_must_succeed}" 
                        then
                            msg="Halting now."
                            logger_logit info "${msg}" 
                            continue="false"
                        fi
                    fi
                else

                    if [ ${rval} -eq 2 ]
                    then
                        # It was a no-op condition when
                        # the module ran and this should
                        # not be considered an error.
                        :
                    else 
                        BATLIB_ERROR_OCCURRED="true"
                    fi

                    if utils_true "${tasks_must_succeed}" 
                    then
                        logger_logit debug  "Last task failed -- halting now."
                        continue="false"
                    fi
                fi

            fi # batlib_VerifyMode

        else
            :
            #logger_logit debug "There is no value for ${conf_setting}."
        fi

        if utils_true ${continue}
        then
            conf_setting="BATLIB_TASK${task_num}_EXEC" 
            #logger_logit debug "Looking for ${conf_setting}"
            #conf_value=$(eval echo "\${${conf_setting}}")
            conf_value=${!conf_setting}

            if [ -n "${conf_value}" ]
            then

                logger_logit debug "Value for ${conf_setting} is '${conf_value}'."
                continue="true"
                eval ${conf_value} 
                
                rval=$?

                if utils_true "${tasks_must_succeed}" 
                then
                    if [ ${rval} -eq 0 ]
                    then
                        :
                        #logger_logit debug  "Last task was successful."
                    else
                        logger_logit debug  "Last task failed -- halting now."
                        continue="false"
                    fi
                fi

            else
                :
                #logger_logit debug "There is no value for ${conf_setting}."
            fi
        fi

        batlib_logResults
        task_num=$(expr ${task_num} + 1) 

    done

    return ${rval}

}

batlib_triggerAppReload()
{
 
    declare -i rval=0

    declare -i taskNum="${1}"
    declare reloadSetting

    declare reloadCom="${BATLIB_RELOAD_COM}"
    declare stdout="${BATLIB_TEMP_DIR}/batlib_triggerAppReload.stdout"
    declare stderr="${BATLIB_TEMP_DIR}/batlib_triggerAppReload.stderr"
    declare grepCom
    declare successMsg
    declare msgLevel 
    declare msg

    reloadSetting="BATLIB_TASK${task_num}_RELOAD_COM" 
    successMsg="BATLIB_TASK${task_num}_RELOAD_SUCCESS_MESSAGE"

    msgLevel="debug" 
    msg="Looking for reload setting: ${reloadSetting}"
    logger_logit ${msgLevel} "${msg}"

    reloadCom="${!reloadSetting}"

    if [ -z "${reloadCom}" ]
    then
        msgLevel="warn"
        msg="No value for ${reloadSetting} -- cannot trigger a reload."
        logger_logit ${msgLevel} "${msg}"

        # Allow for a change that doesn't require a reload
        rval=0

    else

        logger_logit info "Now reloading settings."

        if [ ${rval} -eq 0 ]
        then
            reloadCom="${reloadCom} 1> ${stdout}"
            utils_exec "${reloadCom}" "${stderr}"
            rval=$?
            logger_logQ utils_exec
        fi

        if [ ${rval} -eq 0 ]
        then
            logger_logit debug "Succesfully executed reload command."
        else
            logger_logit error "Failed to execute reload command."
        fi

        msgLevel="debug" 
        msg="Looking for success message setting: ${successMsg}"
        logger_logit ${msgLevel} "${msg}"

        #successMsg=$(eval echo \${${successMsg}})
        successMsg=${!successMsg}

        if [ "x${successMsg}" = "x" ]
        then
            msgLevel="debug" 
            msg="No success message to grep for so success will be"
            msg="${msg} determined by the reload command exit code alone."
            logger_logit ${msgLevel} "${msg}"
        else

            # Now, look for stdout and grep it for successful reload 
            if [ ${rval} -eq 0 ]
            then
                utils_fileReadable "${stdout}"
                rval=$?
                logger_logQ utils_fileReadable
            fi

            if [ ${rval} -eq 0 ]
            then
                # Can't use utils_exec here because it might
                # use utils_qLogMsg and that function cannot
                # handle both embedded single quotes and double
                # quotes. So we'll just use logger_logit and
                # execute the grep command right here -- at 
                # least until the utils log queueing functions
                # can be re-written using bash 3 associative arrays.
                logger_logit "debug" "Executing command: grep -ci \"${successMsg}\" ${stdout}"  
                grep -ci "${successMsg}" ${stdout}
                rval=$?
            fi
        fi # [ "x${successMsg}" = "x" ]

        if [ ${rval} -eq 0 ]
        then
            msgLevel="info"
            msg="Settings successfully reloaded." 
            logger_logit ${msgLevel} "${msg}"
        else
            msgLevel="error"
            msg="Unable to confirm if settings were reloaded."
            logger_logit ${msgLevel} "${msg}"
        fi

    fi # [ -z "${reloadCom}" ]

    utils_qLogMsg ${msgLevel} "${msg}" "${LINENO}" "${FUNCNAME}"

    return ${rval}

}

batlib_fallback()
{

    declare -i rval
    declare src_file="${BATLIB_FALLBACK_DIR}/$(basename ${2})"
    declare src_dir="$(dirname ${2})"
    declare msgLevel
    declare msg

    msgLevel="info"
    msg="Attempting to restore from fallback copy."
    logger_logit ${msgLevel} "${msg}"

    batlib_copyFile "${src_file}" "${src_dir}"
    rval=$?
    if [ ${rval} -eq 0 ]
    then
        logger_logit info "Restored fallback copy of ${2}."
        batlib_triggerAppReload
        rval=$?

        # so that you can properly identify
        # this second call of _triggerAppReload
        # as coming from the fallback and not the 
        # _executeTasks 
        utils_qMsgsFrom batlib_triggerAppReload 
        if [ ${rval} -eq 0 ]
        then
            msgLevel="info"
            logger_logit ${msgLevel} "Fallback completed successfully."
        else
            msgLevel="warn"
            msg=""
            msg="${msg}System is in unknown state. Fallback copy"
            msg="${msg} was restored but unable to determine if" 
            msg="${msg} the application reloaded it." 
            logger_logit ${msgLevel} "${msg}"
        fi

        # Here is where you log the sha1sum of each src_file in the module
        batlib_logTaskEvent "${BATLIB_MODULE_NAME}"\
            "${BATLIB_ACTION}"\
            "batlib_fallback"\
            "${2}"\
            "${rval}"\
            "${BATLIB_EVENT_LOG_FILE}"

    else
        msgLevel="critical"
        msg="Failed to restore fallback copy of ${2}."
        logger_logit ${msgLevel} "${msg}"
    fi

    utils_qLogMsg ${msgLevel} "${msg}" "${LINENO}" "${FUNCNAME}"

    return ${rval}

}


batlib_getResults()
{

    declare -i rval=1
    declare msg
    declare msgLevel="debug"
    declare -i overallResult=0

    if utils_true "${BATLIB_ERROR_OCCURRED}"
    then
        overallResult=1
        if utils_true "${BATLIB_EMAIL_ON_ERROR}"
        then
            msg="Error ocurred and BATLIB_EMAIL_ON_ERROR" 
            msg="${msg} is true -- sending email."
            rval=0
        else
            msg="Error ocurred but BATLIB_EMAIL_ON_ERROR" 
            msg="${msg} is false so not sending email."
        fi
    else
        if batlib_VerifyMode
        then
            if utils_true "${BATLIB_VERIFY_FAILED}"
            then
                overallResult=1
                if utils_true "${BATLIB_EMAIL_ON_VERIFY_FAILURE}"
                then
                    msg="Verify failed and BATLIB_EMAIL_ON_VERIFY_FAILURE"
                    msg="${msg} is true so sending email."
                    rval=0
                else
                    msg="Verify failed but BATLIB_EMAIL_ON_VERIFY_FAILURE"
                    msg="${msg} is false so not sending email."
                    rval=1
                fi
            else
                msg="Verify succeeded"
                overallResult=0
            fi
        else
            if utils_true "${BATLIB_CHANGE_OCCURRED}"
            then
                msg="Change occurred -- sending email."
                rval=0
            else
                overallResult=2
                if utils_true "${BATLIB_EMAIL_ON_NONCHANGE}"
                then
                    msg="No change occurred but sending email anyway because"
                    msg="${msg} BATLIB_EMAIL_ON_NONCHANGE is true."
                    rval=0
                else
                    msg="No change occurred and BATLIB_EMAIL_ON_NONCHANGE"
                    msg="${msg} is false so not sending email."
                fi
            fi
        fi
    fi
    logger_logit ${msgLevel} "${msg}"

    #msgLevel="debug"
    #msg="BATLIB_EMAIL_ATTACHMENTS=${BATLIB_EMAIL_ATTACHMENTS[@]}"
    #logger_logit ${msgLevel} "${msg}"

    if [ ${rval} -eq 0 ]
    then
        batlib_emailResultWithAttachments \
            "${overallResult}" \
            "${BATLIB_TEMP_DIR}/${BATLIB_EMAIL_MSG_FILE}" \
            "$(logger_getLogPath) ${BATLIB_EMAIL_ATTACHMENTS[*]}" 
        rval=$?
    fi

    return ${overallResult}

}

batlib_logResults()
{

    declare -i rval

    declare curLogDir=$(logger_getLogDir)
    declare curLogFile=$(logger_getLogFile)
    declare emailMsgFile="${BATLIB_EMAIL_MSG_FILE}"
    declare emailMsgFormat="${BATLIB_EMAIL_MSG_FORMAT}"

    logger_setLogDir "${BATLIB_TEMP_DIR}" 
    rval=$?

    if [ ${rval} -eq 0 ]
    then
        logger_setLogFile "${emailMsgFile}" 
        rval=$?
    else
        :
    fi

    if [ ${rval} -eq 0 ]
    then
        logger_logQ batlib_loadModules
        logger_logQ batlib_executeTasks
        logger_logQ batlib_fallback
        logger_setLogDir "${curLogDir}"
        logger_setLogFile "${curLogFile}"
    else
        :
    fi


    return ${rval}

}

batlib_emailResultWithAttachments()
{

    declare -i rval=0

    declare mailScript="${BATLIB_MAIL_SCRIPT}"

    declare emailTo="${BATLIB_EMAIL_TO}"
    declare emailCc="${BATLIB_EMAIL_CC}"
    declare emailFrom="${BATLIB_EMAIL_FROM:-bat@$(hostname)}"
    declare overallResult="${1}"
    declare emailSubject="${BATLIB_EMAIL_SUBJECT:-Module Execution Result}"
    declare emailBody="${2}"
    declare emailFooter="${BATLIB_EMAIL_FOOTER}"
    declare emailAttachments="${3}"
    declare com
    declare msg

    case ${overallResult} in
        0) emailSubject="${emailSubject}: SUCCESS"
        ;;
        1) emailSubject="${emailSubject}: FAIL"
        ;; 
        2) emailSubject="${emailSubject}: NO_OP"
        ;;
        *) emailSubject="${emailSubject}: UNKNOWN"
        ;;
    esac 

    com="${mailScript} \
        -from \"${emailFrom}\" \
        -to \"${emailTo}\" \
        -subject \"${emailSubject}\" \
        -cc \"${emailCc}\" \
        -body \"${emailBody}\" \
        -footer \"${emailFooter}\" \
        -attach \"${emailAttachments}\" \
        -verbose \"$(logger_globalLogLevelDesc)\""

    logger_logit debug "executing commmand=${com}"
    eval ${com}
    #utils_exec "${com}"
    #rval=$?
    #logger_logQ utils_exec

    if [ ${rval} -eq 0 ]
    then
        logger_logit debug "Email successfully sent"
    else
        logger_logit error "Failed to send email."
    fi

    return ${rval}

}

batlib_logTaskEvent ()
{

    declare rval=0
    declare msg
    declare msgType="MON"
    declare datetime
    declare millis
    declare nanos
    declare sha1Sum
    declare hostName=$(hostname)
    declare moduleName="${1:-unknown}"
    declare moduleAction="${2:-unknown}"
    declare eventType="${3:-0}"
    declare srcFile=${4:-unknown}
    declare result="${5:-0}"
    declare resultEventLog="${6:-/dev/null}"

    if utils_true ${BATLIB_LOG_TASK_EVENTS}
    then    
        nanos=$(date +%N)
        millis=${nanos:0:3}
        dateTime=$(date "+%Y-%m-%d %H:%M:%S.${millis}")

        sha1Sum=$(utils_sha1sum ${srcFile})
        rval=$?
        logger_logQ utils_sha1sum

        if [ ${rval} -eq 0 ]
        then
            msg="${moduleName}|${moduleAction}|${eventType}|${srcFile}|${sha1Sum}|${result}"

            utils_eLogit "${msgType}" \
                "${dateTime}" \
                "${hostName}" \
                "${msg}" \
                "${resultEventLog}"
            rval=$?
        fi
    fi

    return ${rval}

}

batlib_logResultEvent ()
{

    declare -i rval=0 
    declare msgType="MON"
    declare datetime
    declare millis
    declare nanos
    declare hostName=$(hostname)
    declare moduleName="${1:-unknown}"
    declare moduleAction="${2:-unknown}"
    declare eventType="${3:-0}"
    declare result="${4:-0}"
    declare resultEventLog="${5:-/dev/null}"

    if utils_true ${BATLIB_LOG_MODULE_RESULT_EVENT}
    then
        nanos=$(date +%N)
        millis=${nanos:0:3}
        dateTime=$(date "+%Y-%m-%d %H:%M:%S.${millis}")

        declare msg="${moduleName}|${moduleAction}|${eventType}|${result}"

        utils_eLogit "${msgType}" \
            "${dateTime}" \
            "${hostName}" \
            "${msg}" \
            "${resultEventLog}"
    fi

    return ${rval}

}

# Main Program 
BATLIB_ACTION=engage
BATLIB_BASE_NAME=$(basename $0)
BATLIB_BASE_DIR=$( cd $(dirname ${BATLIB_BASE_NAME}) ; pwd -P )
BATLIB_MODULE_PACKAGE_NAME=$(basename ${BATLIB_BASE_DIR})
BATLIB_LIB_DIR=$(batlib_libdir "${BATLIB_LIB_DIR}")
BATLIB_WORK_DIR=${BATLIB_BASE_DIR}/work
BATLIB_MODULES_DIR=${BATLIB_BASE_DIR}/modules
BATLIB_TEMP_DIR=${BATLIB_WORK_DIR}/temp
BATLIB_FALLBACK_DIR=${BATLIB_WORK_DIR}/fallback
BATLIB_EMAIL_MSG_FILE=email.msg
BATLIB_EVENT_LOG_DIR=/var/log/tomcat
BATLIB_EVENT_LOG_FILE=${BATLIB_EVENT_LOG_DIR}/batEvent.log

batlib_parseOpts

if [ -f ${BATLIB_LIB_DIR}/logger.sh ] 
then

    source ${BATLIB_LIB_DIR}/logger.sh
    #logger_rotateLogs
    CONF_FILE=$(utils_sameNameDifferentExt "conf")
    logger_logit debug "Sourcing ${CONF_FILE} file..."
    utils_includeSource "${CONF_FILE}"
    rval=$?
    logger_logQ utils_includeSource

    if [ $rval -eq 0 ]
    then
        logger_logit debug "Successfully sourced ${CONF_FILE} file..."
        if utils_true ${LOGGER_ROTATE} 
        then
            logger_rotateLogs
        fi

        logger_logit debug "Initialization of batlib is complete."
        logger_logit info "Bash Automation Tools v${BAT_VERSION}"
        if [ "${LOGGER_LOG_LEVEL:-${LOGGER_DEFAULT_LOG_LEVEL}}" -ge 0 ]
        then

            logger_showVars
            batlib_showVars
        fi


    else
        logger_logit error "Failed to source ${CONF_FILE} file..."
    fi
else
    echo "Unable to source logger.sh"
fi
