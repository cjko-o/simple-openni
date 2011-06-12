#!/bin/sh
# --------------------------------------------------------------------------
# buildscript for osx 32bit/64bit
# --------------------------------------------------------------------------
# Processing Wrapper for the OpenNI/Kinect library
# http://code.google.com/p/simple-openni
# --------------------------------------------------------------------------
# prog:  Max Rheiner / Interaction Design / zhdk / http://iad.zhdk.ch/
# date:  06/11/2011 (m/d/y)
# ----------------------------------------------------------------------------

# optional, but gives a clean build
rm -r build

# check if build folder exists
if [ ! -d "build" ]; then
    mkdir build
fi

cd ./build

echo "--- generate cmake ---"
cmake -DOPEN_NI_INCLUDE=/usr/include/ni/ \
	  -DOPEN_NI_LIB=/usr/lib/ \
	  -DXN_NITE_INCLUDE=/usr/include/nite/ \
	  -DXN_NITE_LIB=/usr/lib/ \
	  -DEIGEN3D_INCLUDE=/usr/local/include/eigen3/ \
	  -DP5_JAR=/Applications/Processing.app/Contents/Resources/Java/core.jar \
	  -DCMAKE_OSX_ARCHITECTURES="i386;x86_64" \
	  ..

#	  -DBOOST_ROOT=~/Documents/development/libs/boost/boost_1_46_1/ \
#	  -DBOOST_LIBRARYDIR=/usr/local/lib/ \

echo "--- build ---"
# build with 6 threads, verbose is optional, but otherwise you can't see the compiler directives
make -j 6 VERBOSE=1


echo "--- copy ---"
cp SimpleOpenNI.jar ~/Documents/Processing/libraries/SimpleOpenNI/library
cp libSimpleOpenNI.jnilib ~/Documents/Processing/libraries/SimpleOpenNI/library
