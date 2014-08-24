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

test_utils_versionSupported()
{

    declare rv
    declare -a v
    declare -i ndx

    rv="1.1"

    v[0]=""
    v[1]="0"
    v[2]="0."
    v[3]="0.0"
    v[4]="0.1"
    v[5]="0.1.1"
    v[6]="1.0"
    v[7]="1.1"
    v[8]="1.1."

    numV=$(expr ${#v[@]} - 1 )
    for ndx in $(seq 0 ${numV} ) 
    do
        utils_versionSupported "${rv}" "${v[${ndx}]}"
        rval=$?
        assertTrue "For test case# ${ndx}: '${rv}' and '${v[${ndx}]}'" "${rval}"
    done

    unset v

    v[0]="1.1.1"
    v[1]="1.1.1.0"
    v[2]="1.2"
    v[3]="99.0.0.9"

    numV=$(expr ${#v[@]} - 1 )
    for ndx in $(seq 0 ${numV} ) 
    do
        utils_versionSupported "${rv}" "${v[${ndx}]}"
        rval=$? 
        assertFalse "For test case# ${ndx}: '${rv}' and '${v[${ndx}]}'" "${rval}"
    done


}


test_utils_fileExt()
{

    declare rval
    #declare -a nameExt
    declare -a name

    declare -i num_nameExt
    declare -i ndx

    # For both parameters

    name[0]=""

    name[1]=""
    name[2]=""
    name[3]="txt"

    name[4]=""
    name[5]=""
    name[6]="txt"

    name[7]=""
    name[8]=""
    name[9]="txt"

    name[10]=""
    name[11]=""
    name[12]="txt"

    name[13]=""
    name[14]=""
    name[15]="txt"

    name[16]=""
    name[17]=""
    name[18]="txt"

    name[19]="1"
    name[20]="1"
    name[21]="1"

    name[22]="1"
    name[23]="1"

    num_name=$(expr ${#name[@]} - 1 )
    for ndx in $(seq 0 ${num_name} ) 
    do
        rval=$(utils_fileExt "${nameExt[${ndx}]}")
        assertSame "For test case# ${ndx}: '${nameExt[${ndx}]}': "\
                "${name[${ndx}]}" \
                "${rval}"
    done

}

test_utils_pathWithoutExt()
{

    declare rval
    #declare -a nameExt
    declare -a name

    declare -i num_nameExt
    declare -i ndx

    name[0]=""

    name[1]="file-subdir1a"
    name[2]="file-subdir1a"
    name[3]="file-subdir1a"

    name[4]="/file-subdir1a"
    name[5]="/file-subdir1a"
    name[6]="/file-subdir1a"

    name[7]="./file-subdir1a"
    name[8]="./file-subdir1a"
    name[9]="./file-subdir1a"

    name[10]="../file-subdir1a"
    name[11]="../file-subdir1a"
    name[12]="../file-subdir1a"

    name[13]="../../file-subdir1a"
    name[14]="../../file-subdir1a"
    name[15]="../../file-subdir1a"

    name[16]="/1.2/file-subdir1a"
    name[17]="/1.2/file-subdir1a"
    name[18]="/1.2/file-subdir1a"

    name[19]="file-subdir1a.txt"
    name[20]="/file-subdir1a.txt"
    name[21]="../file-subdir1a.txt"

    name[22]="../../file-subdir1a.txt"
    name[23]="/1.2/file-subdir1a.txt"

    num_name=$(expr ${#name[@]} - 1 )
    for ndx in $(seq 0 ${num_name} ) 
    do
        rval=$(utils_pathWithoutExt "${nameExt[${ndx}]}")
        assertSame "For test case# ${ndx}: '${nameExt[${ndx}]}': "\
                "${name[${ndx}]}" \
                "${rval}"
    done

}

test_utils_fileNameWithoutExt()
{

    declare rval
    #declare -a nameExt
    declare -a name

    declare -i num_nameExt
    declare -i ndx

    # For both parameters

    name[0]=""

    name[1]="file-subdir1a"
    name[2]="file-subdir1a"
    name[3]="file-subdir1a"

    name[4]="file-subdir1a"
    name[5]="file-subdir1a"
    name[6]="file-subdir1a"

    name[7]="file-subdir1a"
    name[8]="file-subdir1a"
    name[9]="file-subdir1a"

    name[10]="file-subdir1a"
    name[11]="file-subdir1a"
    name[12]="file-subdir1a"

    name[13]="file-subdir1a"
    name[14]="file-subdir1a"
    name[15]="file-subdir1a"

    name[16]="file-subdir1a"
    name[17]="file-subdir1a"
    name[18]="file-subdir1a"

    name[19]="file-subdir1a.txt"
    name[20]="file-subdir1a.txt"
    name[21]="file-subdir1a.txt"

    name[22]="file-subdir1a.txt"
    name[23]="file-subdir1a.txt"

    num_name=$(expr ${#name[@]} - 1 )
    for ndx in $(seq 0 ${num_name} ) 
    do
        rval=$(utils_fileNameWithoutExt "${nameExt[${ndx}]}")
        assertSame "For test case# ${ndx}: '${nameExt[${ndx}]}': "\
                "${name[${ndx}]}" \
                "${rval}"
    done

     

}

test_utils_sameNameDifferentExt()
{

    declare rval
    declare -a basisName
    declare -a newExt
    declare -a newName

    declare -i num_basisName
    declare -i ndx

    # For no parameters

    newName[0]="$(dirname $0)/utils.$$"

    rval=$(utils_sameNameDifferentExt)
    assertSame "For empty parameters: "\
            "${newName[0]}" \
            "${rval}"

    # For only one parameter

    newExt[0]="new"

    newName[0]="$(dirname $0)/utils.new"

    num_newName=$(expr ${#newName[@]} - 1 )
    for ndx in $(seq 0 ${num_newName} ) 
    do
        rval=$(utils_sameNameDifferentExt "${newExt[${ndx}]}")
        assertSame "For test case #1: '${newExt[${ndx}]}': "\
                "${newName[${ndx}]}" \
                "${rval}"
    done

    unset basisName
    unset newExt
    unset newName

    # For both parameters

    basisName=("${nameExt[@]}")

    newExt[0]="new"

    newName[0]="$(dirname $0)/utils.new"

    newName[1]="file-subdir1a.new"
    newName[2]="file-subdir1a.new"
    newName[3]="file-subdir1a.new"

    newName[4]="/file-subdir1a.new"
    newName[5]="/file-subdir1a.new"
    newName[6]="/file-subdir1a.new"

    newName[7]="./file-subdir1a.new"
    newName[8]="./file-subdir1a.new"
    newName[9]="./file-subdir1a.new"

    newName[10]="../file-subdir1a.new"
    newName[11]="../file-subdir1a.new"
    newName[12]="../file-subdir1a.new"

    newName[13]="../../file-subdir1a.new"
    newName[14]="../../file-subdir1a.new"
    newName[15]="../../file-subdir1a.new"

    newName[16]="/1.2/file-subdir1a.new"
    newName[17]="/1.2/file-subdir1a.new"
    newName[18]="/1.2/file-subdir1a.new"

    newName[19]="file-subdir1a.txt.new"
    newName[20]="/file-subdir1a.txt.new"
    newName[21]="../file-subdir1a.txt.new"

    newName[22]="../../file-subdir1a.txt.new"
    newName[23]="/1.2/file-subdir1a.txt.new"

    num_newName=$(expr ${#newName[@]} - 1 )
    for ndx in $(seq 0 ${num_newName} ) 
    do
        rval=$(utils_sameNameDifferentExt "${basisName[${ndx}]}" "${newExt[0]}")
        assertSame "For test case# ${ndx}: '${basisName[${ndx}]}' and '${newExt[0]}': "\
                "${newName[${ndx}]}" \
                "${rval}"
    done

    unset basisName
    unset newExt
    unset new_name

}

test_utils_similarNameSameExt()
{

    declare rval
    declare -a basisName
    declare -a newExt
    declare -a newName

    declare -i num_basisName
    declare -i ndx

    # For no parameters

    newName[0]="$(dirname $0)/utils.$$"

    rval=$(utils_sameNameDifferentExt)
    assertSame "For empty parameters: "\
            "${newName[0]}" \
            "${rval}"

    # For only one parameter

    newExt[0]="new"

    newName[0]="$(dirname $0)/utils.new"

    num_newName=$(expr ${#newName[@]} - 1 )
    for ndx in $(seq 0 ${num_newName} ) 
    do
        rval=$(utils_sameNameDifferentExt "${newExt[${ndx}]}")
        assertSame "For test case #1: '${newExt[${ndx}]}': "\
                "${newName[${ndx}]}" \
                "${rval}"
    done

    unset basisName
    unset newExt
    unset newName

    # For both parameters

    basisName=("${nameExt[@]}")

    newExt[0]="new"

    newName[0]="$(dirname $0)/utils.new"

    newName[1]="file-subdir1a.new"
    newName[2]="file-subdir1a.new"
    newName[3]="file-subdir1a.new"

    newName[4]="/file-subdir1a.new"
    newName[5]="/file-subdir1a.new"
    newName[6]="/file-subdir1a.new"

    newName[7]="./file-subdir1a.new"
    newName[8]="./file-subdir1a.new"
    newName[9]="./file-subdir1a.new"

    newName[10]="../file-subdir1a.new"
    newName[11]="../file-subdir1a.new"
    newName[12]="../file-subdir1a.new"

    newName[13]="../../file-subdir1a.new"
    newName[14]="../../file-subdir1a.new"
    newName[15]="../../file-subdir1a.new"

    newName[16]="/1.2/file-subdir1a.new"
    newName[17]="/1.2/file-subdir1a.new"
    newName[18]="/1.2/file-subdir1a.new"

    newName[19]="file-subdir1a.txt.new"
    newName[20]="/file-subdir1a.txt.new"
    newName[21]="../file-subdir1a.txt.new"

    newName[22]="../../file-subdir1a.txt.new"
    newName[23]="/1.2/file-subdir1a.txt.new"

    num_newName=$(expr ${#newName[@]} - 1 )
    for ndx in $(seq 0 ${num_newName} ) 
    do
        rval=$(utils_sameNameDifferentExt "${basisName[${ndx}]}" "${newExt[0]}")
        assertSame "For test case# ${ndx}: '${basisName[${ndx}]}' and '${newExt[0]}': "\
                "${newName[${ndx}]}" \
                "${rval}"
    done

    unset basisName
    unset newExt
    unset new_name

}

test_utils_workFileNameSameExt()
{

    declare rval
    declare -a basisName
    declare -a workDir
    declare -a surname
    declare -a newName

    declare -i ndx

    unset basisName
    unset workDir
    unset surname
    unset newName

    basisName=("${nameExt[@]}")

    workDir[0]="${TEST_UTILS_TEST_DIR2}"

    surname[0]="-work"

    newName[0]="${TEST_UTILS_TEST_DIR2}/utils-work.sh"

    newName[1]="${TEST_UTILS_TEST_DIR2}/file-subdir1a-work"
    newName[2]="${TEST_UTILS_TEST_DIR2}/file-subdir1a-work."
    newName[3]="${TEST_UTILS_TEST_DIR2}/file-subdir1a-work.txt"

    newName[4]="${TEST_UTILS_TEST_DIR2}/file-subdir1a-work"
    newName[5]="${TEST_UTILS_TEST_DIR2}/file-subdir1a-work."
    newName[6]="${TEST_UTILS_TEST_DIR2}/file-subdir1a-work.txt"

    newName[7]="${TEST_UTILS_TEST_DIR2}/file-subdir1a-work"
    newName[8]="${TEST_UTILS_TEST_DIR2}/file-subdir1a-work."
    newName[9]="${TEST_UTILS_TEST_DIR2}/file-subdir1a-work.txt"

    newName[10]="${TEST_UTILS_TEST_DIR2}/file-subdir1a-work"
    newName[11]="${TEST_UTILS_TEST_DIR2}/file-subdir1a-work."
    newName[12]="${TEST_UTILS_TEST_DIR2}/file-subdir1a-work.txt"

    newName[13]="${TEST_UTILS_TEST_DIR2}/file-subdir1a-work"
    newName[14]="${TEST_UTILS_TEST_DIR2}/file-subdir1a-work."
    newName[15]="${TEST_UTILS_TEST_DIR2}/file-subdir1a-work.txt"

    newName[16]="${TEST_UTILS_TEST_DIR2}/file-subdir1a-work"
    newName[17]="${TEST_UTILS_TEST_DIR2}/file-subdir1a-work."
    newName[18]="${TEST_UTILS_TEST_DIR2}/file-subdir1a-work.txt"

    newName[19]="${TEST_UTILS_TEST_DIR2}/file-subdir1a.txt-work.1"
    newName[20]="${TEST_UTILS_TEST_DIR2}/file-subdir1a.txt-work.1"
    newName[21]="${TEST_UTILS_TEST_DIR2}/file-subdir1a.txt-work.1"

    newName[22]="${TEST_UTILS_TEST_DIR2}/file-subdir1a.txt-work.1"
    newName[23]="${TEST_UTILS_TEST_DIR2}/file-subdir1a.txt-work.1"

    num_newName=$(expr ${#newName[@]} - 1 )
    for ndx in $(seq 0 ${num_newName} ) 
    do

        rval=$(utils_workFileNameSameExt "${basisName[${ndx}]}" "${surname[0]}"\
            "${workDir[0]}")

        assertSame "For test case# ${ndx}: '${basisName[${ndx}]}' '${surname[0]}' '${workDir[0]}': "\
                "${newName[${ndx}]}" \
                "${rval}"

    done

    unset basisName
    unset surname
    unset newName


}

xest_utils_similarNameSameExt()
{

    declare rval
    declare -a basis_name
    declare -a surname
    declare -a new_name

    declare -i num_basis_name
    declare -i ndx

    unset basis_name
    unset surname
    unset new_name

    # For both parameters

    basis_name[0]="${TEST_UTILS_TEST_SUBDIR1a}/file-subdir1a.txt"

    surname[0]="-new"

    new_name[0]="${TEST_UTILS_TEST_SUBDIR1a}/file-subdir1a-new.txt"

    num_new_name=$(expr ${#new_name[@]} - 1 )
    for ndx in $(seq 0 ${num_new_name} ) 
    do
        rval=$(utils_similarNameSameExt "${basis_name[${ndx}]}" "${surname[${ndx}]}")
        assertSame "For test text '${basis_name[${ndx}]}' and '${surname[${ndx}]}': "\
                "${new_name[${ndx}]}" \
                "${rval}"
    done

    unset basis_name
    unset surname
    unset new_name


}

xest_utils_callStack()
{

    declare rval

    rval=$(utils_callStack)

    echo $rval

}

xest_utils_copyFiles()
{

    declare rval
    declare srcDir="${TEST_UTILS_TEST_DIR1}" 
    declare destDir="${TEST_UTILS_TEST_DIR2}" 
    declare -a includes
    declare numIncludes
    declare -i ndx

    includes[0]="subdir1/file-subdir1.txt"
    includes[1]="subdir1/subdir1a/file-subdir1a.txt"

    utils_copyFiles "${srcDir}" "${destDir}" includes[@]
    rval=$?
    if assertTrue ${rval} 
    then
        numIncludes=$(expr ${#includes[@]} - 1 )
        for ndx in $(seq 0 ${numIncludes} ) 
        do
            assertTrue "[ -f \"${TEST_UTILS_TEST_DIR2}/${includes[${ndx}]}\" ]"
        done
    fi

    return $rval    

}


xest_utils_replaceDirName()
{

    declare rval
    declare -a dir
    declare -a should 
    declare numDirs
    declare ndx

    path[0]="/replace/this/dir/with/something/file.txt"
    path[1]="/replace/this/dir/with/something/file.txt"
    path[2]="file.txt"
    path[3]="file.txt"
    path[4]="file.txt"
    path[5]="file.txt"

    dir[0]="/this/is/what/it/should/be"
    dir[1]="/this/is/what/it/should/be/"
    dir[2]="/gohere"
    dir[3]="gohere"
    dir[4]="gohere/"
    dir[5]=""

    should[0]="/this/is/what/it/should/be/file.txt"
    should[1]="/this/is/what/it/should/be/file.txt"
    should[2]="/gohere/file.txt"
    should[3]="gohere/file.txt"
    should[4]="gohere/file.txt"
    should[5]="file.txt"

    numDirs=$(expr ${#dir[@]} - 1 )
    for ndx in $(seq 0 ${numDirs} ) 
    do
        rval=$(utils_replaceDirName "${path[${ndx}]}" "${dir[${ndx}]}")
        assertSame "For test path '${path[${ndx}]}' with dir '${dir[${ndx}]}': " \
            "${should[${ndx}]}" \
            "${rval}"
    done

}

xest_utils_rotateFile()
{ 

    declare -i rval
    declare tempDir="${TEST_UTILS_TEST_DIR1}"
    declare tempFile="${tempDir}/tmpfile.txt"
    declare max=5
    declare file

    mkdir -p ${tempDir}

    for file in $(seq 1 ${max})
    do
        utils_rotate "${tempFile}" "${max}"
        touch ${tempFile}
    done


}

xest_utils_rotateDir()
{ 
    declare tempDir[0]="${TEST_UTILS_TEST_DIR1}/notadir"
    declare tempDir[1]="${TEST_UTILS_TEST_DIR1}/backup"
	declare numDirs
	declare ndx

    numDirs=$(expr ${#tempDir[@]} - 1 )
    for ndx in $(seq 0 ${numDirs} ) 
    do
			run_test_utils_rotateDir "${tempDir[${thisDir}]}"
	done

}

run_test_utils_rotateDir()
{ 

    declare -i rval
    declare tempDir="${1}"
    #declare tempDir="nodir"
    declare max=5
    declare stop=$(expr ${max} - 1)
    declare file
    declare separator="."

    for file in $(seq 1 ${max})
    do
        #echo "iteration# ${file}"
        utils_rotate "${tempDir}" "${max}"
        rval=$?
        if assertTrue ${rval}  
        then
            mkdir -p ${tempDir}
        else 
            break
        fi 
    done

    if [ ${rval} -eq 0 ]
    then
        if assertTrue "[ -d \"${tempDir}\" ]"
        then
            for file in $(seq 1 ${stop})
            do
                if assertTrue "[ -d \"${tempDir}${separator}${file}\" ]"
                then
                    : 
                else
                    rval=1
                    break
                fi
            done
        else
            rval=1
        fi
    fi

    return ${rval}

}

xest_utils_logit()
{ 

    declare global_level

    UTILS_LOGIT_DATE_FORMAT="+%Y-%m-%d %H:%M:%S"
    UTILS_LOGIT_LOG_FILE="/dev/null"

    UTILS_LOGIT_QLOGS="false"
    for global_level in {0..5} 
    do
        level_test_utils_logit "${global_level}"
    done 

}

xest_utils_qLogMsg()
{ 

    declare global_level

    UTILS_LOGIT_DATE_FORMAT="+%Y-%m-%d %H:%M:%S"
    UTILS_LOGIT_LOG_FILE="/dev/null"

    UTILS_LOGIT_QLOGS="true"
    for global_level in {0..5} 
    do
        level_test_utils_qLogMsg "${global_level}"
    done 

    #UTILS_LOGIT_QLOGS="false"
    #for global_level in {0..5} 
    #do
    #    level_test_utils_logit "${global_level}"
    #done 

}

level_test_utils_qLogMsg ()
{

    declare -i rval 
    declare -i msg_level
    declare msg
    declare indexes

    declare test_log_level
    declare test_log_msg
    declare test_lineno
    declare test_log_funcname

    declare should_lineno
    declare should_funcname

    UTILS_LOGIT_test_log_level=${1}

    for msg_level in {0..5} 
    do

        msg="Global level: ${UTILS_LOGIT_test_log_level} / Message level: ${msg_level}"
        should_funcname=${FUNCNAME}
        should_lineno=$(expr ${LINENO} + 1) # for the line number immediately following this one
        utils_qLogMsg "${msg_level}" "${msg}"
        rval=$?

        assertTrue "${msg}: " "${rval}"
        rval=$?

        if [ ${rval} -eq 0 ]
        then
    
            # only if you need to debug the test function
            #indexes=${!level_test_utils_qLogMsg_LOG_LEVEL[@]}
            #test_log_level=${level_test_utils_qLogMsg_LOG_LEVEL[${NDX}]}
            #test_log_msg=${level_test_utils_qLogMsg_LOG_MSG[${NDX}]}
            #test_log_lineno=${level_test_utils_qLogMsg_LOG_LINENO[${NDX}]}
            #test_log_funcname=${level_test_utils_qLogMsg_LOG_FUNCNAME[${NDX}]}
            #echo "indexes=${indexes}"
            #echo "test_log_level=${test_log_level}"
            #echo "test_log_msg=${test_log_msg}"
            #echo "test_log_lineno=${test_log_lineno}"
            #echo "test_log_funcname=${test_log_funcname}"

            assertSame "Testing level_test_utils_qLogMsg_LOG_LEVEL: " \
                "${level_test_utils_qLogMsg_LOG_LEVEL}" \
                "${msg_level}"

            assertSame "Testing level_test_utils_qLogMsg_LOG_MSG: " \
                "${level_test_utils_qLogMsg_LOG_MSG}" \
                "${msg}"

            assertSame "Testing level_test_utils_qLogMsg_LOG_LINENO: " \
                "${level_test_utils_qLogMsg_LOG_LINENO}" \
                "${should_lineno}"

            assertSame "Testing level_test_utils_qLogMsg_LOG_FUNCNAME: " \
                "${level_test_utils_qLogMsg_LOG_FUNCNAME}" \
                "${should_funcname}"

            unset level_test_utils_qLogMsg_LOG_LEVEL
            unset level_test_utils_qLogMsg_LOG_MSG
            unset level_test_utils_qLogMsg_LOG_LINENO
            unset level_test_utils_qLogMsg_LOG_FUNCNAME

        fi

    done

}

level_test_utils_logit ()
{

    declare -i rval 
    declare -i msg_level
    declare msg
    UTILS_LOGIT_LOG_LEVEL=${1}

    for msg_level in {0..5} 
    do

        #msg_level=0

        msg="Global level: ${UTILS_LOGIT_LOG_LEVEL} / Message level: ${msg_level}"
        utils_logit "${msg_level}" "${msg}"
        rval=$?
        assertTrue "${msg}: " "${rval}"

    done

}

xest_utils_lower()
{

    declare rval
    declare -a lower_TEXT
    declare -a lower_SHOULD

    lower_TEXT[0]="ABCDEFGHIJKLMNOPQRSTUVWXYZ"
    lower_TEXT[1]="AbC123XyZ"
    lower_TEXT[2]="1234567890"
    lower_TEXT[3]="*-~@"
    lower_TEXT[4]=""
    lower_TEXT[5]="FGK$%123  POGKL"

    lower_SHOULD[0]="abcdefghijklmnopqrstuvwxyz"
    lower_SHOULD[1]="abc123xyz"
    lower_SHOULD[2]="1234567890"
    lower_SHOULD[3]="*-~@"
    lower_SHOULD[4]=""
    lower_SHOULD[5]="fgk$%123  pogkl"

    loop_test_utils_lower "assertSame"
    unset lower_TEXT

    #loop_test_utils_dirReady "assertNotSame"
    #unset lower_TEXT

}

loop_test_utils_lower()
{

    declare rval
    declare -i NUM_lower_TEXT
    declare -i NDX

    NUM_lower_TEXT=$(expr ${#lower_TEXT[@]} - 1 )
    for NDX in $(seq 0 ${NUM_lower_TEXT} ) 
    do
        rval=$(utils_lower "${lower_TEXT[${NDX}]}")
        ${1} "For test text '${lower_TEXT[${NDX}]}': " "${lower_SHOULD[${NDX}]}" "${rval}"
    done

}

xest_utils_upper()
{

    declare rval
    declare -a upper_TEXT
    declare -a upper_SHOULD

    upper_TEXT[0]="abcdefghijklmnopqrstuvwxyz"
    upper_TEXT[1]="AbC123XyZ"
    upper_TEXT[2]="1234567890"
    upper_TEXT[3]="*-~@"
    upper_TEXT[4]=""
    upper_TEXT[5]="fgk$%123  pogkl"

    upper_SHOULD[0]="ABCDEFGHIJKLMNOPQRSTUVWXYZ"
    upper_SHOULD[1]="ABC123XYZ"
    upper_SHOULD[2]="1234567890"
    upper_SHOULD[3]="*-~@"
    upper_SHOULD[4]=""
    upper_SHOULD[5]="FGK$%123  POGKL"

    loop_test_utils_upper "assertSame"
    unset upper_TEXT

    #loop_test_utils_dirReady "assertNotSame"
    #unset upper_TEXT

}

loop_test_utils_upper()
{

    declare rval
    declare -i NUM_upper_TEXT
    declare -i NDX

    NUM_upper_TEXT=$(expr ${#upper_TEXT[@]} - 1 )
    for NDX in $(seq 0 ${NUM_upper_TEXT} ) 
    do
        rval=$(utils_upper "${upper_TEXT[${NDX}]}")
        ${1} "For test text '${upper_TEXT[${NDX}]}': " "${upper_SHOULD[${NDX}]}" "${rval}"
    done

}

xest_utils_dirReady()
{

    declare rval
    declare -a dirReady_DIRS

    dirReady_DIRS[0]="."
    dirReady_DIRS[1]="${TEST_UTILS_TEST_DIR1}"
    dirReady_DIRS[2]="logs"

    loop_test_utils_dirReady "assertTrue"
    unset dirReady_DIRS

    dirReady_DIRS[0]=''
    dirReady_DIRS[1]='notadir'
    dirReady_DIRS[2]="${TEST_UTILS_TEST_DIR1}/file-dir1.txt"

    loop_test_utils_dirReady "assertFalse"
    unset dirReady_DIRS

}

loop_test_utils_dirReady ()
{

    declare -i rval
    declare -i numDirs
    declare -i ndx

    numDirs=$(expr ${#dirReady_DIRS[@]} - 1 )
    for ndx in $(seq 0 ${numDirs} ) 
    do
        utils_dirReady "${dirReady_DIRS[${ndx}]}"
        rval=$?        
        ${1} "For test dir '${dirReady_DIRS[${ndx}]}': " $rval
    done

}

xest_utils_exec ()
{

    declare rval
    declare -a exec_COM

    exec_COM[0]="ls -l 1>/dev/null"
    exec_COM[1]="echo hello! 1>/dev/null 2>&1"
    exec_COM[2]="${TEST_UTILS_EXEC_SCRIPT} ${TEST_UTILS_EXEC_ARG1} > ${TEST_UTILS_EXEC_STDOUT} 2>${TEST_UTILS_EXEC_STDERR}"
    loop_test_utils_exec "assertSame"
    unset exec_COM
    
    exec_COM[0]="badxommand 1>/dev/null 2>&1"
    exec_COM[1]="ls -z 1>/dev/null 2>&1"
    exec_COM[2]="${TEST_UTILS_EXEC_SCRIPT} "" > ${TEST_UTILS_EXEC_STDOUT} 2>${TEST_UTILS_EXEC_STDERR}"
    loop_test_utils_exec "assertNotSame"
    unset exec_COM
    
}


loop_test_utils_exec ()
{

    declare -i NUM_exec_COMS
    declare -i NDX

    NUM_exec_COMS=$(expr ${#exec_COM[@]} - 1 )
    for NDX in $(seq 0 ${NUM_exec_COMS} ) 
    do
        #echo "Executing: ${exec_COM[${NDX}]}"
        utils_exec "${exec_COM[${NDX}]}" "${TEST_UTILS_EXEC_STDOUT}"
        rval=$?        
        ${1} "For command '${exec_COM[${NDX}]}': " 0 $rval
    done

}

#-----------------------------------------------------------------------------
# suite functions
#

oneTimeSetUp()
{

#  outputDir="${SHUNIT_TMPDIR}/output"
#  mkdir "${outputDir}"
#  stdoutF="${outputDir}/stdout"
#  stderrF="${outputDir}/stderr"

#  mkdirCmd='mkdir'  # save command name in variable to make future changes easy
#  testDir="${SHUNIT_TMPDIR}/some_test_dir"

    test_utils_BASE_NAME=$(basename $0)
    test_utils_BASE_DIR=$( cd $(dirname ${test_utils_BASE_NAME}) ; pwd -P )

    TEST_UTILS_TEST_DIR1="${test_utils_BASE_DIR}/testdir1"
    TEST_UTILS_TEST_SUBDIR1="${TEST_UTILS_TEST_DIR1}/subdir1"
    TEST_UTILS_TEST_SUBDIR1a="${TEST_UTILS_TEST_SUBDIR1}/subdir1a"

    TEST_UTILS_TEST_DIR2="${test_utils_BASE_DIR}/testdir2"

    TEST_UTILS_EXEC_SCRIPT="${test_utils_BASE_DIR}/test_utils_exec_external.sh"
    TEST_UTILS_EXEC_ARG1="${test_utils_BASE_DIR}/test_utils_exec_input.txt"
    TEST_UTILS_EXEC_STDOUT="${test_utils_BASE_DIR}/test_utils_exec_external.stdout"
    TEST_UTILS_EXEC_STDERR="${test_utils_BASE_DIR}/test_utils_exec_external.stderr"


    # Test cases for path, file name and file extension parsing
    nameExt[0]=""

    nameExt[1]="file-subdir1a"
    nameExt[2]="file-subdir1a."
    nameExt[3]="file-subdir1a.txt"

    nameExt[4]="/file-subdir1a"
    nameExt[5]="/file-subdir1a."
    nameExt[6]="/file-subdir1a.txt"

    nameExt[7]="./file-subdir1a"
    nameExt[8]="./file-subdir1a."
    nameExt[9]="./file-subdir1a.txt"

    nameExt[10]="../file-subdir1a"
    nameExt[11]="../file-subdir1a."
    nameExt[12]="../file-subdir1a.txt"

    nameExt[13]="../../file-subdir1a"
    nameExt[14]="../../file-subdir1a."
    nameExt[15]="../../file-subdir1a.txt"

    nameExt[16]="/1.2/file-subdir1a"
    nameExt[17]="/1.2/file-subdir1a."
    nameExt[18]="/1.2/file-subdir1a.txt"

    nameExt[19]="file-subdir1a.txt.1"
    nameExt[20]="/file-subdir1a.txt.1"
    nameExt[21]="../file-subdir1a.txt.1"

    nameExt[22]="../../file-subdir1a.txt.1"
    nameExt[23]="/1.2/file-subdir1a.txt.1"

}

setUp ()
{
    mkdir -p "${test_utils_BASE_DIR}/logs"
    mkdir -p "${TEST_UTILS_TEST_DIR1}"
    mkdir -p "${TEST_UTILS_TEST_SUBDIR1}"
    mkdir -p "${TEST_UTILS_TEST_SUBDIR1a}"
    mkdir -p "${TEST_UTILS_TEST_DIR2}"

    touch ${TEST_UTILS_TEST_DIR1}/file-dir1.txt
    touch ${TEST_UTILS_TEST_SUBDIR1}/file-subdir1.txt
    touch ${TEST_UTILS_TEST_SUBDIR1a}/file-subdir1a.txt
}
tearDown()
{
    :
    rm -rf "${TEST_UTILS_TEST_DIR1}"
    rm -rf "${TEST_UTILS_TEST_DIR2}"

    #rm -f "${TEST_UTILS_EXEC_STDOUT}"
    #rm -f "${TEST_UTILS_EXEC_STDERR}"
}

test_utils_SUBJECT_BASE_NAME="../../lib/utils.sh"
test_utils_SUBJECT_BASE_DIR=$( cd $(dirname ${test_utils_SUBJECT_BASE_NAME}) ; pwd -P )
#source ../../lib/utils.sh
source ${test_utils_SUBJECT_BASE_NAME}

# load and run shUnit2
[ -n "${ZSH_VERSION:-}" ] && SHUNIT_PARENT=$0
#. ../shunit2-2.1.6/src/shunit2
. /bin/shunit/shunit2
