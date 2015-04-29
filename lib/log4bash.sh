#============================================================
# Author: Philip Patterson (philip.patterson@gmail.com)
# Date: 2009-04-16
# Copyright (c) 2009, Philip Patterson
# License: GNU LGPL Version 2.1
#          http://www.opensource.net/licenses/lgpl-2.1.php
#
# To use this script, use the "." or "source" command to
# load this file into your shell script.
# e.g.) source /FULL/PATH/log4bash.sh
#============================================================

# this is the primary function that gets used by others
log4bash(){
   #validate the parameters
   if [ ${#} -lt 2 ] ;then
      echo "FATAL ERROR: you must pass at least 2 arguments to ${FUNCNAME}"
      return 1
   fi

   case ${1} in
   *[!0-9]*|"")
      echo "FATAL ERROR: 1st parm passed to ${FUNCNAME} must be NUMERIC"
      return 1
      ;;
   esac

   l4b_last_label=${#L4B_LABEL[@]}
   if [ ${l4b_last_label:-0} -gt 0 ] ;then
      (( l4b_last_label-=1 ))
   fi
   if [ ${1} -lt 0 -o ${1} -gt ${l4b_last_label:-0} ] ;then
      echo "FATAL ERROR: 1st parm passed to ${FUNCNAME} must be between 0 and ${l4b_last_label:-0}"
      return 1
   fi

   #write the message to the logfile, if appropriate
   if [ ${1} -ge ${L4B_DEBUGLVL:-"0"} ] ;then
      #prep the log message, timestamp string and log file name
      L4B_LOGTIME=`${L4B_DATE:-"date"} "${L4B_DATEFORMAT:-"+%Y-%m-%d %H:%M:%S.%N %Z"}"`
      L4B_MESSAGE=`echo "${L4B_LOGTIME}${L4B_DELIM:-"|"}${L4B_LABEL[${1}]:-"UNKNOWN"}${L4B_DELIM:-"|"}${3:-"0"}${L4B_DELIM:-"|"}${4:-"main"}${L4B_DELIM:-"|"}${2}"`
      L4B_LOGGER=${L4B_LOGFILE:-"${0}.`${L4B_DATE:-"date"} "+%Y%m%d"`.log"}

      if [[ ${L4B_VERBOSE:-"false"} == true ]] ;then
         echo "${L4B_MESSAGE}"|tee -a ${L4B_LOGGER}
      else
         echo "${L4B_MESSAGE}" >> ${L4B_LOGGER}
      fi
   fi
   return 0
} #log4bash

# set L4B_LABEL array, if it has not already been set
if [ ${#L4B_LABEL[@]} -eq 0 ] ;then
   declare -a L4B_LABEL=(DEBUG INFO WARN ERROR CRITICAL FATAL)
fi

# initialize the L4B_* variables
for LabelIndex in $(seq 0 $((${#L4B_LABEL[@]}-1))) ;do
   declare L4B_${L4B_LABEL[${LabelIndex}]}=${LabelIndex}
done

#EOF
