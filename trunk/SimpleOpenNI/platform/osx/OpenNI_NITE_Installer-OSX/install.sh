#! /bin/sh

# *******************************************************************************
# SimpleOpenNI
# *******************************************************************************
# Installs all OpenNI/NITE libs 
# *******************************************************************************
# prog. Max Rheiner / Interaction Design / Zhdk
# *******************************************************************************

echo "-------- Install OpenNI/NITE ------------"

echo "copy OpenNI-Module..."
cp -R ./data/ni /var/lib/

echo "copy NITE-Conf..."
cp -R ./data/primesense /usr/etc/

# copy all dyn.libs
echo "copy OpenNI+NITE dynamic libs into /usr/lib"

# OpenNI
cp ./data/libOpenNI.dylib /usr/lib/
cp ./data/libnimCodecs.dylib /usr/lib/
cp ./data/libnimMockNodes.dylib /usr/lib/
cp ./data/libnimRecorder.dylib /usr/lib/

# NITE
cp ./data/libXnCore.dylib /usr/lib/
cp ./data/libXnDDK.dylib /usr/lib/
cp ./data/libXnDeviceFile.dylib /usr/lib/
cp ./data/libXnDeviceSensorV2.dylib /usr/lib/
cp ./data/libXnFormats.dylib /usr/lib/
cp ./data/libXnVCNite.dylib /usr/lib/
cp ./data/libXnVFeatures.dylib /usr/lib/
cp ./data/libXnVHandGenerator.dylib /usr/lib/
cp ./data/libXnVNite.dylib /usr/lib/

# libusb
echo "copy libusb dynamic libs into /opt/local/lib"
cp ./data/libusb-1.0.0.dylib /opt/local/lib/

echo "-------- Done Install OpenNI/NITE ------------"
