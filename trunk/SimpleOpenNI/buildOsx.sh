#!/bin/sh
# --------------------------------------------------------------------------
# buildscript for linux 64bit
# --------------------------------------------------------------------------
# Processing Wrapper for the OpenNI/Kinect library
# http://code.google.com/p/simple-openni
# --------------------------------------------------------------------------
# prog:  Max Rheiner / Interaction Design / zhdk / http://iad.zhdk.ch/
# date:  06/11/2011 (m/d/y)
# ----------------------------------------------------------------------------

# optional, but gives a clean buil
rm -r build64

# check if build folder exists
if [ ! -d "build64" ]; then
    mkdir build64
fi

cd ./build64

echo "--- generate cmake ---"
cmake -DOPEN_NI_INCLUDE=/usr/include/openni/ \
	  -DXN_NITE_INCLUDE=/usr/include/nite/ \
	  -DXN_NITE_LIB=/usr/lib/ \
	  -DEIGEN3D_INCLUDE=/usr/include/eigen3/ \
	  -DBOOST_ROOT=~/Documents/development/libs/boost/boost_1_46_1/ \
	  -DBoost_LIBRARYDIR=/usr/local/lib/ \
	  -DP5_JAR=~/Documents/localApps/processing-1.5.1/lib/core.jar \
	  ..


echo "--- build ---"
# build with 6 threads, verbose is optional, but otherwise you can't see the compiler directives
# make -j 6 VERBOSE=1
make -j 6

echo "--- copy ---"
cp SimpleOpenNI.jar ~/sketchbook/libraries/SimpleOpenNI/library/
cp libSimpleOpenNI.so ~/sketchbook/libraries/SimpleOpenNI/library/
