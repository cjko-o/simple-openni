#! /bin/sh

# *******************************************************************************
# SimpleOpenNI
# *******************************************************************************
# This script changes all abs.file refs to @load_path
# *******************************************************************************
# prog. Max Rheiner / Interaction Design / Zhdk
# *******************************************************************************

echo "-------- SimpleOpenNI - Change lib dependencies ------------"

echo "libSimpleOpenNI.jnilib"
install_name_tool -change ../../Bin/Release/libOpenNI.dylib @loader_path/libOpenNI.dylib libSimpleOpenNI.jnilib
#install_name_tool -change /Users/max/development/ownDev/SimpleOpenNI/expLibFolder/libOpenNI.dylib  @loader_path/libOpenNI.dylib libSimpleOpenNI.jnilib

echo "libOpenNI.dylib"
install_name_tool -change ../../Bin/Release/libOpenNI.dylib @loader_path/libOpenNI.dylib libOpenNI.dylib

echo "libnimCodecs.dylib"
install_name_tool -change ../../Bin/Release/libOpenNI.dylib @loader_path/libOpenNI.dylib libnimCodecs.dylib

echo "libnimMockNodes.dylib"
install_name_tool -change ../../Bin/Release/libOpenNI.dylib @loader_path/libOpenNI.dylib libnimMockNodes.dylib

echo "libnimRecorder.dylib"
install_name_tool -change ../../Bin/Release/libOpenNI.dylib @loader_path/libOpenNI.dylib libnimRecorder.dylib



echo "libXnCore.dylib"
install_name_tool -change ../../Bin/Release/libOpenNI.dylib @loader_path/libOpenNI.dylib libXnCore.dylib


echo "libXnDDK.dylib"
install_name_tool -change ../../Bin/Release/libOpenNI.dylib @loader_path/libOpenNI.dylib libXnDDK.dylib
install_name_tool -change ../../Bin/Release/libXnCore.dylib @loader_path/libXnCore.dylib libXnDDK.dylib
install_name_tool -change ../../Bin/Release/libXnFormats.dylib @loader_path/libXnFormats.dylib libXnDDK.dylib

echo "libXnDeviceFile.dylib"
install_name_tool -change ../../Bin/Release/libOpenNI.dylib @loader_path/libOpenNI.dylib libXnDeviceFile.dylib
install_name_tool -change ../../Bin/Release/libXnCore.dylib @loader_path/libXnCore.dylib libXnDeviceFile.dylib
install_name_tool -change ../../Bin/Release/libXnFormats.dylib @loader_path/libXnFormats.dylib libXnDeviceFile.dylib
install_name_tool -change ../../Bin/Release/libXnDDK.dylib @loader_path/libXnDDK.dylib libXnDeviceFile.dylib

echo "libXnDeviceSensorV2.dylib"
install_name_tool -change ../../Bin/Release/libOpenNI.dylib @loader_path/libOpenNI.dylib libXnDeviceSensorV2.dylib
install_name_tool -change ../../Bin/Release/libXnCore.dylib @loader_path/libXnCore.dylib libXnDeviceSensorV2.dylib
install_name_tool -change ../../Bin/Release/libXnFormats.dylib @loader_path/libXnFormats.dylib libXnDeviceSensorV2.dylib
install_name_tool -change ../../Bin/Release/libXnDDK.dylib @loader_path/libXnDDK.dylib libXnDeviceSensorV2.dylib

echo "libXnFormats.dylib"
install_name_tool -change ../../Bin/Release/libOpenNI.dylib @loader_path/libOpenNI.dylib libXnFormats.dylib
install_name_tool -change ../../Bin/Release/libXnCore.dylib @loader_path/libXnCore.dylib libXnFormats.dylib

echo "libXnVCNite.dylib"
install_name_tool -change ../../Bin/Release/libOpenNI.dylib @loader_path/libOpenNI.dylib libXnVCNite.dylib
install_name_tool -change ../../Bin/Release/libXnVNite.dylib @loader_path/libXnVNite.dylib libXnVCNite.dylib

echo "libXnVFeatures.dylib"
install_name_tool -change ../../Bin/Release/libOpenNI.dylib @loader_path/libOpenNI.dylib libXnVFeatures.dylib

echo "libXnVHandGenerator.dylib"
install_name_tool -change ../../Bin/Release/libOpenNI.dylib @loader_path/libOpenNI.dylib libXnVHandGenerator.dylib

echo "libXnVNite.dylib"
install_name_tool -change ../../Bin/Release/libOpenNI.dylib @loader_path/libOpenNI.dylib libXnVNite.dylib


echo "------------------------------------------------------------"
