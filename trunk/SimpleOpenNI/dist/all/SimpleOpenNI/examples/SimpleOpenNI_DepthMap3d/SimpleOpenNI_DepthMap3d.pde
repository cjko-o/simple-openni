/* --------------------------------------------------------------------------
 * SimpleOpenNI DepthMap3d Test
 * --------------------------------------------------------------------------
 * Processing Wrapper for the OpenNI/Kinect library
 * http://code.google.com/p/simple-openni
 * --------------------------------------------------------------------------
 * prog:  Max Rheiner / Interaction Design / zhkd / http://iad.zhdk.ch/
 * date:  02/16/2011 (m/d/y)
 * ----------------------------------------------------------------------------
 */
import SimpleOpenNI.*;

SimpleOpenNI context;
float        zoomF = 0.07f;
float        rotX = radians(-30.0f);
float        rotY = radians(-35.0f);

void setup()
{
  context = new SimpleOpenNI(this,"SamplesConfig.xml");
   
  // enable depthMap generation 
  context.enableDepth();
  // set the depthImage base color
  context.setDepthImageColor(255,255,255);
 
  size(800,600,P3D); 
  stroke(255,255,255);
  smooth();
  perspective(95,
              float(width)/float(height), 
              500,150000);

}

void draw()
{
  // update the cam
  context.update();

  background(0,0,0);
  
  translate(width/2, height/2, 0);
  rotateX(rotX);
  rotateY(rotY);
  scale(zoomF);
  
  int[] depthMap = context.depthMap();
  int   steps   = 2;
  float xDist   = 5.0f;
  float yDist   = 5.0f;
  int depthV;
 
  translate(-context.depthWidth()  * xDist * 0.5f,
            -context.depthHeight() * yDist * 0.5f);
            
  for(int y=0;y < context.depthHeight();y+=steps)
  {
    for(int x=0;x < context.depthWidth();x+=steps)
    {
      depthV = depthMap[x + y * context.depthWidth()];
      if(depthV > 0)
      {
        point(x * xDist,
              y * yDist,
              - depthMap[x + y * context.depthWidth()]);
      }
    } 
  }  
}

void keyPressed()
{
  switch(keyCode)
  {
    case LEFT:
      rotY += 0.1f;
      break;
    case RIGHT:
      // zoom out
      rotY -= 0.1f;
      break;
    case UP:
      if(keyEvent.isShiftDown())
        zoomF += 0.01f;
      else
        rotX += 0.1f;
      break;
    case DOWN:
      if(keyEvent.isShiftDown())
      {
        zoomF -= 0.01f;
        if(zoomF < 0.01)
          zoomF = 0.01;
      }
      else
        rotX -= 0.1f;
      break;
  }
}
