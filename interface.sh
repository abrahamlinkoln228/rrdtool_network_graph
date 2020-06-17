#!/bin/bash
# interface.sh - Network usage stats
#
# Copyright 2010 Frode Petterson. All rights reserved. Copied without reading licence.
# See README.rdoc for license. 

rrdtool=$(which rrdtool);
db0=ppp0.rrd
img=stats

if [ ! -e $db0 ]
then 
	$rrdtool create $db0 \
		-s 10 \
		DS:in:DERIVE:10:0:1250000000 \
		DS:out:DERIVE:10:0:1250000000 \
		RRA:MAX:0.5:1:360 \
		RRA:MAX:0.5:6:1440 \
		RRA:MAX:0.5:24:2520 \
		RRA:MAX:0.5:144:1800
fi

#Its just on commdand on swith interface {

#Why should I use exactly smtp protocol for accessing data flow information on specific switchport interface; THE MAIN advantage os SNMP;



in0=$(ifconfig enp1s0 | grep bytes | awk '{print $5}' | sed -n '1p')
out0=$(ifconfig enp1s0 | grep bytes | awk '{print $5}' | sed -n '2p')

#in1=$(ifconfig enp1s0 | grep bytes | cut -d ":" -f2 | cut -d " " -f1)
#out1=$(ifconfig enp1s0 | grep bytes | cut -d ":" -f3 | cut -d " " -f1)

$rrdtool updatev $db0 -t in:out N:$in0:$out0
#$rrdtool updatev $db1 -t in:out N:$in1:$out1

for period in hour day week month
do
	$rrdtool graph $img/hpz6-$period.png -s -1$period \
		-t "Network Traffic on HPZ600" \
		--lazy \
		--slope-mode \
		--alt-autoscale \
		--watermark 'Prison ' \
		-l 0 -a PNG -v bites/sec \
		DEF:in=$db0:in:MAX \
		DEF:out=$db0:out:MAX \
		CDEF:out_neg=out,-8,* \
		CDEF:outei=out,8,*	\
		CDEF:in_ei=in,8,*	\
		"AREA:in_ei#FFB3FF#AACCFF:Incoming" \
		"LINE:in_ei#00FFF0:Incoming" \
		"GPRINT:in_ei:MAX:  Max\\: %5.1lf %s" \
		"GPRINT:in_ei:AVERAGE: Avg\\: %5.1lf %S" \
		"GPRINT:in_ei:LAST: Current\\: %5.1lf %Sbits/sec\\n" \
		"AREA:out_neg#FF9900:Outgoing" \
		"LINE:out_neg#FF0000:Outgoing" \
		"GPRINT:outei:MAX:  Max\\: %5.1lf %S" \
		"GPRINT:outei:AVERAGE: Avg\\: %5.1lf %S" \
		"GPRINT:outei:LAST: Current\\: %5.1lf %Sbits/sec" \
		"HRULE:0#000000" \
        -h 334 -w 743 -l 0 -a PNG -v "b/s"  > /dev/null

	done
