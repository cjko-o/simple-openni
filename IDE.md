# Eclipse #

## Importing Libraries into Eclipse Project ##

**Import Processing Library**

see [http://processing.org/learning/eclipse](http://processing.org/learning/eclipse)

**Import Simple-OpenNI Library**

  * Go to: File>Import...>General>File System>
  * Browse “Library” folder of the download package, and check the “SimpleOpenNI.jar” file.
  * Select destination Project folder.
![http://simple-openni.googlecode.com/svn/site/screenshots/eclipse2.png](http://simple-openni.googlecode.com/svn/site/screenshots/eclipse2.png)
  * Right-Click “SimplelOpenNI.jar” and select “Build Path>Add to Buildpath”
  * Copy the “libSimpleOpenNI.jnilib”(OSX), or "libSimpleOpenNI.so"(Linux), or "libSimpleOpenNI.dll"(Windows) file from the download package into the projects “bin” folder.
  * Set the Native Library Location to your applications "bin" folder.
![http://simple-openni.googlecode.com/svn/site/screenshots/nativLib.png](http://simple-openni.googlecode.com/svn/site/screenshots/nativLib.png)
  * Import library by adding “import SimpleOpenNI.**;” to your sourcecode**

**Problems**

```
Exception in thread "Animation Thread" java.lang.UnsatisfiedLinkError: /Users/nuss/Documents/Documents/Education/ZHDK/IAD/Module/Bachelor/05_prototyp/code/lonely/bin/libSimpleOpenNI.jnilib:  no suitable image found.  Did find:  /Users/nuss/Documents/Documents/Education/ZHDK/IAD/Module/Bachelor/05_prototyp/code/lonely/bin/libSimpleOpenNI.jnilib: mach-o, but wrong architecture
	at java.lang.ClassLoader$NativeLibrary.load(Native Method)
	at java.lang.ClassLoader.loadLibrary0(ClassLoader.java:1823)
	at java.lang.ClassLoader.loadLibrary(ClassLoader.java:1738)
	at java.lang.Runtime.loadLibrary0(Runtime.java:823)
	at java.lang.System.loadLibrary(System.java:1045)
	at SimpleOpenNI.SimpleOpenNI.<clinit>(SimpleOpenNI.java:33)
	at lonely.setup(lonely.java:17)
	at processing.core.PApplet.handleDraw(PApplet.java:1583)
	at processing.core.PApplet.run(PApplet.java:1503)
	at java.lang.Thread.run(Thread.java:680)
```

**Force eclipse to run project in 32-bit mode**

  * Go to: Run>Run Configurations...>(x)=Arguments
  * Add “-d32” to “VM Arguments”
  * Apply changes
![http://simple-openni.googlecode.com/svn/site/screenshots/eclipse3.png](http://simple-openni.googlecode.com/svn/site/screenshots/eclipse3.png)

**Check Java Version and Settings**

  * Open Java Preferences: Applications/Utilities/Java Preferences
  * Make Sure that the 32-bit is on top (drag & drop)
![http://simple-openni.googlecode.com/svn/site/screenshots/eclipse1.png](http://simple-openni.googlecode.com/svn/site/screenshots/eclipse1.png)
  * Restart your computer
  * Open Terminal: Applications/Utilities/Terminal
  * Enter “java -version” and compare to the following:

```
java version "1.6.0_24"
Java(TM) SE Runtime Environment (build 1.6.0_24-b07-334-10M3326)
Java HotSpot(TM) Client VM (build 19.1-b02-334, mixed mode)
```