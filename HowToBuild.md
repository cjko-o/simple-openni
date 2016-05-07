# Introduction #

The build system is based on CMake, so it should be easy to build the project on your platform.

  * [Preparation](HowToBuild#Preparation.md)
  * [Windows](HowToBuild#Windows.md)
  * [OSX ](HowToBuild#OSX.md)
  * [UNIX/Linux](HowToBuild#UNIX/Linux.md)

---

# Preparation #

Before you can build the library you should install following tools:
  * [OpenNI + NITE](http://www.openni.org/)
  * [Java Development Kit](https://cds.sun.com/is-bin/INTERSHOP.enfinity/WFS/CDS-CDS_Developer-Site/en_US/-/USD/ViewProductDetail-Start?ProductRef=jdk-6u24-oth-JPR@CDS-CDS_Developer) (should be installed on OSX)
  * [CMake](http://www.cmake.org/cmake/resources/software.html)
  * [Swig](http://www.swig.org/download.html) >= **v2.0.2**
  * [Eigen](http://eigen.tuxfamily.org) >= **v3.0**
  * [Boost](http://www.boost.org/) >= **v1.46** (use the static build)
Boost build tips for OSX(32/64bit version):
```
> cd boost_folderXY
> sudo ./bjam link=static architecture=x86 address-model=32_64 install
```
Boost build tips for Linux(64bit version):
```
> cd boost_folderXY
> ./bjam link=static cxxflags=-fPIC
```
I did run into troubles with the shared lib version of boost and the static lib version. Also i did get problems when i linked the static lib version to SimpleOpenNI without the -fPIC flag.


---

# Windows #

On windows i only used Visual Studio 2008
  * Download the souces from the svn
  * Open a terminal and go into the 'SimpleOpenNI' folder
  * Type those commands:
```
> mkdir build
> cd build
> cmake -DEIGEN3D_INCLUDE='path to the Eigen folder' -DBOOST_ROOT='path to the Boost folder' ..
```
  * Now you should find in the 'SimpleOpenNI/build' folder the Visual Studio Projectfile
  * Open 'SimpleOpenNI.sln' and build it

---

# OSX 32/64bit #

On OSX you need [Xcode](http://developer.apple.com/technologies/xcode.html) in order to compile the sources. Processing should be installed in the applications-folder.

  * Download the souces from the svn
  * Open a terminal and go into the 'SimpleOpenNI' folder
  * Change the paths to your local ones in those two files:  buildOsx.sh, installOsx.sh (There is more info in the files)
  * Type those commands:
```
> ./buildOsx.sh
> ./installOsx.sh
```

---

# UNIX/Linux #

  * Download the souces from the svn
  * Open a terminal and go into the 'SimpleOpenNI' folder
  * Change the paths to your local ones in those two files:  buildLinux64.sh or buildLinux32, installLinux.sh (There is more info in the files)
  * Type those commands:
```
> ./buildLinux64.sh
> ./installLinux.sh
```