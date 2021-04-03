#!/bin/bash

# script written by Brotholomew [https://github.com/brotholomew][https://bartosz.blachut.me]

declare -A processes
flag=1
scriptdir="/var/scripts"
set -m

function terminate {
    $scriptdir/logger.sh msg "terminating tasks..." init init

    for pid in ${processes[@]}; do
        kill -s USR1 $pid > /dev/null 2>&1
    done
}

function goodbye {
    $scriptdir/logger.sh msg "init closed" init init
}

function load {
    $scriptdir/logger.sh msg "loading scripts..." init init

    for f in $scriptdir/init/*; do
        if [ ${processes[$f]} ]; then
            echo "" > /dev/null
        else
            $f > /dev/null 2>&1 &
            processes[$f]=$!
            $scriptdir/logger.sh msg "loaded $f" load load
        fi
    done
}

function reload {
    $scriptdir/logger.sh msg "reloading scripts..." init init
    prune
    load
}

function prune {
    $scriptdir/logger.sh msg "pruning killed processes..." init init

    for p in ${!processes[@]}; do
        ps | grep ${processes[$p]}
        status=$?

        if [ $status -ne 0 ]; then
            unset processes[$p]
            $scriptdir/logger.sh msg "pruned $p" init init
        fi
    done
}

function sync {
    reload

    for p in ${!processes[@]}; do
        remove_if_unused $p
    done
}

function remove_if_unused {
    rm_flag=1

    for f in $scriptdir/init/*; do
        if [ $f = $1 ]; then
            rm_flag=0
        fi
    done

    if [ $rm_flag -eq 1 ]; then
        $scriptdir/logger.sh msg "$1 is not in init anymore, killing..." sync sync
        kill -s USR1 ${processes[$1]}

        sleep 1
        ps | grep ${processes[$1]}
        status=$?

        if [ $status -eq 0 ]; then 
            $scriptdir/terminator.sh ${processes[$1]} ""
        fi

        unset processes[$1]
    fi
}

function init {
    trap terminate INT
    trap terminate TERM
    trap sync USR2
    trap reload USR1

    load

    while [ $flag -ge 1 ]; do
        wait
        flag=$?
    done

    goodbye
    exit 0
}

init