#!/bin/bash
#
# Author: kate.ward@forestent.com (Kate Ward)
#
# Example unit test for the mkdir command.
#
# There are times when an existing shell script needs to be tested. In this
# example, we will test several aspects of the the mkdir command, but the
# techniques could be used for any existing shell script.

#-----------------------------------------------------------------------------
# suite tests
#
test_utils_qLogMsg ()
{

    level_test_utils_qLogMsg "0"
    level_test_utils_qLogMsg "1"
    level_test_utils_qLogMsg "2"
    level_test_utils_qLogMsg "3"
    level_test_utils_qLogMsg "4"
    level_test_utils_qLogMsg "5"

}

level_test_utils_qLogMsg ()
{

    utils_qLogMsg "0" "This is a debug level test message that was queued by test_utils_qLogMsg"
    utils_qLogMsg "1" "This is an info level test message that was queued by test_utils_qLogMsg"
    utils_qLogMsg "2" "This is a warn level test message that was queued by test_utils_qLogMsg"
    utils_qLogMsg "3" "This is a error level test message that was queued by test_utils_qLogMsg"
    utils_qLogMsg "4" "This is a critical level test message that was queued by test_utils_qLogMsg"
    utils_qLogMsg "5" "This is a fatal level test message that was queued by test_utils_qLogMsg"

    LOGGER_LOG_LEVEL=${1}
    logger_logQ "level_test_utils_qLogMsg"

}

#-----------------------------------------------------------------------------
# suite functions
#

th_assertTrueWithNoOutput()
{
  th_return_=$1
  th_stdout_=$2
  th_stderr_=$3

  assertFalse 'unexpected output to STDOUT' "[ -s '${th_stdout_}' ]"
  assertFalse 'unexpected output to STDERR' "[ -s '${th_stderr_}' ]"

  unset th_return_ th_stdout_ th_stderr_
}

oneTimeSetUp()
{

#  outputDir="${SHUNIT_TMPDIR}/output"
#  mkdir "${outputDir}"
#  stdoutF="${outputDir}/stdout"
#  stderrF="${outputDir}/stderr"

#  mkdirCmd='mkdir'  # save command name in variable to make future changes easy
#  testDir="${SHUNIT_TMPDIR}/some_test_dir"
    :
}

setUp()
{
    #echo "Executing setUp"
    #LOGGER_LOG_LEVEL=0
    #export LOGGER_LIB_DIR=""
    :
}

tearDown()
{
#  rm -fr "${testDir}"
    :
}

LOGGER_LIB_DIR="../../lib"
#source ../../lib/utils.sh
#source ../../lib/log4bash.sh
source ../../lib/logger.sh

# load and run shUnit2
[ -n "${ZSH_VERSION:-}" ] && SHUNIT_PARENT=$0
#. ../shunit2-2.1.6/src/shunit2
. /bin/shunit/shunit2

