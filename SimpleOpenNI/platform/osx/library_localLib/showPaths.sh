#! /bin/sh

# *******************************************************************************
# SimpleOpenNI
# *******************************************************************************
# Shows all depencencies of the dynlibs
# *******************************************************************************
# prog. Max Rheiner / Interaction Design / Zhdk
# *******************************************************************************

echo "-------- SimpleOpenNI - Show dependencies ------------"

otool -L libSimpleOpenNI.jnilib

otool -L libOpenNI.dylib
otool -L libnimCodecs.dylib
otool -L libnimMockNodes.dylib
otool -L libnimRecorder.dylib

otool -L libXnCore.dylib
otool -L libXnDDK.dylib
otool -L libXnDeviceFile.dylib
otool -L libXnDeviceSensorV2.dylib
otool -L libXnFormats.dylib
otool -L libXnVCNite.dylib
otool -L libXnVFeatures.dylib
otool -L libXnVHandGenerator.dylib
otool -L libXnVNite.dylib

echo "------------------------------------------------------------"
