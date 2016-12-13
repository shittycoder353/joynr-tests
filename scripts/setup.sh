#!/bin/bash
thisDir=$(pwd)
joynrVer="0.21.4"
cmakeCmds="-DUSE_PLATFORM_SPDLOG=OFF -DUSE_PLATFORM_MUESLI=ON -DUSE_PLATFORM_MOSQUITTO=ON -DUSE_PLATFORM_GTEST_GMOCK=ON -DUSE_PLATFORM_WEBSOCKETPP=OFF -DJOYNR_ENABLE_DLT_LOGGING=ON -DJOYNR_ENABLE_STDOUT_LOGGING=ON -DUSE_DBUS_COMMONAPI_COMMUNICATION=OFF -DBUILD_TESTS=ON -DENABLE_GCOV=OFF -DENABLE_DOXYGEN=OFF -DBUILD_CLUSTER_CONTROLLER=ON"
timeStamp=$(date +"%y%m%d-%H%M%S")


msg() {
# $1->color | $2->msg | $3->$logFile
# red   = 1
# green = 2
# cyan  = 6
# white = 9
# if you using tee you get return val be ${PIPESTATUS[0]}"
# make | tee someLog.log
# echo "${PIPESTATUS[0]} ${PIPESTATUS[1]}"
echo "$(tput setaf $1)$2$(tput setaf 9)"
echo "$2" >> "$3"
}

[[ -d "$thisDir/../logs" ]] || mkdir -p "$thisDir/../logs"
touch "$thisDir/../logs/joynr-tests-$timeStamp.log"
logFile="$thisDir/../logs/joynr-tests-$timeStamp.log"

if [ ! -d "$thisDir/../deploy" ] ; then 
  msg 2 "[info]...creating directory $thisDir/../deploy" $logFile
  mkdir -p $thisDir/../deploy
fi

#######################
# checking cloning/copy joynr from git/local, init git and checkout to right version
#######################
git clone https://github.com/bmwcarit/joynr.git $thisDir/../download/joynr_$joynrVer  >> $logFile
#if [ "${PIPESTATUS[0]}" != "0" ] ; then
#  msg 1 "[erro]... clone" $logFile
#  exit 2
#fi

msg 2 "[info]...checkout joynr to version $joynrVer" $logFile
cd $thisDir/../download/joynr_$joynrVer
git checkout tags/$joynrVer >> $logFile
cd $thisDir
#if [ "${PIPESTATUS[0]}" != "0" ] ; then
#  msg 1 "[erro]... checkout" $logFile
#  exit 2
#fi

#######################
# download joynr-generator and generating files via generator
#######################
cd $thisDir/../download/joynr_$joynrVer
if [ -e "$thisDir/../download/joynr_$joynrVer/joynr-generator-standalone-$joynrVer.jar" ] ; then
  msg 2 "[info]...joynr-generator-standalone-$joynrVer.jar was found $thisDir/../download/joynr_$joynrVer/joynr-generator-standalone-$joynrVer.jar" $logFile
else
  msg 2 "[info]...downloading joynr-generator-standalone-$joynrVer.jar from http://central.maven.org/maven2/io/joynr/tools/generator/joynr-generator-standalone/$joynrVer/joynr-generator-standalone-$joynrVer.jar" $logFile
  joynrGeneratorNotFound="0.21.2"
  joynrGeneratorFound="0.21.1"
  if [ "$joynrVer" == "$joynrGeneratorNotFound" ] ; then 
    wget http://central.maven.org/maven2/io/joynr/tools/generator/joynr-generator-standalone/$joynrGeneratorFound/joynr-generator-standalone-$joynrGeneratorFound.jar
    [ -e "joynr-generator-standalone-$joynrGeneratorFound.jar" ] && mv joynr-generator-standalone-$joynrGeneratorFound.jar joynr-generator-standalone-$joynrVer.jar
  else
    wget http://central.maven.org/maven2/io/joynr/tools/generator/joynr-generator-standalone/$joynrVer/joynr-generator-standalone-$joynrVer.jar
  fi
  #if [ "${PIPESTATUS[0]}" != "0" ]; then
  #  msg 1 "[erro]...joynr-generator-standalone-$joynrVer was not downloaded FATAL ERROR" $logFile
  #  exit 5
  #fi
fi


msg 2 "[info]...generating cpp files for cpp joynr from <joynrDir>/basemodel/src/main/franca/ to <joynrDir>/cpp/libjoynr/" $logFile
java -jar joynr-generator-standalone-$joynrVer.jar -outputPath ./cpp/libjoynr/ -modelpath ./basemodel/src/main/franca/ -generationLanguage cpp
java -jar ./joynr-generator-standalone-$joynrVer.jar -outputPath ./cpp/tests/gen -modelpath ./basemodel/src/test/franca/ -generationLanguage cpp
#if [ "${PIPESTATUS[0]}" != "0" ]; then
#  msg 1 "[erro]...cpp files was not generated from <joynrDir>/basemodel/src/main/franca/ to <joynrDir>/cpp/libjoynr/ via joynr-generator-standalone-$joynrVer FATAL ERROR" $logFile
#  exit 5
#fi

#######################
# run cmake and make for joynr
#######################
[ "$setupMode" == "dev" ] && exit 0
[[ -d "$thisDir/../download/joynr_$joynrVer/cpp/build" ]] || rm -rf $thisDir/../download/joynr_$joynrVer/cpp/build
mkdir "$thisDir/../download/joynr_$joynrVer/cpp/build"

cd $thisDir/../download/joynr_$joynrVer/cpp/build
msg 2 "[info]...run cmake for joynr cpp files" $logFile
cmake $cmakeCmds ../ | tee -a $logFile
#cmake ../
#if [ "${PIPESTATUS[0]}" != "0" ]; then
#  msg 1 "[erro]...cmake" $logFile
#  exit 6
#fi
msg 2 "[info]...run make for joynr cpp files" $logFile
make -j4 | tee -a $logFile
#make
#if [ "${PIPESTATUS[0]}" != "0" ]; then
#  msg 1 "[erro]...make" $logFile
#  exit 6
#fi

#######################
# copy builded files to deploy dir
#######################
[[ -d "$thisDir/../deploy" ]] && rm -rf "$thisDir/../deploy"

[[ -d "$thisDir/../deploy" ]] && rm -rf "$thisDir/../deploy"
if [ ! -d "$thisDir/../deploy" ] ; then 
  msg 2 "[info]...creating directory $thisDir/../deploy" $logFile
  mkdir -p $thisDir/../testsXml
fi

msg 2 "[info]...copy tests files to deploy dir: $thisDir/../deploy" $logFile
cp -rf "$thisDir/../download/joynr_$joynrVer/cpp/build/bin/" "$thisDir/../deploy"

msg 2 "[info]...copy backened-services files to deploy dir: $thisDir/../deploy/backend-services/discovery-directory-servlet" $logFile
cp -rf "$thisDir/../download/joynr_$joynrVer/java/backend-services/discovery-directory-servlet" "$thisDir/../deploy/"


