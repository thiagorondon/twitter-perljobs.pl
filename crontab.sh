#!/bin/bash

PID_FILE=/var/tmp/perljobs.pid
PERLJOBS=/home/thiago/perljobs/perljobs.pl

function check_lock() {
    if [ -f $PID_FILE ]; then
	PID=$(cat $PID_FILE)
	if [ "$PID" -eq $$ ]; then
		echo $$
	else
		[ -d /proc/$PID ] && echo "0" || echo "-1"
	fi
	else
		echo "-1"
	fi
}
while [ 1 ]; do
	PID=$(check_lock)
	[ ! $PID ] && exit
    	if [ $PID -eq -1 ]; then
		echo $$ > $PID_FILE
		PID=$$
	fi
	[ $PID -ne $$ ] && exit
	$PERLJOBS
	trap "rm -f $PID_FILE; exit" 2 3 15
	sleep 20
done

