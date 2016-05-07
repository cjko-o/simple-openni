# Introduction #

Before you can use SimpleOpenNI you have to install Processing and OpenNI.

  * [Processing Installation](Installation#Processing.md)
  * [Windows Installation](Installation#Windows.md)
  * [OSX Installation](Installation#OSX.md)
  * [Linux Installation](Installation#Linux.md)

---


# Processing #

  * Download [Processing](http://processing.org/download/) for your platform and install it


---


# Windows #

**Install OpenNI,NITE and the Sensor Driver**
  * Download [Installation Package Win64](http://code.google.com/p/simple-openni/downloads/list?can=2&q=OpenNI_NITE_Installer+win64&colspec=Filename+Summary+Uploaded+ReleaseDate+Size+DownloadCount), or [Installation Package Win32](http://code.google.com/p/simple-openni/downloads/list?can=2&q=OpenNI_NITE_Installer+win32&colspec=Filename+Summary+Uploaded+ReleaseDate+Size+DownloadCount)
  * Start the OpenNI Installer
  * Start the NITE Installer
  * Start the Sensor Installer (Driver for Primesense Devices: Asus Xtion Pro,etc.)
  * Start the Kinect Installer (Driver for Kinect)

If everything worked out, you should see the camera in your Device Manager(under PrimeSensor : Kinect Camera, Kinect Motor).

**Install SimpleOpenNI (Processing < 2.0)**
  * Download [SimpleOpenNI](http://code.google.com/p/simple-openni/downloads/list?can=2&q=SimpleOpenNI&colspec=Filename+Summary+Uploaded+ReleaseDate+Size+DownloadCountt)
  * Copy the 'SimpleOpenNI.zip' into this folder:
> > C:\Users\'your username'\Documents\Processing\libraries
  * If you don't have this folder then create it.
  * If you use the **64bit** version, verify if you run Processing with 64bit. Mainly you have to install a [64bit Java version](http://www.oracle.com/technetwork/java/javase/downloads/jdk-7u2-download-1377129.html), also you have to remove the Java folder in the Processing folder.

---

# OSX #

I made a little installer(see Install OpenNI the short way), if this doesn't work for you, than you should install it the offical way. For my tests i used only OSX 10.6., with 10.5 i had some problems.

**Install OpenNI the short way**
  * Download the [Installer](http://code.google.com/p/simple-openni/downloads/list?can=2&q=Installer+osx)
  * Unzip the file and open a terminal window
  * Go to the unzipped folder 'OpenNI\_NITE\_Installer-OSX'
```
> cd ./OpenNI_NITE_Installer-OSX 
```
  * Start the installer
```
> sudo ./install.sh
```


**Install OpenNI the official way**

Those programs have to be on your system in order to install OpenNI:
  * [Xcode](http://developer.apple.com/technologies/tools/xcode.html)
  * [MacPorts](http://distfiles.macports.org/MacPorts/MacPorts-1.9.2-10.6-SnowLeopard.dmg)
  * [Java JDK](http://adcdownload.apple.com/Java/java_for_mac_os_x_10.6_update_3_developer_package/javadeveloper_10.6_10m3261.dmg)
  * [CMake](http://www.cmake.org/files/v2.8/cmake-2.8.3-Darwin-universal.dmg)(only if you plan to build the SimpleOpenNI library by yourself)

  * Install OpenNI

> Open the terminal and type in those commands:
```
> sudo port install git-core 
> sudo port install libtool
> sudo port install libusb-devel +universal
```

```
> mkdir ~/Development/Kinect
> cd Kinect
> tar xvf OpenNI-Bin-MacOSX-v1.0.0.25.tar.bz2
> sudo ./install.sh
```

```
> mkdir ~/Development/Kinect
> cd ~/Development/Kinect
> mkdir OpenNI
> mkdir Nite
> cd OpenNI
```

```
> tar xvf OpenNI-Bin-MacOSX-v1.0.0.25.tar.bz2
> sudo ./install.sh
```
...


**Install SimpleOpenNI (Processing < 2.0)**
  * Download [SimpleOpenNI](http://code.google.com/p/simple-openni/downloads/list?can=2&q=SimpleOpenNI&colspec=Filename+Summary+Uploaded+ReleaseDate+Size+DownloadCountt)
  * Copy the 'SimpleOpenNI.zip' into this folder:
> > /Users/'your username'/Documents/Processing/libraries
  * If you don't have this folder then create it.

---

# Linux #

**Install OpenNI,NITE and the Sensor Driver**

  * Download [Installation Package Linux64](http://code.google.com/p/simple-openni/downloads/list?can=2&q=Type%3DInstaller+OpSys%3DLinux+&colspec=Filename+Summary+Uploaded+ReleaseDate+Size+DownloadCount)
  * Uncompress all files to a folder
  * Install OpenNI:
```
> cd ./yourFolder/OpenNI-Bin-Linux64-v1.1.0.41 
> sudo ./install
```
  * Install Nite( the installer asks you for the key, enter this **0KOIk2JeIBYClPWVnMoRKn5cdY4=** ):
```
> cd ./yourFolder/Nite-1.3.1.5
> sudo ./install
```
  * Install Driver Kinect (only if you use a Kinect):

> decompress ./yourFolder/avin2-SensorKinect-28738dc/SensorKinect-Bin-Linux64-v5.0.1.32.tar.bz2
```
> cd ./yourFolder/SensorKinect-Bin-Linux64-v5.0.1.32
> sudo install
```
  * Install Driver Primesense (only if you use an Asus Xtion or the Primesense Developer Kit):
```
> cd ./yourFolder/Sensor-Bin-Linux64-v5.0.1.32
> sudo ./install
```

**Install SimpleOpenNI (Processing < 2.0)**
  * Download [SimpleOpenNI](http://code.google.com/p/simple-openni/downloads/list?can=2&q=SimpleOpenNI&colspec=Filename+Summary+Uploaded+ReleaseDate+Size+DownloadCountt)
  * Copy the 'SimpleOpenNI.zip' into this folder:
> > ~/sketchbook/libraries
  * If you don't have this folder then create it.