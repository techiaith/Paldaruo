#!/bin/sh
while true; do
    START=`date +%s`
    /usr/local/bin/python webserver.py
    END=`date +%s`
    ELAPSED=`expr $END - $START`
    if [ "$ELAPSED" -lt 10 ] ; then
        # Dying too fast; wait
        SLEEP=`expr 10 - $ELAPSED`
        sleep ${SLEEP}s
    fi
done
