#!/bin/bash

echo "killing mosquitto and cc"
#mos_pid=pidof "mosquitto"
#kill $mos_pid
cc_pid=$(pidof cluster-controller)
kill -9 $cc_pid
pkill -9 "mosquitto" 

exit 0
