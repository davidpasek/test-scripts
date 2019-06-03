#!/bin/bash

# Disable SPECTRE
#echo 0 > /sys/kernel/debug/x86/pti_enabled
#echo 0 > /sys/kernel/debug/x86/retp_enabled
#echo 0 > /sys/kernel/debug/x86/ibrs_enabled

# Test params
########################
NUM_OF_CONTAINERS=32
########################

########################
# START REDIS CONTAINERS
########################
function start {
for i in `seq 1 $NUM_OF_CONTAINERS`;
  do
    c_name="redis$i"
    echo "Run container $i - $c_name"
    docker run --name $c_name -d redis
  done
}

########################
# EXEC TEST IN REDIS CONTAINERS
########################
function exec {
for i in `seq 1 $NUM_OF_CONTAINERS`;
  do
    c_name="redis$i"
    echo "Exec test in container $i - $c_name"
    docker exec $c_name redis-benchmark -t set --csv | cut -d"," -f2 | cut -d '"' -f2 > /tmp/$c_name.set.perf &
  done
}

########################
# START REDIS CONTAINERS
########################
function report {
TOTAL_RESULT_SET=0
for i in `seq 1 $NUM_OF_CONTAINERS`;
  do
    c_name="redis$i"
    RESULT_FILE="/tmp/$c_name.set.perf"

    RESULT_SET=0
    while [ $RESULT_SET -lt 1 ]; do
      if [ -f "$RESULT_FILE" ]
        then
	  R=`cat $RESULT_FILE`
	  RESULT_SET=`printf "%i" $R`
          echo "Result set ($c_name): $RESULT_SET"
	else
          echo "Result file $RESULT_FILE not found."
	  RESULT_SET=0
	  sleep 2
      fi
    done

    TOTAL_RESULT_SET=$(expr $TOTAL_RESULT_SET + $RESULT_SET )
  done

echo "Total result of SET operation: $TOTAL_RESULT_SET"
}

########################
# REMOVE REDIS CONTAINERS
########################
function clean {
for i in `seq 1 $NUM_OF_CONTAINERS`;
  do
    c_name="redis$i"
    echo "Stop & remove container $i - $c_name"
    docker container stop $c_name
    docker container rm $c_name
    rm /tmp/$c_name.set.perf
  done
}

echo "Test Redis Performance ..."
echo "Usage: $0 <OPTION>"
echo "Available options: all, start, exec, report, clean"
OPT=$1
if [ -z $OPT ];
then
  OPT="all"
fi

echo "Used options: $OPT"

case $OPT in

  all)
    start
    exec
    report
    clean
    ;;

  start)
    start
    ;;

  exec)
    exec
    ;;

  report)
    report
    ;;

  clean)
    clean
    ;;

  *)
    echo "Unknown option"
    ;;
esac

