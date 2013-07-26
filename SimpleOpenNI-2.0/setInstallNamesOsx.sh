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

cd ./dist/all/SimpleOpenNI/library/osx

echo "--- change rpath for libFreenectDriver.so ---"
install_name_tool -change libOpenNI2.dylib @loader_path/./libOpenNI2.dylib libNiTE2.dylib
