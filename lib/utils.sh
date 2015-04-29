#!/bin/bash
: <<='cut'

=head1 NAME

utils.sh - Low-level Bash Utility Functions

=head1 SYNOPSIS

    #!/bin/bash
    source $(dirname $0)./utils.sh
    # start using any of the functions

=head1 DESCRIPTION

B<utils.sh> is a self-contained Bash function library containing I<low-level> 
utility functions. By I<low-level>, I mean this library does not have any 
dependencies on other script libraries. This is intended to be the home for 
the most commonly-used functions by your script. All you should have to do is 
source this library into your script and all of the below functions should be 
available.

=head2 GLOBAL VARIABLES

I<Integers> representing log levels for messages, 0-5 respectively.

=over 4

=item I<UTILS_QLOG_DEBUG>

=item I<UTILS_QLOG_INFO>

=item I<UTILS_QLOG_WARN>

=item I<UTILS_QLOG_ERROR>

=item I<UTILS_QLOG_CRITICAL>

=item I<UTILS_QLOG_FATAL>

=back

=over 4

=item I<UTILS_QLOGMSG_QUEUES_ENABLED> - I<boolean> switch to disable all 
message queueing functionality, including functions that might even result
in a no-op because UTILS_LOGMSG_QUEUE_MESSAGES is not true.

=item I<UTILS_LOGMSG_QUEUE_MESSAGES> - I<boolean> switch to control 
whether or not to queue log messages. Does not completely disable 
all message queueing functions so some evals might still be executed 
that should result in a no-op even if this switch is false. 
L</UTILS_LOGMSG_QUEUE_MESSAGES> must also be true or this value
is ignored. 

=item I<UTILS_LOGIT_LOG_LEVEL> - I<Integer> for global log level for the 
native utils logging functions. A value from 0-5, with 0 being the most
verbose and 5 being the least.

=item I<UTILS_LOGIT_LOG_FILE> - I<String> for the log file name for the
native utils logging functions to use, if any. Defaults to /dev/null. 

=item I<UTILS_LOGIT_LOG_DATE_FORMAT> - I<String> The date format string. See
the man page for the date command for more.

=back

=over 4

=item I<UTILS_DEBUGME>

=back

Debugging command toggle switch -- see 
L<utils_debugme([I<commands...>])|/utils_debugme([commands...])> for more.

=cut

#=== GLOBAL VARIABLES ==================================================================
UTILS_QLOG_DEBUG="0"
UTILS_QLOG_INFO="1"
UTILS_QLOG_WARN="2"
UTILS_QLOG_ERROR="3"
UTILS_QLOG_CRITICAL="4"
UTILS_QLOG_FATAL="5"

UTILS_LOGMSG_QUEUE_MESSAGES="true"
UTILS_QLOGMSG_QUEUES_ENABLED="true"

UTILS_LOGMSG_QUEUE_MESSAGES="true"
UTILS_LOGIT_LOG_LEVEL=0
UTILS_LOGIT_LOG_FILE="/dev/null" 
UTILS_EXEC_NO_OP="false"
#UTILS_DEBUGME="true"
##======================================================================================

##---------------------------------
## Function definitions begin here
##---------------------------------
: <<='cut'

=head1 FUNCTIONS

B<utils.sh> provides the following functions: 

=cut

##== FUNCTION ==========================================================================
: <<='cut'

=head2 B<utils_callStack(I<[start]>)>

Debugging and logging tool. Creates a short string, suitable for logging
that represents the function call stack. Used by utils_logit for native
logging when log queueing is disabled (i.e. when 
UTILS_LOGMSG_QUEUE_MESSAGES is not true). 

B<ARGUMENTS:> 

I<start> - Where to start in the call stack trace. Defaults to 3 to
avoid including "utils_logMsg->utils_logit" in the trace because those two
functions will generally be included in every call when the trace is logged. 

B<RETURNS:> 

A string representing the call stack. For example: 
C<main->source->logger_rotateLogs->logger_set_L4B_settings->utils_dirReady>

B<GLOBALS USED:> 

None 

B<DEPENDENCIES:> 

None

B<NOTES:>

None

B<BUGS:>

None

B<SEE ALSO:> 

L</utils_trace_off()>, 
L</utils_stacktrace()>, 
L<utils_debugme([I<commands>...])|/utils_debugme([commands...])> 

=cut

##======================================================================================
utils_callStack()
{

    declare rval
    declare start=${1:-3}
    declare numFuncs
    declare funcNdx=${start}

    numFuncs=${#FUNCNAME[*]}

    rval="${FUNCNAME[${funcNdx}]}"

    start=$(expr ${start} + 1)

    for funcNdx in $( seq ${start} ${numFuncs} )
    do
        lineNdx=$(expr ${start}-1)
        if [ ${funcNdx} -eq ${numFuncs} ]
        then
            rval="${FUNCNAME[${funcNdx}]}${rval}" 
        else
            rval="${FUNCNAME[${funcNdx}]}->${rval}" 
        fi
    done 

    echo $rval 

}

##== FUNCTION ==========================================================================
: <<='cut'

=head2 B<utils_trace_on()>

Debugging tool. Toggle-on Bash x-trace with a special prompt that shows
the script name, function name and line number along with the output.

B<ARGUMENTS:> 

None 

B<RETURNS:> 

None 

B<GLOBALS USED:> 

None 

B<DEPENDENCIES:> 

None

B<NOTES:>

None

B<BUGS:>

None

B<SEE ALSO:> 

L</utils_trace_off()>, 
L</utils_stacktrace()>, 
L<utils_callStack(I<[start]>)|/utils_callStack([start])>, 
L<utils_debugme([I<commands>...])|/utils_debugme([commands...])> 

=cut

##======================================================================================
utils_trace_on()
{
    export PS4='+(${BASH_SOURCE}:${LINENO}): ${FUNCNAME[0]:+${FUNCNAME[0]}(): }'
    set -x
}

##== FUNCTION ==========================================================================
: <<='cut'

=head2 B<utils_trace_off()>

Debugging tool. Toggle-off Bash x-trace.

B<ARGUMENTS:>

None 

B<RETURNS:>

None 

B<GLOBALS USED:>

None

B<DEPENDENCIES:>

None

B<NOTES:>

Doesn't do anything more that "set +x" right now. 

B<BUGS:>

B<SEE ALSO:>

L</utils_trace_on()>, 
L</utils_stacktrace()>, 
L<utils_callStack(I<[start]>)|/utils_callStack([start])>, 
L<utils_debugme([I<commands>...])|/utils_debugme([commands...])>

=cut

##======================================================================================
utils_trace_off()
{
    set +x
}

##== FUNCTION ==========================================================================
: <<='cut'

=head2 B<utils_stacktrace()>

Debugging tool. Print a stack trace of the function call stack. 

B<ARGUMENTS:>

None 

B<RETURNS:>

None 

B<GLOBALS USED:>

None

B<DEPENDENCIES:>

None

B<NOTES:>

None 

B<BUGS:>

None

B<SEE ALSO:>

L<utils_callStack(I<[start]>)|/utils_callStack([start])>, 
L</utils_trace_on()>, 
L</utils_trace_off()>, 
L<utils_debugme([I<commands...>])|/utils_debugme([commands...])>

=cut

##======================================================================================
utils_stacktrace()
{

    declare FRAME=0

    echo "<----------Begin Stack Trace------------->"
    while caller ${FRAME}
    do
        ((FRAME++));
    done

    echo "$*"
    echo "<----------End Stack Trace------------->"

}

##== FUNCTION ==========================================================================
: <<='cut'

=head2 B<utils_debugme([I<commands...>])>

Debugging tool. This function does nothing when UTILS_DEBUGME is unset or empty, but it
executes the given parameters as commands when UTILS_DEBUGME is set. 

B<ARGUMENTS:>

I<commands...> - Any number of commands to execute. 

B<RETURNS:>

0 - (Always, regardless of result of commands passed.)

B<GLOBALS USED:>

L</UTILS_DEBUGME>

B<DEPENDENCIES:>

None

B<NOTES:>

Always returns 0 so as not to influence anything else with an unwanted B<false> return
code. For example, the script's exit code if this function is used as the very last 
command in the script.

B<BUGS:>

None

B<SEE ALSO:>

L</utils_trace_on()>, 
L</utils_trace_off()>, 
L</utils_stacktrace()>, 
L<utils_callStack(I<[start]>)|/utils_callStack([start])>, 

=cut

##======================================================================================
utils_debugme() 
{

    # This function does nothing when UTILS_DEBUGME is unset or empty, 
    # but it executes the given parameters as commands when UTILS_DEBUGME is set.

    [[ ${UTILS_DEBUGME} = 1 ]] && "$@" || :
    # be sure to append || : or || true here or use return 0

}

##== FUNCTION ==========================================================================
: <<='cut'

=head2 B<utils_lower(I<text>)>

Convert any alphabetic characters to lower-case.

B<ARGUMENTS:>

I<text> - Text to convert to lower-case 

B<RETURNS:>

echoes the first argument converted to lower-case. 

B<GLOBALS USED:>

None 

B<DEPENDENCIES:>

None

B<NOTES:>

Meant to be called in a subscript with either backticks or $( )'s

B<BUGS:>

None

B<SEE ALSO:>

L<utils_upper(I<text>)|/utils_upper(text)>

=cut

##======================================================================================
utils_lower ()
{
        echo "${1}" | tr A-Z a-z
}

##== FUNCTION ==========================================================================
: <<='cut'

=head2 B<utils_upper(I<text>)>

Convert any alphabetic characters to upper-case.

B<ARGUMENTS:>

I<text> - Text to convert to upper-case 

B<RETURNS:>

echoes the first argument converted to upper-case. 

B<GLOBALS USED:>

None 

B<DEPENDENCIES:>

None

B<NOTES:>

Meant to be called in a subscript with either backticks or $( )'s

B<BUGS:>

None

B<SEE ALSO:>

L<utils_lower(I<text>)|/utils_lower(text)>

=cut

##======================================================================================
utils_upper ()
{
         echo "${1}" | tr a-z A-Z
}

##== FUNCTION ==========================================================================
: <<='cut'

=head2 B<utils_logMsg(I<msgLogLevel, msg>)>

A single function for other utils functions to call in order to either queue or echo 
log messages depending on what the global B<UTILS_LOGMSG_QUEUE_MESSAGES> is set to.  

B<ARGUMENTS:>

I<msgLogLevel> - Integer representing the message log level 

I<msg> - Message to pass to either utils_qLogMsg or utils_logit 

B<RETURNS:>

0 - If either downstream logger returns 0 

1 - If either downstream logger returns 1 

B<GLOBALS USED:>

L</UTILS_LOGMSG_QUEUE_MESSAGES>

B<DEPENDENCIES:>

L<utils_logit(I<msgLogLevel, msg>)|/utils_logit(msgLogLevel, msg)>
L<utils_qLogMsg(I<logLevel, logMsg, [logLineNo], [logFuncName]>)
|/utils_qLogMsg(logLevel, logMsg, [logLineNo], [logFuncName])>

B<NOTES:>

None

B<BUGS:>

None

B<SEE ALSO:>

L<utils_logit(I<msgLogLevel, msg>)|/utils_logit(msgLogLevel, msg)>,, 
L<utils_qLogMsg(I<logLevel, logMsg, [logLineNo], [logFuncName]>)|/utils_qLogMsg(logLevel, logMsg, [logLineNo], [logFuncName])>

=cut

##======================================================================================
utils_logMsg()
{

    declare -i rval=0
    declare msgLogLevel="${1}"
    declare msg="${2}"
 
    # Escape any internal quoting chars with  a \ using perl
    # because it's just too ugly with sed.
    # Backquote can be literal but the single-quote
    # needs to be specified with the octal code \047
    # because bash can't interpret it as a literal
    #msg=$(echo "${msg}" | \
    #  perl -lane 's|`([^\047`]+)[\047`]|[\1]|g;print')

    if utils_true "${UTILS_LOGMSG_QUEUE_MESSAGES}"
    then
        utils_qLogMsg "${msgLogLevel}" "${msg}" 
        rval=$?
    else
        utils_logit "${msgLogLevel}" "${msg}" 
        rval=$?
    fi

    return ${rval}
        
}

##== FUNCTION ==========================================================================
: <<='cut'

=head2 B<utils_logit(I<msgLogLevel, msg>)>

A simple logging function that can be used to log conditionally by comparing 
a  passed log level against a global log level and echoing the message if 
the message level is less than or equal to  the global log level. Includes
a string representing the call stack. 

B<ARGUMENTS:>

I<msgLogLevel> - Integer representing the message log level 

I<msg> - Message to echo 

B<RETURNS:>

0 - If the message was supposed to be logged and was.

1 - If the message was supposed to be logged but was not.

B<GLOBALS USED:>

L</UTILS_LOGIT_LOG_LEVEL>

L</UTILS_LOGIT_LOG_DATE_FORMAT>

L</UTILS_LOGIT_LOG_FILE>

B<DEPENDENCIES:>

L<utils_lower(text)|/utils_lower(I<text>)>, L<utils_callStack(I<[start]>)|/utils_callStack([start])>

B<NOTES:>

This is the native logging function used by utils.sh library 
functions when log queueing is disabled (i.e. when UTILS_LOGMSG_QUEUE_MESSAGES 
is not true). 

B<BUGS:>

None

B<SEE ALSO:>

L<utils_logMsg(I<msgLogLevel, msg>)|/utils_logMsg(msgLogLevel, msg)>
L<utils_qLogMsg(I<logLevel, logMsg, [logLineNo], [logFuncName]>)|/utils_qLogMsg(logLevel, logMsg, [logLineNo], [logFuncName])>
L<utils_callStack(I<start>)|/utils_callStack([start])>

=cut

##======================================================================================
utils_logit()
{

    declare -i rval=0
    declare msgLogLevel="${1}"
    declare msg="${2}"
    declare logLevel=$(utils_lower ${UTILS_LOGIT_LOG_LEVEL})

    declare dateFormat=${UTILS_LOGIT_DATE_FORMAT:-"+%Y-%m-%d %H:%M:%S"}
    declare date=$(date "${dateFormat}")

    declare logMsg
    declare logFile

    declare callStack=$(utils_callStack)

    msgLogLevel=$(utils_lower ${1})

    if [ ${msgLogLevel} -ge ${logLevel:-0} ]
    then
        msg=${2}
        #logMsg="${date}|${msgLogLevel}|${BASH_LINENO[0]}|${FUNCNAME[2]}|${msg}"
        logMsg="${date}|${msgLogLevel}|${BASH_LINENO[0]}|${callStack}|${msg}"
        logFile=${3:-${UTILS_LOGIT_LOG_FILE:-${/dev/null}}}
        echo "${logMsg}" | tee -a ${logFile}
        #echo -n "${logMsg}" | tee -a ${logFile}
        #printf %s "${logMsg}" | tee -a ${logFile}
        rval=$?
    else
        :
    fi

    return ${rval}
        
}

##== FUNCTION ==========================================================================
: <<='cut'

=head2 B<utils_sha1sum(I<fileName>)>

Get and return the SHA-1 sum of a file.

B<ARGUMENTS:>

I<fileName> - Name of the file to get an SHA-1 sum of

B<RETURNS:>

Has both a return value and echoes a string. Check the return value through 
$? first to be sure that the echoed string was created successfully. 

0 - If getting the SHA-1 value of I<fileName> was successful

1 - If getting the SHA-1 value I<fileName> failed 

B<GLOBALS USED:>

None

B<DEPENDENCIES:>

None

B<NOTES:>

None

B<BUGS:>

None

B<SEE ALSO:>

=cut

##======================================================================================
utils_sha1sum ()
{

    declare rval=0
    declare sha1sumOutput
    declare sha1sum
    declare msg
    declare fileName="${1}"

    utils_fileReadable ${fileName}
    rval=$? 
    utils_qMsgsFrom utils_fileReadable

    if [ ${rval} -eq 0 ]
    then
        sha1sumOutput=$(sha1sum ${fileName})
        rval=$?
        if [ ${rval} -eq 0 ]
        then

            sha1sum=$(echo ${sha1sumOutput} | awk '{print $1}')

            if [ ${rval} -eq 0 ]
            then
                msg="SHA-1 sum of ${fileName} is '${sha1sum}'"
                utils_logMsg ${UTILS_QLOG_DEBUG} "${msg}" 
            else
                msg="Failed to parse the SHA-1 sum from ${sha1sumOutput}"
                utils_logMsg ${UTILS_QLOG_ERROR} "${msg}" 
            fi
        else
            msg="Failed to get SHA-1 sum of ${fileName}"
            utils_logMsg ${UTILS_QLOG_ERROR} "${msg}" 
        fi
    fi

    echo "${sha1sum}"
    return ${rval}

}

##== FUNCTION ==========================================================================
: <<='cut'

=head2 B<utils_eLogit(I<msgType, dateTime, hostName, msg, eventLog>)>

Another logging function specifically for event logging, mimicking the
elogging format. The output will always got to stdout and it may also
be sent to an event log specified in the last parameter. 

B<ARGUMENTS:>

I<msgType> - String for the type of message, defaults to MON. 

I<dateTime> - A preformatted date time string. Defaults to the current date 
and time given by the date command formatted "+%Y-%m-%d %H:%M:%S".

I<hostName> - The hostname as you wish it to appear. Defaults to the current
hostname. 

I<msg> - The rest of the message to log, formatted as you wish.

I<eventLog> - The path to the event log. Defaults to /dev/null only. 

B<RETURNS:>

0 - If the message was output 

1 - If the message was not output 

B<GLOBALS USED:>

None

B<DEPENDENCIES:>

None

B<NOTES:>

None

B<BUGS:>

None

B<SEE ALSO:>

L<utils_logMsg(I<msgLogLevel, msg>)|/utils_logMsg(msgLogLevel, msg)>
L<utils_logit(I<msgLogLevel, msg>)|/utils_logit(msgLogLevel, msg)>
L<utils_qLogMsg(I<logLevel, logMsg, [logLineNo], [logFuncName]>)|/utils_qLogMsg(logLevel, logMsg, [logLineNo], [logFuncName])>
L<utils_callStack(I<start>)|/utils_callStack([start])>

=cut

##======================================================================================
utils_eLogit ()
{

    declare rval=0
    declare msgType="${1:-MON}"
    declare dateTime=${2:-$(date "+%Y-%m-%d %H:%M:%S")}
    declare hostName="${3:-$(hostname)}"
    declare msg="${4}"
    declare eventLog="${5:-/dev/null}"

    printf "%s|%s|%s|%s|\n" \
        "${msgType}" \
        "${dateTime}" \
        "${hostName}" \
        "${msg}" | tee -a ${eventLog}

    rval=$?

    return ${rval}

}

##== FUNCTION ==========================================================================
: <<='cut'

=head2 B<utils_quoteSafeEval(I<lval, rval>)>

A helper function for utils_qLogMsg.
A hackish way to workaround the side-effect that the eval command has of
removing embedded single quotes from strings. This function uses perl to
construct an assignment command and then executes it. 

B<ARGUMENTS:>

I<lval> - A string representing the name of the variable that you want to
assign something to.

I<rval> - The value that you want to set the variable to. 

B<RETURNS:>

None

B<GLOBALS USED:>

None

B<DEPENDENCIES:>

None

B<NOTES:>

I'm not sure this is necessary anymore since I reworked logger_logQ. I
intend to try removing it when I get better test coverage for the messgage
queueing functions.


B<BUGS:>

None

B<SEE ALSO:>

L<utils_logMsg(I<msgLogLevel, msg>)|/utils_logMsg(msgLogLevel, msg)>
L<utils_qLogMsg(I<logLevel, logMsg, [logLineNo], [logFuncName]>)|/utils_qLogMsg(logLevel, logMsg, [logLineNo], [logFuncName])>
L<utils_callStack(I<start>)|/utils_callStack([start])>


=cut

##======================================================================================
utils_quoteSafeEval()
{

    declare lval="${1}"
    declare rval="${2}"
    declare setCom

    # old way -- not quote-safe
    #eval ${logFuncName}_LOG_MSG[${length}]=\"${logMsg}\"

    setCom=$(perl -se \
        'print "$lval=\"$rval\""' \
        -- \
        -lval="${lval}" \
        -rval="${rval}")

    eval "${setCom}"

}

##== FUNCTION ==========================================================================
: <<='cut'

=head2 B<utils_qLogMsg(I<logLevel, logMsg, [logLineNo], [logFuncName]>)>

This is the main log queueing function. It is usually not called directly 
but by utils_logMsg when log queueing is enabled. It can be used to log 
messages through some other function (like logger_logit) without creating a 
dependency upon it. This function will "queue" the log level, message, line 
number and function name by creating Bash arrays named after the caller. The 
caller can then dereference the arrays and echo the messages using its own 
logging implementation. 

B<ARGUMENTS:>

I<logLevel> - Integer representing the message log level

I<msg> - Message to queue 

I<logLineNo> - Optional but if you are calling this function 
directly then you should pass the caller's line number. 
See I<logFuncName>, below for more on why. 

I<logFuncName> - Optional but if you are calling this function
directly then you should pass the caller's function name. This will
override the default behavior that derives caller's function name from 
the Bash built-in, ${FUNCNAME[2]}. That default skips the immediate 
caller which is normally utils_logMsg and since there's not much value 
in always showing that function as the caller, it skips it and shows
the function that called utils_logMsg instead. If you're calling this 
function directly then you probably do want the immediate caller's 
function name.

B<RETURNS:>

0 - If the message was queued

1 - If the message was not queued 

B<GLOBALS USED:>

L</UTILS_QLOGMSG_QUEUES_ENABLED>

Dynamically creates 4 global arrays when it is called. The four arrays 
will be named after the calling function and indexed in lock-step. 
These four arrays can be thought of collectively as a message queue, 
bound together by virtue of the first part of their name.

${logFuncName}_LOG_LEVEL - Where ${logFuncName} is the name of the
calling function. Array holding the integers representing the log level 
of all queued messages. 

${logFuncName}_LOG_MSG - Where ${logFuncName} is the name of the
calling function. Array holding the messages queued for later logging. 

${logFuncName}_LOG_FUNCNAME - Where ${logFuncName} is the name of the
calling function. Array holding the names of all the calling functions that
have queued messages for logging.

${logFuncName}_LOG_LINENO - Where ${logFuncName} is the name of the
calling function. Array holding integers representing the line numbers that 
th calling function called this function from. 

B<DEPENDENCIES:> 

B<NOTES:>

Try to avoid passing embedded quotes in the logging messages to
this function. I'm not sure it supports them in every case. If you're getting 
"unexpected EOF while looking for matching ``', then most likely, there is an 
unbalanced quote in your logging message.

B<BUGS:>

None

B<SEE ALSO:>

L<utils_flushLogQ(I<funcName>)|/utils_flushLogQ(funcName)>
L<utils_qMsgsFrom(I<funcName, flushQ>)|/utils_qMsgsFrom(funcName, flushQ)>
L<utils_logMsg(I<msgLogLevel, msg>)|/utils_logMsg(msgLogLevel, msg)>
L<utils_logit(I<msgLogLevel, msg>)|/utils_logit(msgLogLevel, msg)>

=cut

##======================================================================================
utils_qLogMsg()
{

    # This was written in Bash 3 so associative arrays were not available. 
    # It is implemented using an eval hack that is difficult to read and 
    # problematic with embedded quotes in logging messages. When this library 
    # is ported to Bash 4, rewriting these message queueing functions to use 
    # associative arrays should be a high priority.

    declare -i rval=1 
    declare logLevel=${1:-UNKNOWN}
    declare logMsg="${2}"
    declare logLineNo=${3:-${BASH_LINENO[2]}}
    declare logFuncName=${4:-${FUNCNAME[2]}}
    declare length

    if utils_true "${UTILS_QLOGMSG_QUEUES_ENABLED}"
    then

        length=$(eval echo \${#${logFuncName}_LOG_LEVEL[*]})

        # Could try to sanitize any unbalanced quotes here but so far,
        # it has had bad side effects. you need a pretty complex regex
        # to identify only unbalanced quotes and not all quotes.
        #logMsg=$(echo "${logMsg}" | perl -lane 's|`|[backquote]|g;print')
        #logMsg=$(echo "${logMsg}" | perl -lane 's|\047|[singlequote]|g;print')

        if [ ${length} -ge 0 ]
        then 
            eval ${logFuncName}_LOG_LEVEL[${length}]=\"${logLevel}\"

            # This is risky. If you're getting "unexpected EOF while looking for matching ``',
            # then most likely, there is an unbalanced quote in your logging message. Try
            # to fix it before passing it to this function first.  
            # Here's a technique to do that using perl:

                # Escape any internal non-alpha chars with  a \ using perl
                # because it's just too ugly with sed.
                #logMsg=$(echo "${logMsg}" | perl -lane 's/([^a-zA-Z0-9])/\\$1/g; print')	

            eval ${logFuncName}_LOG_MSG[${length}]=\"${logMsg}\"

            #utils_quoteSafeEval ${logFuncName}_LOG_MSG[${length}] "${logMsg}"		

            eval ${logFuncName}_LOG_LINENO[${length}]=\"${logLineNo}\"
            eval ${logFuncName}_LOG_FUNCNAME[${length}]=\"${logFuncName}\"
            rval=0
        fi
    else
        :
        # do nothing because log message queueing is disabled
    fi

    return ${rval}

}

##== FUNCTION ==========================================================================
: <<='cut'

=head2 B<utils_flushLogQ(I<funcName>)>

Flush all values from the four global arrays that were dynamically created with 
L<utils_qLogMsg(I<logLevel, logMsg, [logLineNo], [logFuncName]>)|/utils_qLogMsg(logLevel, logMsg, [logLineNo], [logFuncName])>
This is very often used by 
L<utils_qMsgsFrom(I<funcName, flushQ>)|/utils_qMsgsFrom(funcName, flushQ)>
after it moves messages from one queue to another.

B<ARGUMENTS:>

I<funcName> - Can be thought of as a message queue name.
Technically, it's the function name after which the four global
message queue arrays are named. 

B<RETURNS:>

0 - If it attempted to flush a message queue.

1 - If it did not attempt to flush a message queue because 
message queueing is disabled.

B<GLOBALS USED:>

L</UTILS_QLOGMSG_QUEUES_ENABLED>

Dynamically unsets 4 global arrays when it is called. 
See 
L<utils_qLogMsg(I<logLevel, logMsg, [logLineNo], [logFuncName]>)|/utils_qLogMsg(logLevel, logMsg, [logLineNo], [logFuncName])>
for more information on these arrays.

${logFuncName}_LOG_LEVEL 

${logFuncName}_LOG_MSG 

${logFuncName}_LOG_FUNCNAME 

${logFuncName}_LOG_LINENO 

=cut

##======================================================================================
utils_flushLogQ()
{

    declare -i rval=0
    declare funcName="${1}"

    if utils_true "${UTILS_QLOGMSG_QUEUES_ENABLED}"
    then
        unset $(eval echo ${funcName}_LOG_LEVEL) 
        unset $(eval echo ${funcName}_LOG_MSG) 
        unset $(eval echo ${funcName}_LOG_LINENO) 
        unset $(eval echo ${funcName}_LOG_FUNCNAME) 
    else
        # do nothing because log message queueing is disabled
        rval=1        
    fi

    return ${rval}

}

##== FUNCTION ==========================================================================
: <<='cut'

=head2 B<utils_qMsgsFrom(I<funcName, flushQ>)>

Move messages from one queue to another. This is used when utils_ function a
calls utils_ function b and function b creates its own messages. The caller of 
function a doesn't need to know that function b was called and may have messages
for him. He only needs to print messages from function a to see all of the  
messages.

B<ARGUMENTS:>

I<funcName> - Can be thought of as a message queue name.
Technically, it's the function name after which the four global
message queue arrays are named. 

I<flushQ> - Whether or not to flush the queue that you moved the messages from
after you move them. If this is false, then messages can be duplicated. 
Defaults to true. 

B<RETURNS:>

0 -  If messages were moved from one queue to another.

1 - If no messages were moved. 

B<GLOBALS USED:>

L</UTILS_QLOGMSG_QUEUES_ENABLED>

L</UTILS_LOGMSG_QUEUE_MESSAGES>

Also uses 4 global arrays, the full names of which are determined by the first 
argument to this function when it is called. See 
L<utils_qLogMsg(I<logLevel, logMsg, [logLineNo], [logFuncName]>)|/utils_qLogMsg(logLevel, logMsg, [logLineNo], [logFuncName])>
for more information on these arrays.

${logFuncName}_LOG_LEVEL 

${logFuncName}_LOG_MSG 

${logFuncName}_LOG_FUNCNAME 

${logFuncName}_LOG_LINENO 

=cut

##======================================================================================
utils_qMsgsFrom()
{

    declare -i rval=1
    declare indexes
    declare ndx
    declare logLevel
    declare logMsg
    declare logLineNo
    declare logFuncName
    declare callerFuncName=${FUNCNAME[1]}
    declare callStack
    declare flushQ=${2:-true}

    declare callerQLength

    if utils_true "${UTILS_QLOGMSG_QUEUES_ENABLED}"
    then

        if utils_true "${UTILS_LOGMSG_QUEUE_MESSAGES}"
        then
            # move any messages from one queue to another
            rval=0
        else
            : # do nothing because the messages were 
              # logged instead of queued anyway
        fi
    else
        : # do nothing because log message queueing is disabled 
    fi

    if [ ${rval} -eq 0 ]
    then

		# Find out if you really need the double "eval echo" here 

        indexes=$(eval echo $(eval echo \${!${1}_LOG_LEVEL[@]}))

        #echo "indexes=${indexes}"

        for ndx in ${indexes}
        do
            # Find out if you really need the double "eval echo" here 
            logLevel=$(eval echo $(eval echo \${${1}_LOG_LEVEL[${ndx}]}))
            logMsg=$(eval echo $(eval echo \${${1}_LOG_MSG[${ndx}]}))
            logLineNo=$(eval echo $(eval echo \${${1}_LOG_LINENO[${ndx}]}))
            logFuncName=$(eval echo $(eval echo \${${1}_LOG_FUNCNAME[${ndx}]}))

            callStack="${callerFuncName}-\>${logFuncName}"

            #echo "logMsg=${logMsg}"
            #echo "callStack=${callStack}"

            #utils_logMsg "${logLevel}" "${logMsg}" "${logLineNo}" "${callStack}"
        
            callerQLength=$(eval echo \${#${callerFuncName}_LOG_LEVEL[*]})

            if [ ${callerQLength} -ge 0 ]
            then 
                eval ${callerFuncName}_LOG_LEVEL[${callerQLength}]=\"${logLevel}\"
                eval ${callerFuncName}_LOG_MSG[${callerQLength}]=\"${logMsg}\"
                eval ${callerFuncName}_LOG_LINENO[${callerQLength}]=\"${logLineNo}\"
                eval ${callerFuncName}_LOG_FUNCNAME[${callerQLength}]=\"${callStack}\"
            else
                rval=1
            fi

        done

        if utils_true "${flushQ}"
        then
            if utils_flushLogQ "${1}"
            then
                :
            else
                :
            fi
        fi
    fi

    return ${rval}

}

##== FUNCTION ==========================================================================
: <<='cut'

=head2 B<utils_exec(I<command, sterr_file>)>

A kind of shell wrapper to add an extra layer of fault-tolerance and assist in 
debugging.  Execute a passed command defensively by first optionally logging it and 
then checking for success two different ways: first check the command's exit code and 
then look for a stderr output resulting from the command. If the exit code is non-zero
or there is a stderr file, the log an error, including the stderr and return 1.

B<ARGUMENTS:>

I<command> - Command to execute

I<stderr_file> - Optional file name for the sterr output to go to (defaults to
DEFAULT_STDERR)

B<RETURNS:>

0 - If command was successful

1 - If command was not successful

B<GLOBALS USED:>

L</UTILS_QLOG_DEBUG>

L</UTILS_QLOG_ERROR>

L</UTILS_LOGIT_LOG_FILE>

B<DEPENDENCIES:>

L<utils_qLogMsg(I<logLevel, logMsg, [logLineNo], [logFuncName]>)|/utils_qLogMsg(logLevel, logMsg, [logLineNo], [logFuncName])> 

B<NOTES:>

This function can be unpredictable if the command you pass it to execute has 
an echo in it because it does its own internal echo'ing so make sure you test 
whatever command you pass it. 

Should probably be changed to return the exit code from the command rather
then just 1 on failure but that would need to be tested.

B<BUGS:>

None

B<SEE ALSO:>

None

=cut

##======================================================================================
utils_exec ()
{

    declare -i rval=0
    declare defaultStderr="./utils.stderr"
 
    declare com="${1}"
    declare stderr="${2:-${defaultStderr}}"
    declare msg 
    declare no_op="${UTILS_EXEC_no_op:-false}"

    # Must single-quote the command to log it or chaos could unsue if
    # redirection characters are passed
    if utils_true "${no_op}"
    then
        utils_logMsg ${UTILS_QLOG_DEBUG} "no_op Command: '${com}'"
    else

        #utils_logMsg ${UTILS_QLOG_DEBUG} "Executing: '${com}'"
        eval ${com}	
        rval=$?

        if [ ${rval} -eq 0 ]
        then
            utils_logMsg ${UTILS_QLOG_DEBUG} "Zero exit status received from external command." 
        else
            utils_logMsg ${UTILS_QLOG_ERROR} "Non-zero exit status received from the previous  command."
            #utils_logMsg ${UTILS_QLOG_ERROR} "'${com}'"
            if [ -s ${stderr} ]
            then
                utils_logMsg ${UTILS_QLOG_ERROR} "stderr from above command follows:"
                msg=`cat ${stderr}`
                utils_logMsg ${UTILS_QLOG_ERROR} "${msg}" 
            else
                utils_logMsg ${UTILS_QLOG_ERROR} "No stderr was captured from the above command." 
            fi # [ -f ${stderr} ]
        fi # [ $? == 0 ] 
    fi

    return ${rval}

}

##== FUNCTION ==========================================================================
: <<='cut'

=head2 B<utils_fileReadable(I<path>)>

A single function to test for I<path> being not null, a file and readable. If any of 
these tests fails then use utils_qLogMsg to log which one.

B<ARGUMENTS:>

I<path> - Path to file

B<RETURNS:>

0 - If I<path> is a readable file

1 - If I<path> is not a readable file  

B<GLOBALS USED:>

L</UTILS_QLOG_ERROR>

B<DEPENDENCIES:>

L<utils_qLogMsg(I<logLevel, logMsg, [logLineNo], [logFuncName]>)|/utils_qLogMsg(logLevel, logMsg, [logLineNo], [logFuncName])> 

B<NOTES:>

None

B<BUGS:>

None

B<SEE ALSO:>

L<utils_fileReadable(I<path>)|/utils_fileReadable(path)>, 
L<utils_fileWriteable(I<path>)|/utils_fileWriteable(path)>, 
L<utils_canWriteOrCreateFile(I<path>)|/utils_canWriteOrCreateFile(path)>, 
L<utils_fileExecutable(I<path>)|/utils_fileExecutable(path)>, 
L<utils_dirReady(I<path>)|/utils_dirReady(path)>

=cut

##======================================================================================
utils_fileReadable ()
{
    declare -i rval=1

    if [ -z $1 ]
    then
        utils_logMsg ${UTILS_QLOG_ERROR} "utils_fileReadable was passed a null parameter."
    else
        if [ ! -f $1 ]
        then
            utils_logMsg ${UTILS_QLOG_ERROR} "${1} is not a file."
        else
            if [ ! -r $1 ]
            then
                utils_logMsg ${UTILS_QLOG_ERROR} "${1} is not readable."
            else
                utils_logMsg ${UTILS_QLOG_DEBUG} "${1} is readable."
                rval=0
            fi # [ ! -r $1 ]
        fi # [ ! -f $1 ]
    fi # [ -z $1 ]

    return $rval
}

##== FUNCTION ==========================================================================
: <<='cut'

=head2 B<utils_fileWriteable(I<path>)>

A single function to test for I<path> being not null, a file and writeable. If any of 
these tests fails then use utils_qLogMsg to log which one failed.

B<ARGUMENTS:>

I<path> - Path to file

B<RETURNS:>

0 - If I<path> is a writeable file

1 - If I<path> is not a writeable file  

B<GLOBALS USED:>

L</UTILS_QLOG_WARN>

L</UTILS_QLOG_ERROR>

B<DEPENDENCIES:>

L<utils_qLogMsg(I<logLevel, logMsg, [logLineNo], [logFuncName]>)|/utils_qLogMsg(logLevel, logMsg, [logLineNo], [logFuncName])> 

B<NOTES:>

None

B<BUGS:>

None

B<SEE ALSO:>

L<utils_fileWriteable(I<path>)|/utils_fileWriteable(path)>, 
L<utils_canWriteOrCreateFile(I<path>)|/utils_canWriteOrCreateFile(path)>, 
L<utils_fileExecutable(I<path>)|/utils_fileExecutable(path)>, 
L<utils_dirReady(I<path>)|/utils_dirReady(path)>

=cut

##======================================================================================
utils_fileWriteable ()
{
    declare -i rval=0

    if [ -z $1 ]
    then
        utils_logMsg ${UTILS_QLOG_ERROR} "utils_fileWriteable was passed a null parameter."
        rval=1
    else
        if [ -f $1 ]
        then
            utils_logMsg ${UTILS_QLOG_WARN} "${1} already exists. Overwriting."
            if [ -w $1 ]
            then
                utils_logMsg ${UTILS_QLOG_DEBUG} "${1} is writeable."
                rval=0
            else
                utils_logMsg ${UTILS_QLOG_ERROR} "Can not overwrite '${1}'. Check permissions."
                rval=1
            fi # [ -w $1 ]
        else
            utils_logMsg ${UTILS_QLOG_ERROR} "${1} is not a file."
            rval=1
        fi # [ -f $1 ]
    fi # [ -z $1 ]

    return $rval
}

##== FUNCTION ==========================================================================
: <<='cut'

=head2 B<utils_canWriteOrCreateFile(I<path>)>

A single function to test for I<path> being not null, and either not already 
a file or a file that can be written to.

B<ARGUMENTS:>

I<path> - Path to file

B<RETURNS:>

0 - If I<path> is either a file that can be written to or not a file at all.

1 - If I<path> is a non-writeable file  

B<GLOBALS USED:>

L</UTILS_QLOG_WARN>

L</UTILS_QLOG_ERROR>

B<DEPENDENCIES:>

L<utils_qLogMsg(I<logLevel, logMsg, [logLineNo], [logFuncName]>)|/utils_qLogMsg(logLevel, logMsg, [logLineNo], [logFuncName])> 

B<NOTES:>

None

B<BUGS:>

None

B<SEE ALSO:>

L<utils_fileReadable(I<path>)|/utils_fileReadable(path)>, 
L<utils_fileWriteable(I<path>)|/utils_fileWriteable(path)>, 
L<utils_canWriteOrCreateFile(I<path>)|/utils_canWriteOrCreateFile(path)>, 
L<utils_fileExecutable(I<path>)|/utils_fileExecutable(path)>, 
L<utils_dirReady(I<path>)|/utils_dirReady(path)>

=cut

##======================================================================================
utils_canWriteOrCreateFile()
{
    declare -i rval=0

    if [ -z "${1}" ]
    then
        utils_logMsg ${UTILS_QLOG_ERROR} "utils_canWriteOrCreateFile was passed a null parameter."
        rval=1
    else
        if [ -f "${1}" ]
        then
            if [ -w "${1}" ]
            then
                utils_logMsg ${UTILS_QLOG_DEBUG} "${1} exists and is writeable."
                rval=0
            else
                utils_logMsg ${UTILS_QLOG_ERROR} "${1} exists but can not overwrite. Check permissions."
                rval=1
            fi
        else
            utils_logMsg ${UTILS_QLOG_DEBUG} "${1} does not exist. Can create."
            rval=0
        fi
    fi 

    return $rval
}

##== FUNCTION ==========================================================================
: <<='cut'

=head2 B<utils_fileExecutable(I<path>)>

A single function to test for I<path> being not null, a file and executable. If any of 
these tests fails then use utils_qLogMsg to log which one failed.

B<ARGUMENTS:>

I<path> - Path to file

B<RETURNS:>

0 - If I<path> is an executable file

1 - If I<path> is not an executable file

B<GLOBALS USED:>

L</UTILS_QLOG_ERROR>

B<DEPENDENCIES:>

L<utils_qLogMsg(I<logLevel, logMsg, [logLineNo], [logFuncName]>)|/utils_qLogMsg(logLevel, logMsg, [logLineNo], [logFuncName])> 

B<NOTES:>

None

B<BUGS:>

None

B<SEE ALSO:>

L<utils_fileReadable(I<path>)|/utils_fileReadable(path)>, 
L<utils_fileWriteable(I<path>)|/utils_fileWriteable(path)>, 
L<utils_canWriteOrCreateFile(I<path>)|/utils_canWriteOrCreateFile(path)>, 
L<utils_dirReady(I<path>)|/utils_dirReady(path)>

=cut

##======================================================================================
utils_fileExecutable ()
{
    declare -i rval=1

    if [ -z $1 ]
    then
        utils_logMsg ${UTILS_QLOG_ERROR} "utils_fileExecutable was passed a null parameter."
    else
        if [ ! -f $1 ]
        then
            utils_logMsg ${UTILS_QLOG_ERROR} "${1} is not a file."
        else
            if [ ! -x $1 ]
            then
                utils_logMsg ${UTILS_QLOG_ERROR} "${1} is not executable."
            else
                utils_logMsg ${UTILS_QLOG_DEBUG} "${1} is executable."
                rval=0
            fi # [ ! -x $1 ]
        fi # [ ! -f $1 ]
    fi # i[ -z $1 ]

    return $rval
}

##== FUNCTION ==========================================================================
: <<='cut'

=head2 B<utils_dirReady(I<path>)>

A single function to test for I<path> being not null, a directory and executable. If any of 
these tests fails then use utils_qLogMsg to log which one failed.

B<ARGUMENTS:>

I<path> - Path to directory

B<RETURNS:>

0 - If I<path> is an executable directory

1 - If I<path> is not an executable directory

B<GLOBALS USED:>

L</UTILS_QLOG_ERROR>

L</UTILS_QLOG_DEBUG>

B<DEPENDENCIES:>

L<utils_qLogMsg(I<logLevel, logMsg, [logLineNo], [logFuncName]>)|/utils_qLogMsg(logLevel, logMsg, [logLineNo], [logFuncName])> 

B<NOTES:>

None

B<BUGS:>

None

B<SEE ALSO:>

L<utils_fileReadable(I<path>)|/utils_fileReadable(path)>, 
L<utils_fileWriteable(I<path>)|/utils_fileWriteable(path)>, 
L<utils_canWriteOrCreateFile(I<path>)|/utils_canWriteOrCreateFile(path)>, 
L<utils_fileExecutable(I<path>)|/utils_fileExecutable(path)> 

=cut

##======================================================================================
utils_dirReady ()
{

    declare -i rval=1
    declare TEST_DIR=${1}

    if [ "x${TEST_DIR}" = "x" ] 
    then
        utils_logMsg ${UTILS_QLOG_ERROR} "utils_dirReady was passed null or an empty string." 
    else
        if [ ! -d ${TEST_DIR} ]
        then
            utils_logMsg ${UTILS_QLOG_ERROR} "${TEST_DIR} is not a directory." 
        else
            if [ ! -x ${TEST_DIR} ]
            then
                utils_logMsg ${UTILS_QLOG_ERROR} "${TEST_DIR} is not executable."
            else
                utils_logMsg ${UTILS_QLOG_DEBUG} "${TEST_DIR} is ready."
                #utils_logMsg ${UTILS_QLOG_DEBUG} "${TEST_DIR} is still ready."
                rval=0
            fi # [ ! -x $1 ]
        fi # [ ! -f $1 ]
    fi # i[ -z $1 ]

    return ${rval}    

}

##== FUNCTION ==========================================================================
: <<='cut'

=head2 B<utils_workFileNameSameExt(I<basisName, surname, workDir>)>

Create a path name based on an another file name, with the same extension but 
with a different directory name and a suffix inserted right before the 
extension, if any. 

Example: Calling this function like so:

C<tmpFile=$(utils_workFileNameSameExt("/somedir/thisFile.xml" "-tmp" "/tmp"))>

C<tmpFile> would be assigned the value: I</tmp/thisFile-tmp.xml>             

Example: Calling this function like so:

C<tmpFile=$(utils_workFileNameSameExt("/somedir/thisFile" -tmp "/newDir"))>

C<tmpFile> would be assigned the value: I</newDir/thisFile-tmp>             

B<ARGUMENTS:>

I<basisName> - File name to base the new file name on. 
Defaults to the name of the currently executing script. 

I<surname> - String to add at the end of the new file name, right before
the last dot preceding the file extension. A file extension is that portion 
of the file name following the last dot, if there is a dot. If there is no file
extension, then the surname will be appended to the end of the file name. 

I<workDir> - The directory replace the directory portion of basisName with.
dire 

B<RETURNS:>

Has both a return value and echoes a string. Check the return value through 
$? first to be sure that the echoed string was created successfully. 

0 - If I<path> is an executable directory

1 - If I<path> is not an executable directory

B<GLOBALS USED:>

L</UTILS_QLOG_DEBUG> 

L</UTILS_QLOG_ERROR>

B<DEPENDENCIES:> 

L<utils_similarNameSameExt(I<srcName, surname>)|/utils_similarNameSameExt(srcName, surname)>
L<utils_replaceDirName(I<pathName, dirName>)|/utils_replaceDirName(pathName, dirName)>
L<utils_qLogMsg(I<logLevel, logMsg, [logLineNo], [logFuncName]>)|/utils_qLogMsg(logLevel, logMsg, [logLineNo], [logFuncName])>

B<NOTES:> 

Meant to be called in a subscript with either backticks or $( )'s

B<BUGS:>

None

B<SEE ALSO:>

L<utils_sameNameDifferentExt(I<[path], [newExt]>)|/utils_sameNameDifferentExt([path], [newExt])>

L<utils_workFileNameDifferentExt(I<basisName, ext, workDir>)|/utils_workFileNameDifferentExt(basisName, ext, workDir)>

=cut

##======================================================================================
utils_workFileNameSameExt()
{

    declare -i rval

    declare basisName="${1:-${0}}"
    declare surname="${2}"
    declare workDir="${3}"
    declare newName=""
    declare msg
    declare msgLevel=${UTILS_QLOG_DEBUG} 

    rval=1
    if [ -n "${basisName}" ]
    then
        if [ -n "${surname}" ]
        then
            if [ -n "${workDir}" ]
            then
                rval=0
            else
                msgLevel=${UTILS_QLOG_ERROR}
                msg="No working dir." 
            fi
        else
            msgLevel=${UTILS_QLOG_ERROR}
            msg="No surname."
        fi
    else
        msgLevel=${UTILS_QLOG_ERROR}
        msg="No basis name."
    fi

    if [ ${rval} -eq  0 ]
    then

        rval=1
        newName=$(utils_similarNameSameExt "${basisName}" "${surname}")
        if [ $? -eq 0 ]
        then
            newName=$(utils_replaceDirName "${newName}" "${workDir}")
            if [ $? -eq 0 ]
            then
                rval=0
            else
                msgLevel=${UTILS_QLOG_ERROR}
                msg="utils_replaceDirName failed."
            fi
        else
            msgLevel=${UTILS_QLOG_ERROR}
            msg="utils_similarNameSameExt failed."
        fi
    fi

    #utils_logMsg ${msgLevel} "${msg}"
    utils_qLogMsg ${msgLevel} "${msg}"

    echo "${newName}"
    return ${rval}

}

##== FUNCTION ==========================================================================
: <<='cut'

=head2 B<utils_workFileNameDifferentExt(I<basisName, ext, workDir>)>

Create file name based on an another file name but with a different extension.

B<ARGUMENTS:>

I<basisName> - File name to base the new file name on. 

I<ext> - New extension to assign to the return value,

I<workDir> - The directory to replace the directory portion of basisName with.

B<RETURNS:>

Has both a return value and echoes a string. Check the return value through 
$? first to be sure that the echoed string was created successfully. 

0 - If I<path> is an executable directory

1 - If I<path> is not an executable directory

B<GLOBALS USED:>

L</UTILS_QLOG_DEBUG> 

L</UTILS_QLOG_ERROR>

B<DEPENDENCIES:> 

L<utils_sameNameDifferentExt(I<[path], [newExt]>)|/utils_sameNameDifferentExt([path], [newExt])>
L<utils_replaceDirName(I<pathName, dirName>)|/utils_replaceDirName(pathName, dirName)>

B<NOTES:> 

Meant to be called in a subscript with either backticks or $( )'s

B<BUGS:>

None

B<SEE ALSO:>

L<utils_workFileNameSameExt(I<basisName, surname, workDir>)|/utils_workFileNameSameExt(basisName, surname, workDir)>

=cut

##======================================================================================
utils_workFileNameDifferentExt()
{

    declare rval

    declare basisName="${1}"
    declare ext="${2}"
    declare workDir="${3}"
    declare newName

    if [ -n "${basisName}" ]
    then
        if [ -n "${ext}" ]
        then
            if [ -n "${workDir}" ]
            then
                rval=0
            fi
        fi
    fi

    if [ ${rval} -eq  0 ]
    then
        newName=$(utils_sameNameDifferentExt "${basisName}" "${ext}")
        newName=$(utils_replaceDirName "${newName}" "${workDir}")
    fi

    echo "${newName}"
    return ${rval}

}


##== FUNCTION ==========================================================================
: <<='cut'

=head2 B<utils_replaceDirName(I<pathName, dirName>)>

Replace the directory name portion of a path name with a new directory name. 

B<ARGUMENTS:>

I<pathName> - Path name containing a directory and file name. 

I<dirName> - New directory name to replace the directory name in pathName with.  

B<RETURNS:>

Echoes pathName with the directory name portion replaced with dirName.

B<GLOBALS USED:>

L</UTILS_QLOG_DEBUG> 

L</UTILS_QLOG_ERROR>

B<DEPENDENCIES:> 

L<utils_qLogMsg(I<logLevel, logMsg, [logLineNo], [logFuncName]>)|/utils_qLogMsg(logLevel, logMsg, [logLineNo], [logFuncName])>

B<NOTES:> 

Meant to be called in a subscript with either backticks or $( )'s

B<BUGS:>

None

B<SEE ALSO:>

L<utils_sameNameDifferentExt(I<[path], [newExt]>)|/utils_sameNameDifferentExt([path], [newExt])>
L<utils_replaceDirName(I<pathName, dirName>)|/utils_replaceDirName(pathName, dirName)>
L<utils_workFileNameSameExt(I<basisName, surname, workDir>)|/utils_workFileNameSameExt(basisName, surname, workDir)>

=cut

##======================================================================================
utils_replaceDirName()
{

    declare rval

    declare pathName="${1}"
    declare dirName="${2}"
    declare baseName

    baseName=$(basename "${pathName}") 

    utils_qLogMsg ${UTILS_QLOG_DEBUG} "Last char of '${dirName}' is '${dirName: -1:1}'" 

    if [ "x${dirName}" = "x" ]
    then
        rval=${pathName} 
    else
        # Get the last character in dirName 
        # using bash parameter substitution.
        # Your editor's syntax highlighting
        # may show  this as an error 
        # but the space between the : and -1
        # are valid and necessary to  
        # prevent bash from treating the
        # negative offset as a :- which
        # is the default-parameter code.
        if [ "${dirName: -1:1}" = "/" ]
        then
            rval=${dirName}${baseName}
        else
            rval=${dirName}/${baseName}
        fi 
    fi

    echo "${rval}"

}

##== FUNCTION ==========================================================================
: <<='cut'

=head2 B<utils_sameNameDifferentExt(I<[path], [newExt]>)>

Create file name based on an another file name but with a different newExtension. This 
function has three different forms:

B<First form:> utils_sameNameDifferentExt() - With no arguments, it will create 
a file name based on the currently executing script with the currently executing 
process id as the newExtension. 

Example: Calling this function from myscript.sh running as process id '1234' like so:

C<tmpFile=$(utils_sameNameDifferentExt())>

C<tmpFile> would be assigned the value: I<myscript.1234>

B<Second form:> utils_sameNameDifferentExt(newExt) - With a single argument, it will 
create a file name based on the currently executing script with 'newExt' as the
newExtension. 

Example: If the currently executing script is named myscript.sh and this function 
is called like so: 

C<tmpFile=$(utils_sameNameDifferentExt(tmp))>

C<tmpFile> would be assigned the value: I<myscript.tmp>             

B<Third form:> utils_sameNameDifferentExt(path, newExt) - With two arguments, 
it will create a file name based on path with newExt as the newExtension.

Example: If this function is called like so: 

C<tmpFile=$(utils_sameNameDifferentExt(someScript, tmp))>

C<tmpFile> would be assigned the value: I<someScript.tmp>

B<ARGUMENTS:>

[I<path>] - Optional file name to base the new file name on. 
Defaults to the name of the currently executing script. 

[I<newExt>] - Optional newExtension to use to create the new file name.
Defaults to the process id of the currently executing script. 

B<RETURNS:>

echoes the newly-created file name 

B<GLOBALS USED:>

None 

B<DEPENDENCIES:> None

B<NOTES:> 

Meant to be called in a subscript with either backticks or $( )'s

B<BUGS:>

None

B<SEE ALSO:>

L<utils_similarNameSameExt(I<srcName, surname>)|/utils_similarNameSameExt(srcName, surname)>

=cut

##======================================================================================
utils_sameNameDifferentExt()
{

    declare rval=1
    declare path="${1}"
    declare newExt
    declare newName

    declare dot="."

    case $# in
        0)  path=${0}  
            newExt=${$}
        ;;
        1)  path=${0}
            newExt="${1}"
        ;;
        *)  path=${1:-${0}}
            newExt="${2}"
        ;;
    esac

    newName=$(utils_pathWithoutExt "${path}")
    if [ $? -eq 0 ]
    then
        newName=${newName}${dot}${newExt} 
        rval=0
    fi

    echo "${newName}"
    return ${rval}

}

##== FUNCTION ==========================================================================
: <<='cut'

=head2 B<utils_similarNameSameExt(I<srcName, surname>)>

Create file name based on an another file name, with the same extension but with a 
suffix inserted right before the extension, if any.

Example: Calling this function like so:

C<tmpFile=$(utils_similarNameSameExt(thisFile.xml, -tmp))>

C<tmpFile> would be assigned the value: I<thisFile-tmp.xml>             

Example: Calling this function like so:

C<tmpFile=$(utils_similarNameSameExt(thisFile, -tmp))>

C<tmpFile> would be assigned the value: I<thisFile-tmp>             

This can be useful to create temporary files based on some existing file without
changing its extension, which can affect the way some programs process and display
it. For example, if you want to create an xml file based on an existing one, the 
new file will still retain xml-like syntax highlighting and colors.

B<ARGUMENTS:>

I<srcName> - File name to base the new file name on. 
Defaults to the name of the currently executing script. 

I<surname> - String to add at the end of the new file name, right before
the last dot preceding the file extension. A file extension is that portion 
of the file name following the last dot, if there is a dot. If there is no file
extension, then the surname will simply be appended to the end of the file 
name. 

B<RETURNS:>

echoes the newly-created file name 

B<GLOBALS USED:>

None 

B<DEPENDENCIES:> 

None

B<NOTES:> 

Meant to be called in a subscript with either backticks or $( )'s

B<BUGS:>

None

B<SEE ALSO:>

L<utils_sameNameDifferentExt(I<[path], [newExt]>)|/utils_sameNameDifferentExt([path], [newExt])>

=cut

##======================================================================================
utils_similarNameSameExt ()
{
   
    declare rval=1
    declare srcName="${1:-${0}}"
    declare surname="${2}"
    declare name
    declare dot="."
    declare ext
    declare newName

     
    name=$(utils_fileNameWithoutExt "${srcName}")
    if [ $? -eq 0 ]
    then
        ext=$(utils_fileExt "${srcName}")
        if [ $? -eq 0 ]
        then

            rval=0
            if [ "${srcName: -1:1}" = "${dot}" ]
            then
                newName=${name}${surname}${dot}
            else
                if [ -n "${ext}" ]
                then
                    newName=${name}${surname}${dot}${ext}
                else
                    newName=${name}${surname}
                fi #  [ -n "${ext}" ]
            fi # [ "${srcName: -1:1}" = "${dot}" ]
        fi # [ $? -eq 0 ]
    fi # [ $? -eq 0 ]

    echo "${newName}"
    return ${rval}

}


##== FUNCTION ==========================================================================
: <<='cut'

=head2 B<utils_pathWithoutExt(I<path>)>

Given a path name to a file, extract and return only that portion up to the 
last dot, if there is a dot. 

B<ARGUMENTS:>

I<path> - Path name containing a directory, file name and optionally, 
an extension. 

B<RETURNS:>

Has both a return value and echoes a string. Check the return value through 
$? first to be sure that the echoed string was created successfully. 

0 - If succesfully parsed the path (w/o the extension) from I<path>

1 - If failed to parse the path (w/o the extension) from I<path>

Echoes only that portion of path up to the last dot, if there is a dot. 

B<GLOBALS USED:>

L</UTILS_QLOG_DEBUG>

L</UTILS_QLOG_ERROR>

B<DEPENDENCIES:> 

Perl v5.8 or later
L<utils_qLogMsg(I<logLevel, logMsg, [logLineNo], [logFuncName]>)|/utils_qLogMsg(logLevel, logMsg, [logLineNo], [logFuncName])>

B<NOTES:> 

Meant to be called in a subscript with either backticks or $( )'s

B<BUGS:>

None

B<SEE ALSO:>

L<utils_fileNameWithoutExt(I<path>)|/utils_fileNameWithoutExt(path)>

=cut

##======================================================================================
utils_pathWithoutExt() 
{

    declare rval=0

    declare path="${1}"
    declare newPath
    declare msg 
    declare msgLevel=${UTILS_QLOG_DEBUG}

    # Needed perl's negative lookahead: (?!.*/)
    # to stop the backtrack at the last occurance
    # of the dot to handle cases like this: "/1.2/file-subdir1a.txt.1" 
    # This tells the regex to not backtrack to any dot that is
    # followed by zero or more characters and either another
    # dot. 

    newPath=$(echo "${path}" | perl -lane \
        'if( m{(^.*)\.(?!.*/)} ){print $1} else {print $_}')

    if [ $? -eq 0 ]
    then 
        msgLevel=${UTILS_QLOG_DEBUG}
        msg="Parsing with perl regex successful."
    else
        msgLevel=${UTILS_QLOG_ERROR}
        msg="Failed to parse with perl regex."
        rval=1
    fi

    utils_qLogMsg ${msgLevel} "${msg}"

    echo "${newPath}"    
    return ${rval}

}

##== FUNCTION ==========================================================================
: <<='cut'

=head2 B<utils_fileNameWithoutExt(I<path>)>

Given a path name to a file, extract and return only that portion of the file
name (excluding the directory name) up to the last dot, if there is a dot. 

B<ARGUMENTS:>

I<path> - Path name containing a directory, file name and optionally, 
an extension. 

B<RETURNS:>

Has both a return value and echoes a string. Check the return value through 
$? first to be sure that the echoed string was created successfully. 

0 - If succesfully parsed the file name from I<path>

1 - If failed to parse the file name from I<path>

Echoes only that portion of path that is the file name up to the last dot, 
if there is a dot. 

B<GLOBALS USED:>

L</UTILS_QLOG_DEBUG>

L</UTILS_QLOG_ERROR>

B<DEPENDENCIES:> 

Perl v5.8 or later
L<utils_qLogMsg(I<logLevel, logMsg, [logLineNo], [logFuncName]>)|/utils_qLogMsg(logLevel, logMsg, [logLineNo], [logFuncName])>

B<NOTES:> 

Meant to be called in a subscript with either backticks or $( )'s

B<BUGS:>

None

B<SEE ALSO:>

L<utils_pathWithoutExt(I<path>)|/utils_pathWithoutExt(path)>

=cut

##======================================================================================
utils_fileNameWithoutExt() 
{

    declare rval=0

    declare path="${1}"
    declare name
    declare msg 
    declare msgLevel=${UTILS_QLOG_DEBUG}

    # Needed perl's negative lookahead: (?!(?:.*/|\.))
    # to stop the backtrack at the last occurance
    # of the dot to handle cases like this: "/1.2/file-subdir1a.txt.1" 
    # This tells the regex to not backtrack to any dot that is
    # followed by zero or more characters and either another
    # dot or a slash. 

    # The alternatation immediatley after that
    # was needed to catch cases like this: "/1.2/file-subdir1a"
    # Making the dot just before the neg lookahead optional with \.?
    # stops the star before it from being greedy to begin with and
    # causes the first case to not match so that didn't work.  

    name=$(echo "${path}" | perl -lane \
        'if( m{([^/]*)\.(?!(?:.*/|\.))|([^/]*)$} ) {print $1|$2}')

    if [ $? -eq 0 ]
    then 
        msgLevel=${UTILS_QLOG_DEBUG}
        msg="Parsing with perl regex successful."
    else
        msgLevel=${UTILS_QLOG_ERROR}
        msg="Failed to parse with perl regex."
        rval=1
    fi

    utils_qLogMsg ${msgLevel} "${msg}"

    echo "${name}"    
    return ${rval}

}

##== FUNCTION ==========================================================================
: <<='cut'

=head2 B<utils_fileExt(I<path>)>

Given a path name to a file, extract and return only that portion that 
is the extension. An extenstion is defined here as that portion of the 
path that follows the last dot, if there is a dot. 

B<ARGUMENTS:>

I<path> - Path name containing a directory, file name and optionally, 
an extension. 

B<RETURNS:>

Has both a return value and echoes a string. Check the return value through 
$? first to be sure that the echoed string was created successfully. 

0 - If succesfully parsed the file extension from I<path>

1 - If failed to parse the extentsion from I<path>

Echoes only that portion of path that is the file extension, if there 
is one.

B<GLOBALS USED:>

L</UTILS_QLOG_DEBUG>

L</UTILS_QLOG_ERROR>

B<DEPENDENCIES:> 

Perl v5.8 or later
L<utils_qLogMsg(I<logLevel, logMsg, [logLineNo], [logFuncName]>)|/utils_qLogMsg(logLevel, logMsg, [logLineNo], [logFuncName])>

B<NOTES:> 

Meant to be called in a subscript with either backticks or $( )'s

B<BUGS:>

None

B<SEE ALSO:>

L<utils_pathWithoutExt(I<path>)|/utils_pathWithoutExt(path)>

=cut

##======================================================================================
utils_fileExt() 
{

    declare rval=0

    declare path="${1}"
    declare ext
    declare msgLevel=${UTILS_QLOG_DEBUG}
    declare msg

    ext=$(echo "${path}" | perl -lane \
        'if( m{\.([^./]*)(?!.*(?:/|\.))$} ) {print $1}')

    if [ $? -eq 0 ]
    then 
        msgLevel=${UTILS_QLOG_DEBUG}
        msg="Parsing with perl regex successful."
    else
        msgLevel=${UTILS_QLOG_ERROR}
        msg="Failed to parse with perl regex."
        rval=1
    fi

    utils_qLogMsg ${msgLevel} "${msg}"

    echo "${ext}"    
    return ${rval}

}

##== FUNCTION ==========================================================================
: <<='cut'

=head2 B<utils_copyFiles(I<src, dest, includes>)>

Selectively copy files from one directory to another by
passing an array of file names to include.

B<ARGUMENTS:>

I<src> - Source directory for the copy 

I<dest> - Destination directory for the copy

I<includes> - Name of an array containing the names of files to include
in the copy.

B<RETURNS:>

0 - If succesfully copied files 

1 - If failed to copy files

B<GLOBALS USED:>

L</UTILS_QLOG_DEBUG> 

B<DEPENDENCIES:> 

L<utils_dirReady(I<path>)|/utils_dirReady(path)>
L<utils_qMsgsFrom(I<funcName, flushQ>)|/utils_qMsgsFrom(funcName, flushQ)>
L<utils_qLogMsg(I<logLevel, logMsg, [logLineNo], [logFuncName]>)|/utils_qLogMsg(logLevel, logMsg, [logLineNo], [logFuncName])>
L<utils_exec(I<command, sterr_file>)|/utils_exec(command, sterr_file)>

B<NOTES:> 

None

B<BUGS:>

None

B<SEE ALSO:>

None

=cut

##======================================================================================
utils_copyFiles()
{

    declare -i rval=1
    declare src="${1}"
    declare dest="${2}"
    declare -a includes=("${!3}") # passing an array as a parameter
    declare com 

	utils_dirReady "${src}"
    rval=$?
    utils_qMsgsFrom utils_dirReady

    if [ ${rval} -eq 0 ]
	then

        utils_dirReady "${dest}"
        rval=$?
        utils_qMsgsFrom utils_dirReady

        if [ ${rval} -eq 0 ]
        then

            # get the absolute path to both src and dest dirs 
            src=$( cd ${src} ; pwd -P )
            dest=$( cd ${dest} ; pwd -P )

            utils_logMsg ${UTILS_QLOG_DEBUG} "Absolute src dir: ${src}" 
            utils_logMsg ${UTILS_QLOG_DEBUG} "Absolute dest dir: ${dest}" 

            # Using tar instead of cp to do this gives you the ability to
            # use include and exclude files if you need to in the future.
            #exeCom "cp -fpr $copyLooseFiles_SRC/* $copyLooseFiles_DEST"

            if [ "x${includes}" = "x" ] 
            then
                com="cd ${src} ; tar cf - . | (cd ${dest} ; tar xfop - )"
            else
                com="cd ${src} ; tar cf - ${includes[@]} | (cd ${dest} ; tar xfop - )"
            fi

            utils_exec "${com}"
            rval=$?
            utils_qMsgsFrom utils_exec

        fi
    fi

    return ${rval} 

}

##== FUNCTION ==========================================================================
: <<='cut'

=head2 B<utils_rotate(I<fileToRotate, max, separator>)>

A file or directory rotator. Given an existing file or directory, like 
"file.txt" for example, rename it to "file.txt.1". Also rename all 
similarly named files ("file.txt.1" becomes "file.txt.2", etc.), up to
the max number. The max + 1 file is removed.

B<ARGUMENTS:>

I<fileToRotate> - Path name containing an existing file or directory to rotate.

I<max> - Maximum number of rotated copies to create. 

I<separator> - The characters making-up the separator between the file name
and the rotation number.

B<RETURNS:>

0 - If all files / directories were succesfully rotated. 

1 - If not all files / directories were succesfully rotated. 

B<GLOBALS USED:>

L</UTILS_QLOG_ERROR>

B<DEPENDENCIES:> 

L<utils_qLogMsg(I<logLevel, logMsg, [logLineNo], [logFuncName]>)|/utils_qLogMsg(logLevel, logMsg, [logLineNo], [logFuncName])>

B<NOTES:> 

None

B<BUGS:>

None

B<SEE ALSO:>

None

=cut

##======================================================================================
utils_rotate()
{

    declare -i rval=0
    declare fileToRotate=${1}
    declare max=${2:-5}
    declare separator=${3:-.}
    declare fileNum
    declare nextFileNum
    declare thisFile
    declare nextFile
    declare errMsg

    for fileNum in $(seq ${max} -1 0)
    do
        thisFile="${fileToRotate}${separator}${fileNum}"
        nextFileNum=$(expr ${fileNum} + 1)
        nextFile="${fileToRotate}${separator}${nextFileNum}"

        case ${fileNum} in
            ${max})

                if [ -e "${thisFile}" ]
                then
                    rm -rf ${thisFile}
                    rval=$?                    
                    if [ ${rval} -ne 0 ]
                    then
                        errMsg="Failed to remove ${thisFile}"
                        utils_logMsg ${UTILS_QLOG_ERROR} "${errMsg}" 
                    fi
                fi
            ;;
            0) 
                thisFile="${fileToRotate}"
                if [ -e "${thisFile}" ]
                then
                    mv ${thisFile} ${nextFile} 
                    rval=$?                    
                    if [ ${rval} -ne 0 ]
                    then
                        errMsg="Failed to rename ${thisFile} to ${nextFile}"
                        utils_logMsg ${UTILS_QLOG_ERROR} "${errMsg}"
                    fi
                fi
            ;;
            *)          
                if [ -e "${thisFile}" ]
                then
                    mv ${thisFile} ${nextFile} 
                    rval=$?                    
                    if [ ${rval} -ne 0 ]
                    then
                        errMsg="Failed to rename ${thisFile} to ${nextFile}"
                        utils_logMsg ${UTILS_QLOG_ERROR} "${errMsg}"
                    fi
                fi
                ;;
        esac

        if [ ${rval} -ne 0 ]
        then
            break 
        fi

    done

    return ${rval}

}

##== FUNCTION ==========================================================================
: <<='cut'

=head2 B<utils_includeSource(I<file>)>

Safely source a file by first making sure it exists. Then, capture and log any
error if the source command fails.

B<ARGUMENTS:>

I<file> - Path name containing an existing file or directory to rotate.

B<RETURNS:>

0 - If successfully source I<file>. 

1 - If failed to source I<file>. 

B<GLOBALS USED:>

L</UTILS_QLOG_ERROR>

B<DEPENDENCIES:> 

L<utils_qLogMsg(I<logLevel, logMsg, [logLineNo], [logFuncName]>)|/utils_qLogMsg(logLevel, logMsg, [logLineNo], [logFuncName])>

B<NOTES:> 

None

B<BUGS:>

None

B<SEE ALSO:>

None

=cut

##======================================================================================
utils_includeSource () 
{

    declare -i rval=0
    declare file=${1}

    if [[ -z "${file}" ]]; then
        utils_logMsg ${UTILS_QLOG_ERROR} "argument 1 (file) missing."
        rval=1 # error
    fi

    if ! source "${file}" >>"${_L:-/dev/null}" 2>&1; then
        utils_logMsg ${UTILS_QLOG_ERROR} "failed to include source file '${file}'."
        #MSG=`cat ${STDERR}`
        #utils_logMsg ${UTILS_QLOG_ERROR} "${MSG}" 
        rval=1 # error
    fi

    return ${rval}

} 

##== FUNCTION ==========================================================================
: <<='cut'

=head2 B<utils_loadConfig(I<fileName>)>

An alternative to sourcing a file to include it. Use the read command to load a 
config file. The config file is expected to have name=value pairs. 

Example: If file.conf contained the following:

setting1=this
setting2=${setting1}-and-that

Then, calling this function like so:

if C<loadConfig(file.conf)> 
then
    : # success
fi

Then, a global variable named C<setting1> would be created and assigned the value 
I<this> and a global variable named C<setting2> would be created and assigned
the value I<${setting}-and-that>. Note that ${setting1} was not expanded. 

B<ARGUMENTS:>

I<fileName> - File name to read

B<RETURNS:>

0 - If I<fileName> exists and was read successfully

1 - If I<fileName> could not be read 

B<GLOBALS USED:>

None 

B<DEPENDENCIES:> 

None

B<NOTES:> 

Loading a config files through this function is more secure than sourcing 
it but it lacks parameter and command substitution, although the function could 
be enhanced to support that, of course.

Uses the bash IFS built-in to switch to  the equal sign as the internal file 
separator. This may not work on older versions of bash.

B<BUGS:>

None

B<SEE ALSO:>

None

=cut

##======================================================================================
utils_loadConfig ()
{

    declare CONFIG_FILE=${1}
    declare KEY
    declare VAL 
    declare STR

    CUR_IFS=${IFS}
    IFS="="
    while read KEY VAL
    do
        IFS=${CUR_IFS}
        eval ${KEY}=${VAL}
        IFS="="
    done < ${CONFIG_FILE}
    IFS=${CUR_IFS}

}

##== FUNCTION ==========================================================================
: <<='cut'

=head2 B<utils_true(I<expr>)>

Evaluate an expression for several equivalents of the boolean value I<true> and
return the appropriate code. All of the following expressions will evaluate
to I<true>: 1, true (all cases), on (all cases), yes (all cases). Anything else
will evaluate to I<false> This is to allow for maximum flexibility when editing /
loading a configuration file.

B<ARGUMENTS:>

I<expr> - Expression to evaluate for I<true>

B<RETURNS:>

0 - If I<expr> evaluates to I<true>

1 - If I<expr> evaluates to I<false>

B<GLOBALS USED:>

None

B<DEPENDENCIES:>

L<utils_lower(I<text>)|/utils_lower(text)>

B<NOTES:>

B<BUGS:>

None

B<SEE ALSO:>

L<utils_false(I<expr>)|/utils_false(expr)>

=cut

##======================================================================================
utils_true ()
{

    declare rval=0
    declare EXPR=${1:-0}

    EXPR=$(utils_lower ${EXPR})

    case ${EXPR} in
        1|true|on|yes) ;; 
        *) rval=1 ;;
    esac

    return ${rval}

}

##== FUNCTION ==========================================================================
: <<='cut'

=head2 B<utils_false(I<expr>)>

Evaluate an expression for several equivalents of the boolean value I<false> and
return the appropriate code. All of the following expressions will evaluate
to I<false>: 0, false (all cases), off (all cases), no (all cases). Anything else
will evaluate to I<true> This is to allow for maximum flexibility when editing / 
loading a configuration file.

B<ARGUMENTS:>

I<expr> - Expression to evaluate for I<false> 

B<RETURNS:>

0 - If I<expr> evaluates to I<false> 

1 - If I<expr> evaluates to I<true>

B<GLOBALS USED:>

None 

B<DEPENDENCIES:> 

L<utils_lower(I<text>)|/utils_lower(text)> 

B<NOTES:> 

None

B<BUGS:>

None

B<SEE ALSO:>

L<utils_true(I<expr>)|/utils_true(expr)>

=cut

##======================================================================================
utils_false ()
{

    declare rval=1
    declare EXPR=${1:-1}

    EXPR=$(utils_lower ${EXPR})

    case ${EXPR} in
        1|false|off|no) ;; 
        *) rval=0 ;;
    esac

    return ${rval}

}

##== FUNCTION ==========================================================================
: <<='cut'

=head2 B<utils_execsed(I<sed_com, sed_script, input_file[, output_file]>)>

Intended to be called from either 
L<utils_runsed(I<sed_script, input_file[, output_file]>)
|/utils_runsed(sed_script, input_file[, output_file])>
 or 
L<utils_gensed(I<sed_script, input_file[, output_file]>)
|/utils_gensed(sed_script, input_file[, output_file])>
 to control usage of the -n option. 
Run a sed script on an input file and either send the output to stdout
or create a new file from the output. May also be used on systems where the -i 
(in-place edit) option is not available or you would just prefer to mimic -i 
more defensively and get better error handling.  

B<Example #1:>

C<utils_execsed "sed " "s/REPLACE/WITH/g" infile.txt infile.txt> 

Executes sed without -n option, using "s/REPLACE/WITH/g" as the sed script, 
infile.txt as the input file and send the output to infile.txt, updating it. 

B<Example #2:>

C<utils_execsed "sed -n" execsed.sed infile.txt outfile.txt> 

Executes sed with the -n option, using execsed.sed as the external sed script, 
infile.txt as the input file and sends the output to outfile.txt 

B<Example #3:>

C<execsed "sed " execsed.sed infile.txt infile.txt>

Executes sed without the -n option, using execsed.sed as the external sed script, 
infile.txt as the input file and overwrites infile.txt with the output,

B<Example #4:>

C<execsed "sed " execsed.sed infile.txt> 

Executes sed without the -n option, using execsed.sed as the external sed script, 
infile.txt as the input file and sends the output to stdout.

B<ARGUMENTS:>

I<sed_com> - Quoted sed command with or without '-n' option

I<sed_script> - sed script to run -- external script or string 

I<input_file> - Input file 

I<output_file> - Optional output file. May be either blank to send the  
output to stdout or the same as I<input_file> to mimic the GNU sed '-i' in-place 
edit option. 

B<RETURNS:>

0 - If successfully executed a sed command or script, an output file 
was created and it is different from the input file -- determined by "cmp -s"

1 - If it was not not possible to create a new, different output file
from the arguments passed. 

B<GLOBALS USED:>

L</UTILS_QLOG_DEBUG>

L</UTILS_QLOG_ERROR>

B<DEPENDENCIES:> 

L<utils_qLogMsg(I<logLevel, logMsg, [logLineNo], [logFuncName]>)|/utils_qLogMsg(logLevel, logMsg, [logLineNo], [logFuncName])> 

B<NOTES:> 

This is an adaptation of I<runsed.sh> from I<sed & awk, Second Edition
by Dale Dougherty and Arnold Robbins, O'Reilly>.

B<BUGS:>

None

B<SEE ALSO:>

L<utils_runsed(I<sed_script, input_file[, output_file]>)
|/utils_runsed(sed_script, input_file[, output_file])>,  
L<utils_gensed(I<sed_script, input_file[, output_file]>)
|/utils_gensed(sed_script, input_file[, output_file])> 

=cut

##======================================================================================
utils_execsed()
{

    # Initialize stdout_only switch 
    # If the 4th argument is blank, 
    # then just send the output to stdout 
    declare stdout_only=""

    declare sed_com="${1}"
    declare sed_script="${2}"
    declare input_file="${3}"
    declare output_file="${4}"

    declare tmperr=/tmp/RUNSEDe${$}
    declare tmpout=/tmp/RUNSEDo${$}
    declare errmsg=""
    declare -i rval=1
    declare debug=""

    # make sure a sed "script" was passed
    if [ "x${errmsg}" = "x" -a "x${sed_script}" = "x" ]
    then
        errmsg="No sed script passed to execute"
    fi

    if [ "x${errmsg}" = "x" -a -f "${sed_script}" ]
    then
        # there is a file named after the argument passed-in
        # for sed_script so assume that is the external 
        # sed script to run against the input file 
        sed_com="$sed_com -f "
    else
        # assume that sed_script IS the 
        # script and execute it in-line 
        :
    fi

    # input file tests
    if [ "x${errmsg}" = "x" -a "x${input_file}" = "x" ]
    then
        errmsg="No file passed to run sed on"
    fi

    if [ "x${errmsg}" = "x" -a ! -f "$input_file" ]
    then
        errmsg="$input_file is not a file"
    fi

    if [ "x${errmsg}" = "x" -a ! -s "$input_file" ]
    then
        errmsg="$input_file is empty"
    fi

    if [ "x${errmsg}" = "x" -a "x${output_file}" = "x" ]
    then
        # No output file was passed so we'll send the output to stdout 
        stdout_only="true"
    else
        if [ -f $output_file -a ! -w $output_file ]
        then
            errmsg="$output_file is not writeable" 
        fi
    fi

    if [ "x${debug}" = "x" ]
    then
        :
    else
        utils_logMsg ${UTILS_QLOG_DEBUG} "sed_com=$sed_com"
        utils_logMsg ${UTILS_QLOG_DEBUG} "sed_script=$sed_script"
        utils_logMsg ${UTILS_QLOG_DEBUG} "input_file=$input_file"
        utils_logMsg ${UTILS_QLOG_DEBUG} "output_file=$output_file"
    fi

    if [ "x${errmsg}" = "x" ]
    then
        # if here, go ahead and run sed
        # use cat to create / overwrite
        # to preserve permissions
        ${sed_com} "${sed_script}" "${input_file}" >${tmpout} 2>${tmperr}

        if [ $? -ne 0 -o -s ${tmperr} ]
        then
            echo -e "${sed_com} ${sed_script} ${input_file} bombed!?!" >> $tmperr

            errmsg=$(cat $tmperr)

            # Escape any internal quoting chars with  a \ using perl
            # because it's just too ugly with sed.
            # Backquote can be literal but the single-quote
            # needs to be specified with the octal code \047
            # because bash can't interpret it as a literal
            errmsg=$(echo "${errmsg}" \
                | perl -lane 's|`([^\047`]+)[\047`]|[\1]|g;print')
            #errmsg="sed bombed -- check $tmperr"

        else
            if [ ! -s $tmpout ]
            then
                errmsg="sed produced an empty file"
            else

                if cmp -s "$input_file" $tmpout
                then
                    errmsg="${input_file} and ${output_file} are identical"
                    # special return value for a noop 
                    rval=2 
                else
                    if [ "x$stdout_only" = "x" ]
                    then
                        # use cat to create / overwrite
                        # to preserve permissions
                        if /bin/cat $tmpout > $output_file
                        then
                            rval=0
                        else
                            errmsg="problem creating $output_file from $tmpout?"
                        fi # /bin/cat $tmpout > $output_file
                    else
                        # just send the output to stdout
                        /bin/cat $tmpout                        
                        rval=0
                    fi # [ "x$STDOUT_ONLY" = "x" ]
                fi # cmp -s "$input_file" $tmpout
            fi # [ -s $tmpout ]
        fi # [ $? -ne 0 -o -s $tmperr ]
    fi # [ "x${errmsg}" = "x" ]

    #rm -f $tmpout
    #rm -f $tmperr

    #if [ "x${errmsg}" = "x" ]
    if [ ${rval} -eq 0 ]
    then
        : # success
    else
        #echo "errmsg=$errmsg"
        utils_logMsg ${UTILS_QLOG_ERROR} "${errmsg}"
    fi

    return $rval

}

##== FUNCTION ==========================================================================
: <<='cut'

=head2 B<utils_runsed(I<sed_script, input_file[, output_file]>)>

Convienence function for making the following call: 
C<utils_execsed("sed", sed_script, input_file[, output_file]>)> 
This is the function you would call to use I<utils_execsed> fucntion to use sed 
to transform a file.

B<ARGUMENTS:>

I<sed_script> - sed script to run -- external script or string 

I<input_file> - Input file 

I<output_file> - Optional output file. May be either blank to send the  
output to stdout or the same as I<input_file> to mimic the GNU sed '-i' in-place 
edit option. 

B<RETURNS:>

0 - If successfully executed a sed command or script, an output file 
was created and it is different from the input file -- determined by "cmp -s"

1 - If it was not not possible to create a new, different output file
from the arguments passed. 

B<GLOBALS USED:>

None 

B<DEPENDENCIES:> 

L<utils_execsed(I<sed_com, sed_script, input_file[, output_file]>)
|/utils_execsed(sed_com, sed_script, input_file[, output_file])>

B<NOTES:> 

None

B<BUGS:>

None

B<SEE ALSO:>

L<utils_gensed(I<sed_script, input_file[, output_file]>)
|/utils_gensed(sed_script, input_file[, output_file])> 

=cut

##======================================================================================
function utils_runsed() 
{

    utils_execsed "sed " "$@"
}

##== FUNCTION ==========================================================================
: <<='cut'

=head2 B<utils_gensed(I<sed_script, input_file[, output_file]>)>

Convienence function for making the following call: 
C<utils_execsed("sed -n", sed_script, input_file[, output_file]>)> 
This is the function you would call to use I<utils_execsed> fucntion to use sed 
to create a file fomr an existing file.

B<ARGUMENTS:>

I<sed_script> - sed script to run -- external script or string 

I<input_file> - Input file 

I<output_file> - Optional output file. May be either blank to send the  
output to stdout or the same as I<input_file> to mimic the GNU sed '-i' in-place 
edit option. 

B<RETURNS:>

0 - If successfully executed a sed command or script, an output file 
was created and it is different from the input file -- determined by "cmp -s"

1 - If it was not not possible to create a new, different output file
from the arguments passed. 

B<GLOBALS USED:>

None 

B<DEPENDENCIES:> 

L<utils_execsed(I<sed_com, sed_script, input_file[, output_file]>)
|/utils_execsed(sed_com, sed_script, input_file[, output_file])>

B<NOTES:> 

None

B<BUGS:>

None

B<SEE ALSO:>

L<utils_runsed(I<sed_script, input_file[, output_file]>)
|/utils_runsed(sed_script, input_file[, output_file])> 

=cut

##======================================================================================
function utils_gensed() 
{

    utils_execsed "sed -n" $*
}

##== FUNCTION ==========================================================================
: <<='cut'

=head2 B<__utils_versionWalk(I<rv, tv, ndx>)>

This function is not intended to be called directly. It is used by 
L<utils_versionSupported(I<fullRequiresV, fullTestV>)|/utils_versionSupported(fullRequiresV, fullTestV)> 
to recursively "walk" two version arrays of potentially varying size
and determine if one (tv) is "less" than the other (rv). For example, 
given two arrays defined like so:

I<tv[0]=1 tv[1]=0 tv[2]=1> 
I<rv[0]=1 rv[1]=2> 

The function would determine that the entire I<tv> array is less than
the I<rv> array by virtue of the second element of I<tv> being less than 
the second element of I<rv>.

B<ARGUMENTS:>

This function uses a novel technique to simulate taking two arrays of 
indeterminent size passed by value. To use it, do not attempt to pass
them by value by dereferencing them but simply pass it the names of 
the arrays followed by [@] like soL

C<__utils_versionWalk tv[@] rv[@] 0>

I<tv> - Name of the test version array. It's the version that you are
interested in testing. This should be an array of integers with any 
number of elements. 

I<rv> - Name of the required version array. It's the version that you
want to compare I<tv> to. Like I<tv>, it should be an array of integers
with any number of elements.

I<ndx> - The current element in the tv array being tested. Always pass
0 and let subsequent recursive calls manage this.

B<RETURNS:>

0 - If the I<tv> array is determined to be "less" than the I<rv>
array. 

1 - If the I<tv> array is determined to not be "less" than the I<rv> 
array.

B<GLOBALS USED:>

None 

B<DEPENDENCIES:> 

None

B<NOTES:> 

None

B<BUGS:>

None

B<SEE ALSO:>

L<utils_versionSupported(I<fullRequiresV, fullTestV>)
|/utils_versionSupported(fullRequiresV, fullTestV)>,  

=cut

##======================================================================================
__utils_versionWalk()
{

    declare -i rval=0
    declare -a rv=("${!1}") # passing an array as a parameter
    declare -a tv=("${!2}") # passing an array as a parameter
    declare -i numTv
    declare -i ndx=${3}

    numTv=$(expr ${#tv[@]} - 1 )

    if [ $ndx -le ${numTv} ]
    then 
        if [ -n "${tv[${ndx}]}" ]
        then
            rval=1
            if [ -n "${rv[${ndx}]}" ]
            then
                if [ "${tv[${ndx}]}" -lt "${rv[${ndx}]}" ]
                then
                    rval=0
                else
                    if [ "${tv[${ndx}]}" -eq "${rv[${ndx}]}" ]
                    then
                        ndx=$(expr ${ndx} + 1)
                        __utils_versionWalk rv[@] tv[@] ${ndx} 
                        rval=$?
                    else
                        : # it's >  
                    fi # -eq
                fi # -lt
            fi #  -n "${rv[${ndx}]}"
        fi # -n "${tv[${ndx}]}"
    fi # [ $ndx -le ${numTv} ]

    return ${rval}

}

##== FUNCTION ==========================================================================
: <<='cut'

=head2 B<utils_versionSupported(I<fullRequiresV, fullTestV>)>

Compare two version string of potentially varying size and determine 
if one (I<fullTestV>) is "less" than the other (I<fullRequiresV>). 
For example, given two strings defined like so:

fullTestV=1.0.1
fullRequiresV=1.2

The function would determine that I<fullTestV> is less than 
 I<fullRequiresV>. 

B<ARGUMENTS:>

I<fullRequiresV> - Name of the required version string. It's the version that you
want to compare I<fullTestV> to.

I<fullTestV> - Name of the test version string. It's the version that you are
interested in testing.

B<RETURNS:>

0 - If the I<fullTestV> string is determined to be "less" than the I<fullTestV>
string. 

1 - If the I<fullTestV> array is determined to not be "less" than the 
I<fullRequiresV> string.

B<GLOBALS USED:>

None 

B<DEPENDENCIES:> 

sed
L<__utils_versionWalk(I<rv, tv, ndx>)|/__utils_versionWalk(rv, tv, ndx)>  

B<NOTES:> 

None

B<BUGS:>

None

B<SEE ALSO:>

None

=cut

##======================================================================================
utils_versionSupported()
{

    declare -i rval
    declare fullRequiresV="${1}"
    declare fullTestV="${2}"
    declare curIFS=${IFS}
    declare parsingIFS="."
    declare -i numRv
    declare -i ndx

    # IFS technique doesn't work on older versions of bash 3
    #curIFX=${IFS}
    #IFS="${parsingIFS}"

    # So use sed to replace the dots with spaces 
    fullRequiresV=$(echo ${fullRequiresV} | sed 's/\./ /g')
    fullTestV=$(echo ${fullTestV} | sed 's/\./ /g')

    # Now declare the arrays and split them 
    declare -a rv=(${fullRequiresV})
    declare -a tv=(${fullTestV})

    #IFS=${curIFS}

    __utils_versionWalk rv[@] tv[@] 0 
    rval=$?

    return ${rval} 

}
