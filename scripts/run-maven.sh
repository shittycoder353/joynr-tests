#!/bin/bash
thisDir=$(pwd)

if [ ! -d "$thisDir/../maven" ] ; then
  mkdir "$thisDir/../maven"
  cd "$thisDir/../maven"
  echo "downloading maven"
  wget http://mirror.olnevhost.net/pub/apache/maven/binaries/apache-maven-3.2.2-bin.tar.gz
  tar xvf apache-maven-3.2.2-bin.tar.gz
else
  echo "maven already installed"
fi

cd $thisDir/../deploy/discovery-directory-servlet
$thisDir/../maven/apache-maven-3.2.2/bin/mvn jetty:run

#$thisDir/../maven/apache-maven-3.2.2/bin/mvn $thisDir/../deploy/discovery-directory-servlet/jetty:run
  
