#!/bin/bash

ranges="$1"
SERVER='114.114.114.114'
OUTPUT='dig.log'

function validateRange
{
if [ -z "$ranges" ]; then
	exit 1
fi

local RANGE_PATTERN='([0-9]{1,3}\.){2}[0-9]{1,3}'
if [[ ! "$ranges" =~ ${RANGE_PATTERN} ]]; then
	echo 'ERROR: invalid ip address' >&2
	exit 1
fi
}

function digTest
{
local netPrefix="$1"
for i in {0..255}; do
	target="$netPrefix.$i"
	stdout=$(dig @${SERVER} -x "$target" +retry=1 +time=1 +cmd 2>&1)
	## echo "Testing --> $target" >> $OUTPUT
	echo "$stdout" | grep ';; Got answer:' >/dev/null 2>&1
	got_answer=$( echo $?)
	code=$( echo "$stdout" | sed -rn 's/^[[:print:]]+?, status: ([[:alpha:]]*?), id: [[:digit:]]+/\1/p')
	if [ $got_answer == 0 ] && [ "$code" == 'NOERROR' ]; then
		echo "$target" >> $OUTPUT
		local answer_start=$( echo "$stdout" | grep -n ';; ANSWER SECTION:' | sed -rn 's/^([[:digit:]]+):[[:print:]]+/\1/p' )
		local answer_end=$( echo "$stdout" | grep -n ';; Query time:' | sed -rn 's/^([[:digit:]]+):[[:print:]]+/\1/p' )
		if [ $answer_start -le $answer_end ]; then
			echo "$stdout" | sed -n "$((answer_start+1)),$((answer_end-2))p" >> $OUTPUT
		fi
	fi
done
exit 0
}

validateRange
digTest $ranges
