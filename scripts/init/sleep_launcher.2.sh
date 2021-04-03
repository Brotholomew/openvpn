#!/bin/sh

function sigint_handler {
    while kill -s KILL $pid >/dev/null 2>&1; do
    	echo "$$ attempted to kill $pid" > /dev/null
	done

    echo "$$ launcher killed sleep at $pid"

    wait $pid
    exit 0
}

trap sigint_handler USR1

sleep 1000 &
pid=$!

wait
exit 0