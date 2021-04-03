#!/bin/bash

pid=$1
process=$2

scriptdir="/var/scripts"

if [ kill -s TERM $pid >/dev/null 2>&1 ]; then
    $scriptdir/logger.sh warn "$process did not terminate, attempting to terminate it again in 1s" $process $process
    sleep 1
    
    if [ kill -s TERM $pid >/dev/null 2>&1 ]; then
        $scriptdir/logger.sh error "$process did not terminate, killing process" $process $process

        while kill -s KILL $pid >/dev/null 2>&1; do
            echo -n > /dev/null
        done

        $scriptdir/logger.sh msg "killed $process" $process $process
    fi
else
    ps | grep $pid
    status=$?

    if [ $status -eq 0 ]; then
        $scriptdir/logger.sh error "$process did not terminate, killing process" $process $process
        
        while kill -s KILL $pid >/dev/null 2>&1; do
            echo -n > /dev/null
        done
    else
        $scriptdir/logger.sh msg "$process terminated normally" $process $process
    fi
fi