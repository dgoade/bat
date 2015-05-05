#!/bin/bash
#
# Author: david.goade@ntrepidcorp.com (David Goade) 
#
# Test the parse_args library 
#-----------------------------------------------------------------------------
# suite tests
#

#--- get_options test (round 1): options, short and long and mixed
test_get_options_1 ()
{

    declare -i rval=0
    declare -a opt_array
    declare -a assert_array
   
    assert_array=("start" "" "" "3" "" "")
    if [ ${rval} -eq 0 ]
    then
        rval=${?}
    fi

    unset opt_array
    opt_array=(-a start -x -l 3 -v -n)
    _test_get_options opt_array[@] assert_array[@]
    if [ ${rval} -eq 0 ]
    then
        rval=${?}
    fi

    unset opt_array
    opt_array=(--action start --xfactor --loglevel 3 -verbose --noop)
    _test_get_options opt_array[@] assert_array[@]
    if [ ${rval} -eq 0 ]
    then
        rval=${?}
    fi

    unset opt_array
    opt_array=(-a start --x -l 3 -verbose -n)
    _test_get_options opt_array[@] assert_array[@]
    if [ ${rval} -eq 0 ]
    then
        rval=${?}
    fi

    unset opt_array
    opt_array=(-a start --x -l 3 -verbose -n)
    _test_get_options opt_array[@] assert_array[@]
    if [ ${rval} -eq 0 ]
    then
        rval=${?}
    fi

    return ${rval}

}

#--- get_options test (round 2): options preceded by a positional arg
test_get_options_2 ()
{

    declare -i rval=0
    declare -a opt_array
    declare -a assert_array

    assert_array=("" "" "3" "" "" "")
    if [ ${rval} -eq 0 ]
    then
        rval=${?}
    fi

    unset opt_array
    opt_array=(start -x -l 3 -v -n)
    _test_get_options opt_array[@] assert_array[@]
    if [ ${rval} -eq 0 ]
    then
        rval=${?}
    fi

    unset opt_array
    opt_array=(stop --xfactor --loglevel 3 -verbose --noop)
    _test_get_options opt_array[@] assert_array[@]
    if [ ${rval} -eq 0 ]
    then
        rval=${?}
    fi

    unset opt_array
    opt_array=(status --x -l 3 -verbose -n)
    _test_get_options opt_array[@] assert_array[@]
    if [ ${rval} -eq 0 ]
    then
        rval=${?}
    fi

    unset opt_array
    opt_array=(restart --x -l 3 -verbose -n)
    _test_get_options opt_array[@] assert_array[@]
    if [ ${rval} -eq 0 ]
    then
        rval=${?}
    fi

    return ${rval}

}

#--- get_options test (round 3): two positional args before the options
test_get_options_3 ()
{

    declare -i rval=0
    declare -a opt_array
    declare -a assert_array

    assert_array=("" "" "" "3" "" "")
    if [ ${rval} -eq 0 ]
    then
        rval=${?}
    fi

    unset opt_array
    opt_array=(start true -x -l 3 -v -n)
    _test_get_options opt_array[@] assert_array[@]
    if [ ${rval} -eq 0 ]
    then
        rval=${?}
    fi

    unset opt_array
    opt_array=(stop false --xfactor --loglevel 3 -verbose --noop)
    _test_get_options opt_array[@] assert_array[@]
    if [ ${rval} -eq 0 ]
    then
        rval=${?}
    fi

    unset opt_array
    opt_array=(status true --x -l 3 -verbose -n)
    _test_get_options opt_array[@] assert_array[@]
    if [ ${rval} -eq 0 ]
    then
        rval=${?}
    fi

    unset opt_array
    opt_array=(restart false --x -l 3 -verbose -n)
    _test_get_options opt_array[@] assert_array[@]
    if [ ${rval} -eq 0 ]
    then
        rval=${?}
    fi

    return ${rval}

} 

#--- get_options test (round 4): dash-dash option, followed by positional arg
test_get_options_4 ()
{

    declare -i rval=0
    declare -a opt_array
    declare -a assert_array

    assert_array=("" "3" "" "")

    unset opt_array
    opt_array=(-x -l 3 -v -n --)
    _test_get_options opt_array[@] assert_array[@]
    if [ ${rval} -eq 0 ]
    then
        rval=${?}
    fi

    unset opt_array
    opt_array=(--xfactor --loglevel 3 -verbose --noop -- start)
    _test_get_options opt_array[@] assert_array[@]
    if [ ${rval} -eq 0 ]
    then
        rval=${?}
    fi

    unset opt_array
    opt_array=(--x -l 3 -verbose -n -- start true)
    _test_get_options opt_array[@] assert_array[@]
    if [ ${rval} -eq 0 ]
    then
        rval=${?}
    fi

    unset opt_array
    opt_array=(--x -l 3 -verbose -n -- start true 9)
    _test_get_options opt_array[@] assert_array[@]
    if [ ${rval} -eq 0 ]
    then
        rval=${?}
    fi

    return ${rval}

} 


#--- get_options test function: loops through the assert array,
#    calls the the get_options function and does the assert for
#    each setting
_test_get_options ()
{

    declare -i rval=0
    declare -i ndx
    declare msg

    declare -a opt_array=("${!1}")  # note the '!' syntax -- passing array as arg
    declare -a assert_array=("${!2}")

    let "num_asserts=${#assert_array[@]}-1"
    for ndx in $(seq 0 ${num_asserts})
    do
        get_options opt_array[@] ${ndx} SETTING
        msg="Parsing value for option# ${ndx} from options '${opt_array[*]}':"
        assertSame "${msg}" "${assert_array[${ndx}]}" "${SETTING}"
        rval=${?}
        unset SETTING
    done

    return ${rval}

} 

#--- parse_args test (round 1): short options
test_parse_args_1 ()
{

    declare -i rval=0
    declare msg

    declare -a opt_array

    opt_array=(-a start -h -l 3 -n -v)
    _test_parse_args opt_array[@]
    if [ ${rval} -eq 0 ]
    then
        rval=${?}
    fi

    return ${rval}

}

#--- parse_args test (round 2): long options
test_parse_args_2 ()
{

    declare -i rval=0
    declare msg

    declare -a opt_array

    opt_array=(--action start --help --loglevel 3 --noop --verbose)
    _test_parse_args opt_array[@]
    if [ ${rval} -eq 0 ]
    then
        rval=${?}
    fi

    return ${rval}
}

#--- parse_args test (round 3): mixed options
test_parse_args_3 ()
{

    declare -i rval=0
    declare msg

    declare -a opt_array

    opt_array=(--action start -h --loglevel 3 -n --verbose)
    _test_parse_args opt_array[@]
    if [ ${rval} -eq 0 ]
    then
        rval=${?}
    fi

    return ${rval}
}

#--- parse_args test (round 4): a positional arg followed by options
test_parse_args_4 ()
{

    declare -i rval=0
    declare msg

    declare -a opt_array

    opt_array=(stop --action start -h --loglevel 3 -n --verbose)
    _test_parse_args opt_array[@]
    if [ ${rval} -eq 0 ]
    then
        rval=${?}
    fi

    return ${rval}
}

#--- parse_args test (round 5): positional args followed by options
test_parse_args_5 ()
{

    declare -i rval=0
    declare msg

    declare -a opt_array

    opt_array=(stop true --action start -h --loglevel 3 -n --verbose)
    _test_parse_args opt_array[@]
    if [ ${rval} -eq 0 ]
    then
        rval=${?}
    fi

    return ${rval}
}

#--- parse_args test (round 6): options, followed by dash-dash 
#    and a positional arg
test_parse_args_6 ()
{

    declare -i rval=0
    declare msg

    declare -a opt_array

    opt_array=(-h --loglevel 3 -n --verbose -- start)
    _test_parse_args opt_array[@]
    if [ ${rval} -eq 0 ]
    then
        rval=${?}
    fi

    return ${rval}
}

#--- parse_args test (round 7): options, followed by dash-dash 
#    and positional args
test_parse_args_6 ()
{

    declare -i rval=0
    declare msg

    declare -a opt_array

    opt_array=(-h --loglevel 3 -n --verbose -- start 1)
    _test_parse_args opt_array[@]
    if [ ${rval} -eq 0 ]
    then
        rval=${?}
    fi

    return ${rval}
}

_test_parse_args ()
{

    declare -i rval=0
    declare -i ndx
    declare msg

    declare -a opt_array=("${!1}")  # note the '!' syntax -- passing array as arg

    parse_args ${opt_array[@]}

    msg="After parsing value for -a"
    assertSame "${msg}" "start" "${ACTION}"
    if [ ${rval} -eq 0 ]
    then
        rval=${?}
    fi

    msg="After parsing value for -h"
    assertSame "${msg}" "1" "${HELP}"
    if [ ${rval} -eq 0 ]
    then
        rval=${?}
    fi

    msg="After parsing value for -l"
    assertSame "${msg}" "3" "${LOG_LEVEL}"
    if [ ${rval} -eq 0 ]
    then
        rval=${?}
    fi

    msg="After parsing value for -n"
    assertSame "${msg}" "1" "${NO_OP}"
    if [ ${rval} -eq 0 ]
    then
        rval=${?}
    fi

    msg="After parsing value for -v"
    assertSame "${msg}" "1" "${VERBOSE}"
    if [ ${rval} -eq 0 ]
    then
        rval=${?}
    fi

    return ${rval}
}


#-----------------------------------------------------------------------------
# suite functions
#

oneTimeSetUp()
{

    test_parse_args_BASE_NAME=$(basename $0)
    test_parse_args_BASE_DIR=$( cd $(dirname ${test_parse_args_BASE_NAME}) ; pwd -P )

}

setUp ()
{
    :
}
tearDown()
{
    :
}

TEST_BASE_DIR=$( cd $(dirname ${BASH_SOURCE}) ; pwd -P )

# Use this technique to clear-out the positional args after 
# loading them because shunit2 has a strange error whenever 
# it is sourced when there is a residual arg. 
if [ "x${1}" = "x" ]
then
    SHUNIT2_HOME="${TEST_BASE_DIR}/../../shunit2"
else
    SHUNIT2_HOME="${1}"
    shift
fi

if [ "x${1}" = "x" ]
then
    test_SUBJECT_BASE_NAME="${TEST_BASE_DIR}/../../lib/$(basename $0)"
else
    test_SUBJECT_BASE_NAME="${1}"
    shift
fi

test_SUBJECT_BASE_DIR=$( cd $(dirname ${test_SUBJECT_BASE_NAME}) ; pwd -P )
source ${test_SUBJECT_BASE_NAME}

# load and run shUnit2
[ -n "${ZSH_VERSION:-}" ] && SHUNIT_PARENT=${0}

source "${SHUNIT2_HOME}/src/shunit2"

#test_get_options
