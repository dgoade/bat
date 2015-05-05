#!/bin/bash

get_options()
{    

    declare -i rval=0

    # Technique to pass an array as an argunent
    # http://tinyurl.com/7ut67cl
    declare -a opt_array=("${!1}")  # note the '!' syntax

    # The ndx of the option element. If it starts with a '-',
    # then value of the element immediately following it will 
    # be assigned to the global variable.
    declare -i ndx=${2}      

    # The name of the global variable to assign the value to.
    declare setting=${3}

    declare -i num_args
    declare -i next_ndx
    declare next_arg

    let "num_args=${#opt_array[@]}-1"

    # Make sure there is at least one more element in the array
    # than the one that we are testing for a preceding '-'
    if [ ${num_args} -gt ${ndx} ]
    then
        if [ ${opt_array[$ndx]:0:1} = "-" ]
        then
            let "next_ndx=${ndx}+1"
            next_arg=${opt_array[${next_ndx}]}
            # substring pattern-matching to get the 1st char
            if [ ${next_arg:0:1} = "-" ]
            then
                : # don't treat this as an option 
                #echo "skipping ${opt_array[${ndx}]}"
            else
                # Technique to assign a string to a global
                # variable by using the *name* of the var, 
                # which was passed as a parameter and then 
                # using eval to assign a value to it.
                # This kind of mimics symbolic references. 
                # http://tinyurl.com/ofl4qc8
                eval "${setting}=${next_arg}"
                rval=1
            fi
        else
            : # don't treat this as an option 
            #echo "skipping ${opt_array[${ndx}]}"
        fi
    fi

    return ${rval}

}

parse_args()
{

    declare -i rval=0
    declare -a opt_array=(${@})
    declare -a pos_array
    declare -i ndx=0
    declare -i skip_arg=0
    declare -i has_opts=0
    declare -i in_opts=0
    declare -i end_opts=0
    declare -i num_args=0
    declare arg
    declare errMsg

    let "num_args=${#opt_array[@]}-1"
    #echo "Number of args: $(expr ${num_args} + 1)"

    for ndx in $(seq 0 ${num_args})
    do

        if [ ${skip_arg} -eq 1 ]
        then
            skip_arg=0
        else
            arg=${opt_array[${ndx}]}
            #echo "arg #${ndx} = ${arg}"

            if [ ${arg:0:1} = "-" ]
            then
                if [ ${end_opts} -eq 1 ]
                then
                    echo "No options allowed after --"
                    in_opts=0
                    rval=1
                else
                    in_opts=1
                    has_opts=1
                fi
            else
                in_opts=0
            fi

            if [ ${rval} -eq 0 ]
            then
                if [ ${in_opts} -eq 0 ]
                then
                    if [ ${has_opts} -eq 1 ]
                    then
                        if [ ${end_opts} -eq 1 ]
                        then
                            : 
                            # this arg is not preceded with a '-' but the arg
                            # before it was '--',  which means this and all 
                            # following args will be parsed positionally
                        else
                            errMsg="Positional args must follow '--'" 
                            errMsg="${errMsg} when options are included."
                            echo ${errMsg}
                            rval=1
                        fi
                    else
                        : # there were not any '-' options on the command line
                    fi
                    if [ ${rval} -eq 0 ]
                    then
                        # start collecting positional args
                        pos_array+=(${arg})
                    fi
                else
                    case "${arg}" in
                        --) 
                            end_opts=1
                        ;;
                        -a|--action) 
                            get_options opt_array[@] ${ndx} ACTION
                            skip_arg=${?}
                        ;;
                        -h|--help) 
                            HELP=1
                        ;;
                        -l|--loglevel) 
                            get_options opt_array[@] ${ndx} LOG_LEVEL
                            skip_arg=${?}
                        ;;
                        -n|--noop) 
                            NO_OP=1
                        ;;
                        -v|--verbose) 
                            VERBOSE=1
                        ;;
                        *) 
                            echo "Invalid option: ${arg}"
                            rval=1
                        ;;
                    esac
                fi # [ ${in_opts} -eq 0 ]
            fi # [ ${rval} -eq 0 ]
        fi # [ ${skip_arg} -eq 1 ]
    done

    # Now, we assign any positional args
    let "num_args=${#pos_array[@]}-1"
    #echo "Number of positional args: ${num_args}"
    if [ ${num_args} -ge 0 ]
    then
        for ndx in $(seq 0 ${num_args})
        do
            case "${ndx}" in
                0) 
                    if [ "x${ACTION}" = "x" ]
                    then
                        ACTION="${pos_array[${ndx}]}"
                    fi
                ;;
                1) 
                    if [ "x${VERBOSE}" = "x" ]
                    then
                        VERBOSE="${pos_array[${ndx}]}"
                    fi
                ;;
                *) 
                    errMsg="Too many positional args#${ndx}:"
                    errMsg="${errMsg} ${pos_array[${ndx}]}"
                    echo "${errMsg}"
                    rval=1
                ;;
            esac
        done
    fi

    return ${rval}

}

DEBUG=0
if [ ${DEBUG} -eq 1 ]
then
    parse_args $@
    rval=${?}

    if [ ${rval} -eq 0 ]
    then 
        echo "Arguments parsed successfully"
    else
        echo "Failed to parse arguments"
    fi
    echo "ACTION=${ACTION}"
    echo "HELP=${HELP}"
    echo "LOG_LEVEL=${LOG_LEVEL}"
    echo "NO_OP=${NO_OP}"
    echo "VERBOSE=${VERBOSE}"
fi
