#!/bin/bash
thisDir=$(pwd)

if [ ! -d "$thisDir/../mosquitto" ] ; then
  mkdir "$thisDir/../mosquitto"
  cd "$thisDir/../mosquitto"
  echo "downloading mosquitto"
  git clone https://github.com/eclipse/mosquitto.git .
  git checkout tags/v1.4.10
else
  echo "mosquitto already installed"
fi

cd "$thisDir/../mosquitto"
mkdir ./build
cd ./build
cmake ../
make

./src/mosquitto -d </dev/null 2>&1
