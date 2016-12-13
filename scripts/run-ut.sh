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
[ -d "./ut" ] && rm -rf ./ut
mkdir ./ut
ln -s $thisDir/g_UnitTests $thisDir/ut/g_UnitTests
ln -s $thisDir/resources/ $thisDir/ut/resources
cd ./ut

touch "$thisDir/../testsXml/ut_$timeStamp.xml"
export GTEST_OUTPUT="xml:$thisDir/../testsXml/ut_$timeStamp.xml"
./g_UnitTests

exit 0