#!/bin/sh
# --------------------------------------------------------------------------
# rpathScript for linux 64bit
# --------------------------------------------------------------------------
# Processing Wrapper for the OpenNI/Kinect 2.0 library
# http://code.google.com/p/simple-openni
# --------------------------------------------------------------------------
# prog:  Max Rheiner / Interaction Design / zhdk / http://iad.zhdk.ch/
# date:  07/251/2013 (m/d/y)
# ----------------------------------------------------------------------------
# Set the rpaths for the libraries, the libs should have all the need shared
# objects in their folder	
# ----------------------------------------------------------------------------

cd ./dist/all/SimpleOpenNI/library

echo "--- change rpath for libSimpleOpenNI.so ---"

echo "--- change rpath for libSimpleOpenNI.so ---"

echo "--- generate cmake ---"
# changes this according to your environment
cmake -DCMAKE_BUILD_TYPE=Release \
	  -DOPEN_NI_BASE=/media/dataDisk/ownDev/libs/openni/git/OpenNI2/ \
          -DOPEN_NI_LIBDIR=./dist/all/SimpleOpenNI/library/linux64/ \
          -DNITE_BASE=/media/dataDisk/ownDev/libs/openni/git/NiTE-Linux-x64-2.2/ \
	  -DEIGEN3D_INCLUDE=/usr/local/include/eigen3/ \
	  -DBOOST_ROOT=/usr/include/boost/ \
	  -DBOOST_LIBRARYDIR=/usr/lib/ \
          -DP5_JAR=/media/dataDisk/ownDev/locApp/processing-2.0.1/core/library/core.jar \
          ..


echo "--- build ---"
# build with 6 threads, verbose is optional, but otherwise you can't see the compiler directives
#make -j 6 VERBOSE=1
make -j 6

echo "--- copy ---"
# copy the library
cp SimpleOpenNI.jar ../dist/all/SimpleOpenNI/library
cp libSimpleOpenNI*.so ../dist/all/SimpleOpenNI/library

# copy the doc
cp -r ./doc/* ../dist/all/SimpleOpenNI/documentation/

