### If i start an example under linux i've got always a 'java.lang.UnsatisfiedLinkError' ? ###

Maybe you have the wrong version for your installation(32bit or 64bit).
If this is your full error log:
```
Exception in thread "Animation Thread" java.lang.UnsatisfiedLinkError:
/home/xx/sketchbook/libraries/SimpleOpenNI/library/libSimpleOpenNI.so:
/home/xx/sketchbook/libraries/SimpleOpenNI/library/libSimpleOpenNI.so: wrong ELF class: ELFCLASS64 (Possible cause: architecture word width mismatch)
	at java.lang.ClassLoader$NativeLibrary.load(Native Method)
	at java.lang.ClassLoader.loadLibrary0(ClassLoader.java:1803)
	at java.lang.ClassLoader.loadLibrary(ClassLoader.java:1728)
	at java.lang.Runtime.loadLibrary0(Runtime.java:823)
	at java.lang.System.loadLibrary(System.java:1028)
	at SimpleOpenNI.SimpleOpenNI.<clinit>(SimpleOpenNI.java:33)
	at Hands3d.setup(Hands3d.java:55)
	at processing.core.PApplet.handleDraw(Unknown Source)
	at processing.core.PApplet.run(Unknown Source)
	at java.lang.Thread.run(Thread.java:662)
```
Install the right version for your system.