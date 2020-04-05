#!/bin/bash

CONFIG_DIR="$HOME/.config"
CONFIG_PATH="$CONFIG_DIR/secret_goose_rust.config"

if [ -f $CONFIG_PATH ]; then
    source $CONFIG_PATH
else
    mkdir -p $CONFIG_DIR
fi

if [[ -z $SG_UWATERLOO_USERNAME ]]; then
    read -p "Please enter your Uwaterloo Quest id: " SG_UWATERLOO_USERNAME
    echo "export SG_UWATERLOO_USERNAME=$SG_UWATERLOO_USERNAME" >> $CONFIG_PATH
fi

if [[ -z $SG_PREFERRED_SERVER ]]; then
    read -p "Please enter your Preferred server: CSC(1), STUDENT CS(2):  " SG_PREFERRED_SERVER
    case $SG_PREFERRED_SERVER in
        1|2)
            echo "SG_PREFERRED_SERVER: CSC(1), STUDENT CS(2)" >> $CONFIG_PATH
            echo "export SG_PREFERRED_SERVER=$SG_PREFERRED_SERVER" >> $CONFIG_PATH
            ;;
        *)
            echo "Please select a valid server."
            exit 1
            ;;
    esac
fi

echo "export SG_PROJECT_PATH=" >> $CONFIG_PATH
