#!/bin/bash

ranges="$1"
start="$2"
end="$3"
DIR="$( cd "$( dirname "$0" )" && pwd )"
EXEC="$DIR/digTest.sh"
PIDLIST=''
OUTPUT='dig.log'
THREADS=100

function validateRange
{
if [ -z "$ranges" ]; then
        exit 1
fi
local RANGE_PATTERN='([0-9]{1,3}\.)[0-9]{1,3}'
if [[ ! "$ranges" =~ ${RANGE_PATTERN} ]]; then
        echo 'ERROR: invalid ip address' >&2
        exit 1
fi
}

function waits
{
local finish=false
while [ $finish = false ]
do
        local flag=true
        for j in $PIDLIST; do
                if [ $(kill -0 $j >/dev/null 2>&1; echo $?) == 0 ]; then
                        flag=false
                        break
                fi
        done
        if [ $flag == false ]; then
                local WAIT=30
                finish=false
                sleep $WAIT
        else
                finish=true
                PIDLIST=''
        fi
done
}

function startJobs
{
local START=0
local END=255
if [ -n "$start" ]; then
        START=$start
fi
if [ -n "$end" ]; then
        END=$end
fi
for (( i=$START; i<=$END; i++ )); do
        local target="$ranges.$i"
        echo "[$target] start ..."
        /bin/bash "$EXEC" "$target" &
        local pid=$(echo "$!")
        PIDLIST="$PIDLIST $pid"
        if [ $(( (i+1) % $THREADS )) == 0 ] || [ $i == $END ]; then
                waits
        fi
done
exit 0
}

> $OUTPUT
validateRange
startJobs
