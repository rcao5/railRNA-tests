#!/bin/bash

while getopts p:d:o:t:m: option
do
	case "${option}"
	in
	p) PROCS=${OPTARG};;
	d) INTERM=${OPTARG};;
	o) BT1=${OPTARG};;
	t) BT2=${OPTARG};;
	m) MANIFEST=${OPTARG};;
	esac
done

BASEDIR=$(dirname "$0")
mkdir $BASEDIR/top_logs
mkdir $BASEDIR/run_logs

# loop over all core counts
for CORES in $(echo $PROCS | tr "," "\n")
do
	echo Running Rail with $CORES cores

	# start recording with top in background
	top -d 2 -b|grep --line-buffered "load average" -A 12 > $BASEDIR/top_logs/top_core_$CORES.log &
	TOPPID=$!

	# start rail
	rail-rna go local -x $BT1 $BT2 -m $MANIFEST -p $CORES --scratch $INTERM

	# kill background top
	kill $TOPPID

	cp $BASEDIR/rail-rna_logs/*.log $BASEDIR/run_logs/$CORES.log
	rm -rf $BASEDIR/rail-rna_logs/
	rm -rf $BASEDIR/rail-rna_out/
done
