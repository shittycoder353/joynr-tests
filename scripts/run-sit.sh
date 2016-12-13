#!/bin/bash
yourMosquitto="/usr/local/sbin/mosquitto"
timeStamp=$(date +"%y%m%d-%H%M%S")

# $1->deployDir
if [ "$1" != "" ] ; then
  [ -d "$1" ] || exit 1
  cd "$1"
else
  [ -d "../deploy" ] || exit 1
  cd "../deploy"
fi
thisDir=$(pwd) #deploy
touch "$thisDir/../testsXml/sit_$timeStamp.xml"
export GTEST_OUTPUT="xml:$thisDir/../testsXml/sit_$timeStamp.xml"

#############################
# starting jetty mosquitto cc
#############################
#jetty
echo "starting jetty"
cd "./discovery-directory-servlet" 
if pgrep "java" > /dev/null
then
  echo "jetty already runnnig"
else
  mvn jetty:run </dev/null 2>&1 &
fi
cd ..

#mosquitto
echo "starting mosquitto"
[ -e "$yourMosquitto" ] || exit 1
if pgrep "mosquitto" > /dev/null 
then
  echo "mosquitto already runnnig"
else
  $yourMosquitto -d </dev/null 2>&1
fi 

#cc
echo "starting cluster-controller"
[ -d "./cc" ] && rm -rf ./cc
mkdir ./cc
ln -s $thisDir/cluster-controller $thisDir/../deploy/cc/cluster-controller
ln -s $thisDir/resources/ $thisDir/../deploy/cc/resources
cd ./cc
if pgrep "cluster-controller" > /dev/null
then
  echo "cc already runnnig"
else
  ./cluster-controller ./resources/default-messaging.settings </dev/null 2>&1 &
fi
cd ..


#############################
# starting system g_SystemIntegrationTests
#############################
cd "$thisDir/../deploy"
[ -d "./sit" ] && rm -rf ./sit
mkdir ./sit
ln -s $thisDir/g_SystemIntegrationTests $thisDir/sit/g_SystemIntegrationTests
ln -s $thisDir/resources/ $thisDir/sit/resources
ln -s $thisDir/test-resources/ $thisDir/sit/test-resources
cd ./sit
./g_SystemIntegrationTests

echo "killing mosquitto and cc"
cc_pid=$(pidof cluster-controller)
kill -9 $cc_pid
pkill -9 "mosquitto" 

exit 0