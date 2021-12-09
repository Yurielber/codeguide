#!/bin/bash

TEMP_DIR='/tmp'
ZONES_FILE_DIR='/opt/dns/zones'
ZONES_FILE_TEMP="${TEMP_DIR}/zones"
ZONE_INCLUDE_FILE_TEMP="${TEMP_DIR}/zones.include"
ZONE_INCLUDE_FILE='/opt/dns/bind-data/zones.include'
ZONE_INCLUDE_FILE_BACKUP="${ZONE_INCLUDE_FILE}.bak"

if [ ! $(whoami) == 'root' ]; then
	exit 1
fi

## disable cron task
service cron stop

## kill named
killall named; sleep 5 ; killall named

## kill dns-agent
ps -wwef | grep 'dns-agent' | grep -v grep | awk '{print $2}' | xargs kill -9

## backup file
rm -f ${ZONE_INCLUDE_FILE_BACKUP} >/dev/null 2>&1
cp ${ZONE_INCLUDE_FILE} ${ZONE_INCLUDE_FILE_BACKUP}
chown --reference ${ZONE_INCLUDE_FILE} ${ZONE_INCLUDE_FILE_BACKUP}
chmod --reference ${ZONE_INCLUDE_FILE} ${ZONE_INCLUDE_FILE_BACKUP}
> ${ZONE_INCLUDE_FILE}

rm -f ${ZONES_FILE_TEMP} >/dev/null 2>&1
touch ${ZONES_FILE_TEMP}
tatal_zones=$(ls ${ZONES_FILE_DIR} | wc -w)
echo "$tatal_zones zones found."
find ${ZONES_FILE_DIR} -type f -name "*.z" -exec echo {} >> ${ZONES_FILE_TEMP} \;

content=$(cat $ZONES_FILE_TEMP)

for zone in $content; do
	if [ -r $zone ]; then
		file_name=$(basename $zone)
		zone_name="${file_name%.z}"
		/usr/sbin/named-checkzone -i local $zone_name $zone >/dev/null 2>&1
		if [ 0 == $? ]; then
			echo "zone \"$zone_name\" IN { type master; file \"$zone\"; allow-update { none; }; };" >> ${ZONE_INCLUDE_FILE}
		fi
	fi
done

/usr/sbin/named-checkconf -z >/dev/null 2>&1
if [ 0 == $? ]; then
	echo "zones.include file is ok."
else
	## recovery file
	rm -f ${ZONE_INCLUDE_FILE} >/dev/null 2>&1
	mv ${ZONE_INCLUDE_FILE_TEMP} ${ZONE_INCLUDE_FILE}
	chown --reference ${ZONE_INCLUDE_FILE_BACKUP} ${ZONE_INCLUDE_FILE}
	chmod --reference ${ZONE_INCLUDE_FILE_BACKUP} ${ZONE_INCLUDE_FILE}
fi

service named restart
## enable cron task
service cron restart
