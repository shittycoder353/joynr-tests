#!/bin/bash

thisDir=$(pwd)
timeStamp=$(date +"%y%m%d-%H%M%S")


if [ -d "$thisDir/../testsXml" ] ; then
  [[ -d "$thisDir/../testsXml-old" ]] || mkdir "$thisDir/../testsXml-old"
  cp -vR "$thisDir/../testsXml/." "$thisDir/../testsXml-old/"
  rm -rf $thisDir/../testsXml/*
fi
  
  
