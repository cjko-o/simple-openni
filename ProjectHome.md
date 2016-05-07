# Introduction #
This project is a simple [OpenNI](http://www.openni.org/) and [NITE](http://www.primesense.com/?p=515) wrapper for [Processing](http://www.processing.org/). Therefore not all functions of OpenNI are supported, it's meant more to deliver a simple access to the functionality of this library.

# News #
For a detailed list of changes see the [ChangeLog](http://simple-openni.googlecode.com/svn/trunk/SimpleOpenNI/ChangeLog.txt)

  * Version 1.96
    * Support for Win32/64, OSX32/64, Linux64
    * [Installation is](https://code.google.com/p/simple-openni/wiki/Installation?ts=1377782923&updated=Installation) now much simpler
  * --- OpenNI2 ---
  * Version 0.26
    * Added the autocalibration, now you can only enter the scene and get the skeleton data without the psi pose
    * Updated the examples to enable auto-calibration (User, User3d)
    * Unified the SimpleOpenNI distribution library, from now there is only one library distribution for OSX,Windows and Linux. Had to make this change because of the Processing 2.0 autoinstaller.
    * SimpleOpenNI tries on windows/linux to find automatically the valid architecture(32bit/64bit), depending on java machine you use. On OSX this works already through the universal libraries. SimpleOpenNI will print out which version it uses.
    * Updated the wiki-install doc(thanks to Bradley Henke)

> [Older logs](http://simple-openni.googlecode.com/svn/trunk/SimpleOpenNI/ChangeLog.txt)

# Installation #
http://code.google.com/p/simple-openni/wiki/Installation

# Examples #

This examples shows, how to display the depthMap and the camera:
```
import SimpleOpenNI.*;

SimpleOpenNI  context;

void setup()
{
  context = new SimpleOpenNI(this);
   
  // enable depthMap generation 
  context.enableDepth();
  
  // enable camera image generation
  context.enableRGB();
 
  background(200,0,0);
  size(context.depthWidth() + context.rgbWidth() + 10, context.rgbHeight()); 
}

void draw()
{
  // update the cam
  context.update();
  
  // draw depthImageMap
  image(context.depthImage(),0,0);
  
  // draw camera
  image(context.rgbImage(),context.depthWidth() + 10,0);
}
```

http://code.google.com/p/simple-openni/wiki/Examples

# Screenshots #
![![](http://simple-openni.googlecode.com/svn/site/screenshots/NiteSlider2d_small.jpg)](http://simple-openni.googlecode.com/svn/site/screenshots/NiteSlider2d.jpg)


![![](http://simple-openni.googlecode.com/svn/site/screenshots/NiteHands_small.jpg)](http://simple-openni.googlecode.com/svn/site/screenshots/NiteHands.jpg)
![![](http://simple-openni.googlecode.com/svn/site/screenshots/NiteCircle_small.jpg)](http://simple-openni.googlecode.com/svn/site/screenshots/NiteCircle.jpg)

![![](http://simple-openni.googlecode.com/svn/site/screenshots/UserScene3d_small.jpg)](http://simple-openni.googlecode.com/svn/site/screenshots/UserScene3d.jpg)
![![](http://simple-openni.googlecode.com/svn/site/screenshots/User3dOri_small.jpg)](http://simple-openni.googlecode.com/svn/site/screenshots/User3dOri.jpg)

![![](http://simple-openni.googlecode.com/svn/site/screenshots/User3d1_small.jpg)](http://simple-openni.googlecode.com/svn/site/screenshots/User3d1.jpg)
![![](http://simple-openni.googlecode.com/svn/site/screenshots/Hands3d_small.jpg)](http://simple-openni.googlecode.com/svn/site/screenshots/Hands3d.jpg)

![![](http://simple-openni.googlecode.com/svn/site/screenshots/UserTest_small.jpg)](http://simple-openni.googlecode.com/svn/site/screenshots/UserTest.jpg)


# Acknowledgments #

This project was developed for a workshop at the [Interaction Design Department Zurich](http://iad.zhdk.ch/en) / [ZHDK](http://www.zhdk.ch/)