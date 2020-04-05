#!/bin/bash

CONFIG_DIR="$HOME/.config"
SG_CONFIG_PATH="$CONFIG_DIR/secret_goose_rust.config"

CSC_SERVER="hfcs.csclub.uwaterloo.ca"
CS_SERVER="linux.student.cs.uwaterloo.ca"

sg_rust_check_environment()
{
    local ENV_ERR_MSG="Environment is not set correctly"
    if [ ! -f $SG_CONFIG_PATH ]; then
        echo $ENV_ERR_MSG
        exit 1
    fi

    source $SG_CONFIG_PATH

    if [[ -z $SG_UWATERLOO_USERNAME ]]; then
        echo $ENV_ERR_MSG
        exit 1
    fi

    if [[ -z $SG_PREFERRED_SERVER ]]; then
        echo $ENV_ERR_MSG
        exit 1
    fi
}

sg_rust_build()
{
    sg_rust_check_environment

    local DEFAULT_PROJECT_PATH='$HOME/src/github.com/secret-goose/rust'
    local SG_PROJECT_PATH=${SG_PROJECT_PATH:-$DEFAULT_PROJECT_PATH}

    local FUNCTION_NAME=$0
    usage() {
        echo "$FUNCTION_NAME [ OPTIONS ]"
        echo "OPTIONS:"
        echo "-s | --server (1: CSC| 2: Student CS): Select build server"
        echo "-p | --proj-dir [PATH relative to $HOME| default: $DEFAULT_PROJECT_PATH]: Set project root directory"
        echo "-r | --remember: Updates environement variables"
        echo "-h | --help: Print this usage message"

        echo "When specifing project path and using server environment variable, use single quotes instead of double quotes."
        exit ${1:0}
    }


    local UPDATE_ENV=0
    local SERVER_UPDATED=0
    local PROJ_PATH_UPDATED=0


    while [  $1 ]; do
        case $1 in
            --server|-s)
                SERVER_UPDATED=1
                SG_PREFERRED_SERVER=$2
                shift
                ;;
            --proj-dir|-p)
                PROJ_PATH_UPDATED=1
                SG_PROJECT_PATH=$2
                shift
                ;;
            --remember|-r)
                UPDATE_ENV=1
                ;;
            --help|-h)
                usage
                ;;
            *)
                usage 1
                ;;
        esac
        shift
    done

    local SSH_SERVER=""
    case $SG_PREFERRED_SERVER in
        1)
            SSH_SERVER=$CSC_SERVER
            ;;
        2)
            SSH_SERVER=$CS_SERVER
            ;;
        *)
            usage 1
            ;;
    esac

    local SSH_ADDRESS="$SG_UWATERLOO_USERNAME@$SSH_SERVER"

    if [[ 1 -eq $UPDATE_ENV ]]; then
        if [[ 1 -eq $SERVER_UPDATED ]]; then
            sed -ie \
                "s:SG_PREFERRED_SERVER=.*$:SG_PREFERRED_SERVER=$SG_PREFERRED_SERVER:g" \
                $SG_CONFIG_PATH
        fi

        if [[ 1 -eq $PROJ_PATH_UPDATED ]]; then
            sed -ie \
                "s:SG_PROJECT_PATH=.*$:SG_PROJECT_PATH='$SG_PROJECT_PATH':g" \
                $SG_CONFIG_PATH
        fi
    fi

    local BUILD_COMMAND="hostname"

    ssh $SSH_ADDRESS -t "cd $SG_PROJECT_PATH; pwd; $BUILD_COMMAND"
    ssh $SSH_ADDRESS
}
