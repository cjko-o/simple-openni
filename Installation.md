# Introduction #

Before you can use SimpleOpenNI you have to install Processing and OpenNI.

  * [Processing Installation](Installation#Processing.md)
  * [Windows Installation](Installation#Windows.md)
  * [OSX Installation](Installation#OSX.md)
  * [Linux Installation](Installation#Linux.md)

---


# Processing #

  * Download [Processing >= 2.0](http://processing.org/download/) for your platform and install it
  * Go to the menu: Sketch-> Import Library...-> Add Library...
  * Select and install SimpleOpenNI

or Download as file:
  * Download [SimpleOpenNI](https://simple-openni.googlecode.com/svn/trunk/SimpleOpenNI-2.0/dist/all/SimpleOpenNI.zip)
  * Copy the extracted folder in your Processing library folder
    * Windows: C:\Users\'your username'\Documents\Processing\libraries
    * Linux: ~/sketchbook/libraries
    * OSX: /Users/'your username'/Documents/Processing/libraries

---


# Windows #

**Install Kinect SDK
  * Download [Kinect SDK](http://go.microsoft.com/fwlink/?LinkId=275588) from the [Developer Page](http://www.microsoft.com/en-us/kinectforwindows/develop/developer-downloads.aspx)
  * Start the Kinect SDK Installer**

If everything worked out, you should see the plugged camera in your Device Manager(under 'Kinect for Windows').
In case you have an error when you startup a processing sketch with SimpleOpenNI, try to install the [Runtime Libraries](http://www.microsoft.com/en-us/download/details.aspx?id=29) from Microsoft.



---

# OSX #

Don't need to install, should work out of the box.

---

# Linux #

  * Install OpenNI Device Rules
```
cd ~/Downloads
wget https://simple-openni.googlecode.com/svn/trunk/SimpleOpenNI-2.0/platform/linux/installLinuxRules.sh
wget https://simple-openni.googlecode.com/svn/trunk/SimpleOpenNI-2.0/platform/linux/primesense-usb.rules
sudo ./installLinuxRules.sh
```