#!/bin/bash

scriptdir="/var/scripts"
service="sleep"

flag=1

function sigint_handler {
    $scriptdir/terminator.sh $pid $service
    
    wait $pid
    exit 0
}

trap sigint_handler USR1

sleep 1000 &
pid=$!

ps | grep $pid
status=$?

if [ $status -eq 0 ]; then
    $scriptdir/logger.sh msg "$service service is on" $service $service
fi

while [ $flag -ge 1 ]; do
    wait
    flag=$?
done

exit 0