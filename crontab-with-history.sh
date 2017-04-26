#!/usr/bin/env bash

# path configuration
ROOT="${HOME}/.crontab"
LOCK="${ROOT}/lock"
CRONTAB="${ROOT}/crontab"
TEMP="${ROOT}/temp"
CRONTAB_SWP="${ROOT}/.crontab.swp"
TEMP_SWP="${ROOT}/.temp.swp"
DIFF="${ROOT}/diff"
HISTORY="${ROOT}/history"

function main {
    # unlock when force terminated
    trap "echo -e '\nForce terminated. Bye.' && rm -f ${LOCK} ${TEMP} ${DIFF} ${CRONTAB_SWP} ${TEMP_SWP} && exit" INT TERM

    # check arguments
    if [ $# -eq 0 ] || [ $# -gt 1 ]
    then
        usage
    fi

    case $1 in
        -e)
            edit
            ;;
        -l)
            display_crontab
            ;;
        -h)
            display_history
            ;;
        -C)
            force_clean
            ;;
        *)
            usage
            ;;
    esac
}

function usage {
    echo "Usage: $0 { -e | -l | -h | -C }"
    echo "This script prevents removing crontab by mistake and writes history after editing crontab."
    echo ""
    echo -e "  -e\t Edit crontab and then write history"
    echo -e "  -l\t Display the current crontab"
    echo -e "  -h\t Display change history"
    echo -e "  -C\t Force clean lock and temp files"

    exit
}

function edit {
    echo "### crontab-with-history script ###"

    # ready directory
    mkdir -p ${ROOT}

    # check lock
    if [ -f ${LOCK} ]
    then
        echo "Lock file exists. [$(cat ${LOCK})] is editing crontab."
        exit
    fi

    # lock
    touch ${LOCK}

    # get editor name
    read -p "Enter your name: " NAME

    # write editor name to lock file
    echo ${NAME} > ${LOCK}

    # get current crontab file
    crontab -l > ${CRONTAB}

    # make temp
    cp ${CRONTAB} ${TEMP}

    # edit temp file
    vim -c "set ft=crontab" ${TEMP}

    # diff current with temp
    diff -u ${CRONTAB} ${TEMP} > ${DIFF}

    # check changed
    if [ -s ${DIFF} ]
    then
        # cat diff
        echo "=================================================================================================================================="
        cat ${DIFF} | sed "s/^-/`echo -e \"\x1b\"`[41m-/;s/^+/`echo -e \"\x1b\"`[42m+/;s/^@/`echo -e \"\x1b\"`[34m@/;s/$/`echo -e \"\x1b\"`[0m/"
        echo "=================================================================================================================================="
        # get comment
        read -p "Enter comment: " COMMENT

        # write history
        echo "==================================================================================================================================" >> ${HISTORY}
        echo "#### DATE: $(date +%Y-%m-%d:%H:%M:%S)" >> ${HISTORY}
        echo "#### EDITOR: ${NAME}" >> ${HISTORY}
        echo "#### COMMENT: ${COMMENT}" >> ${HISTORY}
        cat ${DIFF} >> ${HISTORY}

        # install crontab
        cp ${TEMP} ${CRONTAB}
        crontab ${CRONTAB}
        echo "New crontab installed."

        # clean
        rm ${TEMP} ${DIFF}
    else
        echo "No changes."
        rm ${TEMP} ${DIFF}
    fi

    # unlock
    rm ${LOCK}
}

function display_crontab {
    # ready directory
    mkdir -p ${ROOT}
    
    # get current crontab file
    crontab -l > ${CRONTAB}

    # vim read-only
    vim -M -c "set ft=crontab" ${CRONTAB}
}

function display_history {
    # ready directory
    mkdir -p ${ROOT}
    
    # vim read-only
    vim -M -c "set ft=diff" ${HISTORY}
}

function force_clean {
    # ready directory
    mkdir -p ${ROOT}
    
    # confirm
    read -p "Do you want remove lock and temp files? [y/n]: " ANSWER
    case ${ANSWER} in
        [yY])
            echo "Remove lock and temp files."
            rm -f ${LOCK} ${TEMP} ${DIFF} ${CRONTAB_SWP} ${TEMP_SWP}
            exit
            ;;
        *)
            echo "Do nothing. Bye."
            exit
            ;;
    esac
}

# Run main
main $@

