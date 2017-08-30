#!/bin/bash

ZONE_INCLUDE_FILE='/opt/dns/bind-data/zones.include'
ZONE_INCLUDE_FILE_BACKUP="${ZONE_INCLUDE_FILE}.bak"
TEMP_DIR='/run'
ZONE_INCLUDE_FILE_TEMP="${TEMP_DIR}/zones.include"

if [ ! $(whoami) == 'root' ]; then
	exit 1
fi

if [ ! -r $ZONE_INCLUDE_FILE ]; then
	exit 1
fi

## disable cron task
service cron stop

## kill named
killall named; sleep 5ll ; killall named

## kill dns-agent
killall java

## backup file
rm -f ${ZONE_INCLUDE_FILE_BACKUP} >/dev/null 2>&1
cp ${ZONE_INCLUDE_FILE} ${ZONE_INCLUDE_FILE_BACKUP}
chown --reference ${ZONE_INCLUDE_FILE} ${ZONE_INCLUDE_FILE_BACKUP}
chmod --reference ${ZONE_INCLUDE_FILE} ${ZONE_INCLUDE_FILE_BACKUP}

## make a copy
rm -f ${ZONE_INCLUDE_FILE_TEMP} >/dev/null 2>&1
cp ${ZONE_INCLUDE_FILE_BACKUP} ${ZONE_INCLUDE_FILE_TEMP}

## gather non-exist zone
target=$(/usr/sbin/named-checkconf -z 2>&1 >/dev/null | grep 'file not found' | sed -r 's|^[-_a-zA-Z0-9]+?/(.?+)/IN:.+$|\1|')

if [ ! -z "$target" ]; then
	index=0
	for zone in $target; do
		index=$((index+1))
		echo $index
		sed -i "s|^zone \"$zone\" IN |# zone \"$zone\" IN |g" $ZONE_INCLUDE_FILE_TEMP
	done
fi

## recovery file
rm -f ${ZONE_INCLUDE_FILE} >/dev/null 2>&1
mv ${ZONE_INCLUDE_FILE_TEMP} ${ZONE_INCLUDE_FILE}
chown --reference ${ZONE_INCLUDE_FILE_BACKUP} ${ZONE_INCLUDE_FILE}
chmod --reference ${ZONE_INCLUDE_FILE_BACKUP} ${ZONE_INCLUDE_FILE}

## enable cron task
service cron restart
