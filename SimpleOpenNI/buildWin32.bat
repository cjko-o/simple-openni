rem "build SimpleOpenNI 32bit"
mkdir build32
cd build32
cmake -G "Visual Studio 9 2008" ^
-DMACH_ARCH="32" ^
-DCMAKE_BUILD_TYPE=Release ^
-DOPEN_NI_INCLUDE="C:\Program Files (x86)\OpenNI\Include" ^
-DOPEN_NI_LIB="C:\Program Files (x86)\OpenNI\Lib" ^
-DXN_NITE_INCLUDE="C:\Program Files (x86)\PrimeSense\NITE\Include" ^
-DXN_NITE_LIB="C:\Program Files (x86)\PrimeSense\NITE\Lib" ^
-DNITE_VERSION="1_5_2" ^
-DEIGEN3D_INCLUDE=C:\Users\Public\Documents\development\libs\graphics\3d\eigen\eigen-eigen-c40708b9088d ^
-DBOOST_ROOT=C:\Users\Public\Documents\development\libs\os\boost\boost_1_46_1-win32 ^
..
cd ..