#!/bin/sh

IP_PATTERN='([0-9]{1,3}\.){3}[0-9]{1,3}'
IP_ADDRESS=''
SCRIPTS_HOME={% if ansible_distribution in ['SLES'] %}'/etc/sysconfig/network'{% else %}'/etc/sysconfig/network-scripts'{% endif %}

## validate ip address
if [ $# -gt 0 ]; then
        if [[ $1 =~ ${IP_PATTERN} ]]; then
                IP_ADDRESS=$1
        else
                echo 'ERROR: invalid ip address' >&2
                exit 1
        fi
else
        echo 'ERROR: empty parameter' >&2
        exit 1
fi

## check root login
if [ ! $(whoami) == 'root' ];then
    echo "ERROR: insufficient privilege." >&2
    exit 1
fi

## find NIC with target ip address
MATCH_PATTERN="IPADDR=('|\")?${IP_ADDRESS}('|\")?"
nicFile=''
for file in ${SCRIPTS_HOME}/ifcfg-*; do
    line=$(grep '^IPADDR=' $file )
    if [ $? == 0 ]; then
        if [[ $line =~ ${MATCH_PATTERN} ]]; then
            nicFile=$(basename $file)
            break
        fi
    fi
done

if [ ! -z $nicFile ]; then
    prefix="ifcfg-"
    nic="${nicFile#$prefix}"
    echo "${nic}"
    exit 0
else
    echo "ERROR: There is no network interfaces bind ip ${IP_ADDRESS}" >&2
    exit 1
fi
