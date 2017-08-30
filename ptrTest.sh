#!/bin/bash

RANGES=" 49.4 "
for x in $RANGES; do
	for y in {0..255}; do
		for z in {0..255}; do
			target="$x.$y.$z"
			stdout=$(dig @8.8.8.8 "$target" +retry=1 +time=1 +cmd 2>&1)
			echo "$stdout" | grep ';; Got answer:' >/dev/null 2>&1
			got_answer=$( echo $?)
			code=$( echo "$stdout" | sed -rn 's/^[[:print:]]+?, status: ([[:alpha:]]*?), id: [[:digit:]]+/\1/p')
			if [ $got_answer == 0 ] && [ "$code" == 'NOERROR' ]; then
				echo "$target" " --> $stdout"
			fi
		done
	done
done
