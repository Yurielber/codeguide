#!/bin/bash

DNS_SERVER=localhost

STORAGE_DIR=/opt/dns/test-data
LOG_FILE=$STORAGE_DIR/test.log

BIND_WORK_DIR=/opt/dns/named
DUMP_DB_FILE=$BIND_WORK_DIR/data/cache_dump.db

function log()
{
    if [ ! -d $STORAGE_DIR ]; then
        mkdir -p $STORAGE_DIR
        chmod 755 $STORAGE_DIR
    fi
    if [ ! -f $LOG_FILE ]; then
        touch $LOG_FILE
    fi
    echo "$1" >> $LOG_FILE
}

function log_error()
{
   log "ERROR: $1"
}

function named_dump()
{
    local disk_usage=$(df -h | grep '/opt' | awk '{print $5}')
    local suffix='%'
    disk_usage=${disk_usage%$suffix}
	
    if [ $disk_usage -gt 50 ]; then
        return
    fi
	
    rm -f $DUMP_DB_FILE >/dev/null 2>&1
    local current=$(date '+%Y-%m-%d_%H-%M-%S')
	
    /usr/sbin/rndc dumpdb -all >/dev/null 2>&1
    if [ 0 = $? ]; then
        cp $DUMP_DB_FILE "$STORAGE_DIR/${current}.dump" >/dev/null 2>&1
        rm -f $DUMP_DB_FILE >/dev/null 2>&1
        log "INFO: dumpdb success."
    else
        log "WARN: dumpdb failed."
    fi
}

function rndc_reload_zone()
{
    /usr/sbin/rndc reload >/dev/null 2>&1
    if [ 0 = $? ]; then
        log "INFO: rndc reload success."
    else
        log "WARN: rndc reload failed."
    fi
}

function named_restart()
{
    ## check root login
    if [ ! ${whoami} == 'root' ];then
        echo "ERROR: insufficient privilege." >&2
		log "WARN: named not restart, insufficient privilege."
		return
    fi

    service named restart >/dev/null 2>&1; sleep 2
    if [ 0 = $? ]; then
        log "INFO: named restart success."
    else
        log "WARN: named restart failed."
    fi
}

function test_dig()
{
    local target=$1
	
    local stdout=$(dig @$DNS_SERVER $target +tries=1 +time=1 +cmd 2>&1)
    echo "$stdout" | grep ';; Got answer:' >/dev/null 2>&1
    local got_answer=$( echo $?)
	
    if [ ! $got_answer = 0 ]; then
        echo "$stdout"
		exit 1
    fi
	
    local code=$( echo "$stdout" | sed -rn 's/^[[:print:]]+?, status: ([[:alpha:]]*?), id: [[:digit:]]+/\1/p')
    echo "$target  -->  $code"
	
    echo "$stdout" | grep '^;; flags:'
	
	local answer_start=$( echo "$stdout" | grep -n ';; ANSWER SECTION:' | sed -rn 's/^([[:digit:]]+):[[:print:]]+/\1/p' )
	local answer_end=$( echo "$stdout" | grep -n ';; Query time:' | sed -rn 's/^([[:digit:]]+):[[:print:]]+/\1/p' )
    
    if [ $answer_start -le $answer_end ]; then
	    echo "$stdout" | sed -n "$((answer_start+1)),$((answer_end-2))p"
    fi

    case "$code" in
    NOERROR)

	  ;;
    NXDOMAIN)

	  ;;
    SERVFAIL)

	  ;;
	*)
	  ;;
    esac
}

function test()
{
    test_dig 'version.bind'
    exit 0
}

test
