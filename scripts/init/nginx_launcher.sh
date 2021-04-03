#!/bin/bash

scriptdir="/var/scripts"
service="nginx"

flag=1

function sigint_handler {
    nginx -s quit

    ps | grep $pid
    status=$?

    if [ $status -eq 0 ]; then
        $scriptdir/terminator.sh $pid $service
    fi

    ps | grep $pid2
    status=$?
             
    if [ $status -eq 0 ]; then
        $scriptdir/terminator.sh $pid2 "nginx:inotifywait"
    fi                  
                        
    exit 0              
}                       
                        
trap sigint_handler USR1
trap sigint_handler INT 
trap sigint_handler TERM
                        
nginx &                   
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
                                                                
# nginx becomes an orphan and a direct child of the init process
pid=$(cat /var/run/nginx/nginx.pid) > /dev/null 2>&1                         
inotifywait /var/run/nginx/nginx.pid > /dev/null 2>&1 &  
pid2=$!                               
                         
flag=1                   
while [ $flag -ge 1 ]; do
    wait                 
    flag=$?
done       
      
exit 0