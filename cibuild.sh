#!/bin/bash

SHUNIT2_HOME=${1}
FAILURES=0

run_shunit_tests()
{

    declare -i rval=0

    return ${rval}
}


run_shunit2_tests()
{

    declare -i rval=0
    declare -i failures=0
    curDir=$( cd $(dirname ${0}) ; pwd -P )
    for file in $(find test -name "*.sh")
    do
        testScriptDir=$( cd $(dirname ${file}) ; pwd -P )
        testScript=$(basename ${file})
        cd ${testScriptDir}
        ./${testScript} ${SHUNIT_HOME}
        test_suite_result=${?}
        #echo "test_suite_result=${test_suite_result}"
        let "failures+=${test_suite_result}"
        cd ${curDir}
    done

    rval=${failures}

    return ${rval}

}

run_tests()
{
    declare -i rval=0

    run_shunit_tests
    shunit_failres=${?}
    echo "shunit failures=${rval}"

    run_shunit2_tests
    shunit2_failures=${?}
    echo "shunit2 failures=${rval}"

    let "rval=${shunit_failres}+${shunit2_failures}"

    return ${rval}

}

run_tests
FAILURES=${?}
echo "Test suites with failures=${FAILURES}"
exit ${FAILURES}
