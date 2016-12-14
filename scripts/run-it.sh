#!/bin/bash
timeStamp=$(date +"%y%m%d-%H%M%S")
# $1->deployDir
if [ "$1" != "" ] ; then
  [ -d "$1" ] || exit 1
  cd "$1"
else
  [ -d "../deploy" ] || exit 1
  cd "../deploy"
fi
thisDir=$(pwd)
[ -d "./it" ] && rm -rf ./it
mkdir ./it
ln -s $thisDir/g_IntegrationTests $thisDir/it/g_IntegrationTests
ln -s $thisDir/resources/ $thisDir/it/resources
ln -s $thisDir/*.so* $thisDir/it/ 
cd ./it

touch "$thisDir/../testsXml/it_$timeStamp.xml"
export GTEST_OUTPUT="xml:$thisDir/../testsXml/it_$timeStamp.xml"
./g_IntegrationTests

exit 0