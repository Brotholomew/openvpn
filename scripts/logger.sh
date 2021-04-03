#!/bin/bash

# script written by Brotholomew [https://github.com/brotholomew][https://bartosz.blachut.me]
# params: $1 - state (warn/err/msg); $2 - message; $3 - service name; $4 - name for logfile 

# --- logrotate ---
umask 0

logdir="/home/log/$4"
mkdir -p $logdir > /dev/null 2>&1

logfile="$logdir/$4.log"
touch $logfile
#chmod 644 $logfile

function logrotate {
    increment=1

    for f in $logdir/*; do
        if [ $f = "$logdir/$1.$increment.log" ]; then
            increment=$(($increment+1))
        fi
    done

    touch "$logdir/$1.$increment.log"
    cat $logfile > "$logdir/$1.$increment.log"
    echo -n > "$logfile"
}

if [ `wc -l $logfile | tr -dc '0-9'` -ge 1000 ]; then
    logrotate $4
fi
# --- * ---

if [ $1 = "warn" ]; then
    echo "[$3][WARN]{`date +"%d-%M-%Y %H:%M:%S"`} $2"
    echo "[$3][WARN]{`date +"%d-%M-%Y %H:%M:%S"`} $2" >> $logfile
fi

if [ $1 = "error" ]; then
    echo "[$3][ERR]{`date +"%d-%M-%Y %H:%M:%S"`} $2"
    echo "[$3][ERR]{`date +"%d-%M-%Y %H:%M:%S"`} $2" >> $logfile
fi

if [ $1 = "msg" ]; then
    echo "[$3][MSG]{`date +"%d-%M-%Y %H:%M:%S"`} $2"
    echo "[$3][MSG]{`date +"%d-%M-%Y %H:%M:%S"`} $2" >> $logfile
fi