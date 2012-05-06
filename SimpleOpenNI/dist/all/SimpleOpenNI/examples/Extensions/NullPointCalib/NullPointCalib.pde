/* --------------------------------------------------------------------------
 * SimpleOpenNI NullPointCalib Test
 * --------------------------------------------------------------------------
 * Processing Wrapper for the OpenNI/Kinect library
 * http://code.google.com/p/simple-openni
 * --------------------------------------------------------------------------
 * prog:  Max Rheiner / Interaction Design / zhdk / http://iad.zhdk.ch/
 * date:  05/06/2012 (m/d/y)
 * ----------------------------------------------------------------------------
 */

import SimpleOpenNI.*;

final static int CALIB_START     = 0;
final static int CALIB_NULLPOINT = 1;
final static int CALIB_X_POINT   = 2;
final static int CALIB_Z_POINT   = 3;
final static int CALIB_DONE      = 4;

SimpleOpenNI  context;
boolean       screenFlag = true;
int           calibMode = CALIB_START;

PVector   nullPoint3d = new PVector();
PVector   xDirPoint3d = new PVector();
PVector   zDirPoint3d = new PVector();
PVector   tempVec1 = new PVector();
PVector   tempVec2 = new PVector();
PVector   tempVec3 = new PVector();

void setup()
{  
  size(640,480);
  smooth();
  
  context = new SimpleOpenNI(this);
   
  // mirror is by default enabled
  context.setMirror(true);
  
  // enable depthMap generation 
  if(context.enableDepth() == false)
  {
     println("Can't open the depthMap, maybe the camera is not connected!"); 
     exit();
     return;
  }
 
  if(context.enableRGB() == false)
  {
     println("Can't open the rgbMap, maybe the camera is not connected or there is no rgbSensor!"); 
     exit();
     return;
  }
  
  // align depth data to image data
  context.alternativeViewPointDepthToImage();
  
  // Create the font
  textFont(createFont("Georgia",16));
}

void draw()
{
  // update the cam
  context.update();
  
  if(screenFlag)
    image(context.rgbImage(),0,0);
  else
    image(context.depthImage(),0,0);
  
  switch(calibMode)
  {
  case CALIB_START:
    text("To start the calibration press SPACE!", 5, 30);
    break;
  case CALIB_NULLPOINT:
    text("Set the nullpoint with the left mousebutton", 5, 30);
    break;
  case CALIB_X_POINT:
    text("Set the x-axis with the left mousebutton", 5, 30);
    break;
  case CALIB_Z_POINT:
    text("Set the z-axis with the left mousebutton", 5, 30);
    break;
  case CALIB_DONE:
    text("New nullpoint is defined!", 5, 30);
    break;
  }
  
  // draw 
  drawCalibPoint();
  
  // draw user def coordsys
  if(context.hasUserCoordsys())
  {
      pushStyle();
      context.getOrigUserCoordsys();
      popStyle();  
  }

}

void drawCalibPoint()
{
  pushStyle();

  strokeWeight(3);
  noFill();
  
  switch(calibMode)
  {
  case CALIB_START:    
    break;
  case CALIB_NULLPOINT:
    context.convertRealWorldToProjective(nullPoint3d,tempVec1);

    stroke(255,255,255,150);
    ellipse(tempVec1.x,tempVec1.y,10,10);  
    break;
  case CALIB_X_POINT:
    // draw the null point
    context.convertRealWorldToProjective(nullPoint3d,tempVec1);
    context.convertRealWorldToProjective(xDirPoint3d,tempVec2);
 
    stroke(255,255,255,150);
    ellipse(tempVec1.x,tempVec1.y,10,10);  

    stroke(255,0,0,150);
    ellipse(tempVec2.x,tempVec2.y,10,10);  
    line(tempVec1.x,tempVec1.y,tempVec2.x,tempVec2.y);
    
    break;
  case CALIB_Z_POINT:
  
    context.convertRealWorldToProjective(nullPoint3d,tempVec1);
    context.convertRealWorldToProjective(xDirPoint3d,tempVec2);
    context.convertRealWorldToProjective(zDirPoint3d,tempVec3);
 
    stroke(255,255,255,150);
    ellipse(tempVec1.x,tempVec1.y,10,10);  

    stroke(255,0,0,150);
    ellipse(tempVec2.x,tempVec2.y,10,10);  
    line(tempVec1.x,tempVec1.y,tempVec2.x,tempVec2.y);

    stroke(0,255,0,150);
    ellipse(tempVec3.x,tempVec3.y,10,10);  
    line(tempVec1.x,tempVec1.y,tempVec3.x,tempVec3.y);
  
    break;
  case CALIB_DONE:
    

    break;
  }
  
  popStyle();
}

void keyPressed()
{
  switch(key)
  {
  case '1': 
    screenFlag = !screenFlag; 
    break;
  case ' ': 
    calibMode++;
    if(calibMode > CALIB_DONE)
      calibMode = CALIB_START; 
    else if(calibMode == CALIB_DONE)
    {  // set the calibration
      println("Set the user define coordinatesystem");
      context.setUserCoordsys();
      
    }
    
    break;    
  }
}  

void mousePressed() 
{
  PVector[] realWorldMap = context.depthMapRealWorld();
  int index = mouseX + mouseY * context.depthWidth();
  
  switch(calibMode)
  {
  case CALIB_NULLPOINT:
    nullPoint3d.set(realWorldMap[index]);
    println("set nullpoint");
    break;
  case CALIB_X_POINT:
    xDirPoint3d.set(realWorldMap[index]);
    break;
  case CALIB_Z_POINT:
    zDirPoint3d.set(realWorldMap[index]);
    break;
  } 
}
