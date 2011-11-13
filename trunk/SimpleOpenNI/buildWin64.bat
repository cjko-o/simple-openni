rem "build SimpleOpenNI 64bit"
mkdir build64
cd build64
cmake -G "Visual Studio 9 2008 Win64" ^
-DOPEN_NI_INCLUDE="C:\Program Files\OpenNI\Include" ^
-DOPEN_NI_LIB="C:\Program Files\OpenNI\Lib64" ^
-DXN_NITE_INCLUDE="C:\Program Files\PrimeSense\NITE\Include" ^
-DXN_NITE_LIB="C:\Program Files\PrimeSense\NITE\Lib64" ^
-DEIGEN3D_INCLUDE="C:\Users\Public\Documents\development\libs\graphics\3d\eigen\eigen-eigen-c40708b9088d" ^
-DBOOST_ROOT="C:\Users\Public\Documents\development\libs\os\boost\boost_1_46_1" ^
..
cd ..