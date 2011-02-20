/* ----------------------------------------------------------------------------
 * SimpleOpenNI
 * ----------------------------------------------------------------------------
 * Copyright (C) 2011 Max Rheiner / Interaction Design Zhdk
 *
 * This file is part of SimpleOpenNI.
 *
 * SimpleOpenNI is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 2 of the License, or
 * (at your option) any later version (subject to the "Classpath" exception
 * as provided in the LICENSE.txt file that accompanied this code).
 *
 * SimpleOpenNI is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with SimpleOpenNI.  If not, see <http://www.gnu.org/licenses/>.
 * ----------------------------------------------------------------------------
 */
 
package SimpleOpenNI;

import processing.core.*;
import java.lang.reflect.Method;
   
public class SimpleOpenNI extends ContextWrapper implements SimpleOpenNIConstants
{
	static 
	{	// load the nativ shared lib
		System.loadLibrary("SimpleOpenNI");
	}
	
	// constants
	public static final int DEPTH 			= 1 << 1;
	public static final int IMAGE 			= 1 << 2;
	public static final int IR 				= 1 << 3;
	public static final int SCENE		 	= 1 << 4;
	public static final int USER	 		= 1 << 5;
	
	protected Method 			_userNewMethod;
	protected Method 			_userLostMethod;
	
	protected Method 			_calibrationStartedMethod;
	protected Method 			_calibrationEndedMethod;
	
	protected Method 			_poseStartedMethod;
	protected Method 			_poseEndedMethod;
	
	protected String 			_filename;	
	protected PApplet			_parent;
	protected int				_dataType;
	
	protected PImage			_depthImage;
	protected int[]				_depthRaw;
	
	protected PImage			_rgbImage;

	protected PImage			_irImage;
	
	protected PImage			_sceneImage;
  
  /**
   * Creates the OpenNI context ands inits the modules
   * 
   * @param parent
   *          PApplet
   * @param initXMLFile
   *          String
   */
	public SimpleOpenNI(PApplet parent, String initXMLFile)
	{
		this._parent 	= parent;
		parent.registerDispose(this);
		
		this._dataType 					= 0;
		this._userNewMethod				= null;
		this._userLostMethod 			= null;
		this._calibrationStartedMethod 	= null;
		this._calibrationEndedMethod	= null;
		this._poseStartedMethod 		= null;
		this._poseEndedMethod			= null;
		
		// user callbacks
		try {
			/*
			_userMethod = parent.getClass().getMethod("userEvent",
														new Class[] { UserEvent.class });																									
			*/
			_userNewMethod = parent.getClass().getMethod("onUserNew",new Class[] { int.class });																									
		} 
		catch (Exception e) 
		{
		// no such method, or an error.. which is fine, just ignore
		}
		
		try {
			_userLostMethod = parent.getClass().getMethod("onUserLost",new Class[] { int.class });																									
		} 
		catch (Exception e) 
		{
		// no such method, or an error.. which is fine, just ignore
		}
		
		// calibrations callbacks
		try {
			_calibrationStartedMethod = parent.getClass().getMethod("onCalibrationStarted",new Class[] { int.class });																									
		} 
		catch (Exception e) 
		{
		// no such method, or an error.. which is fine, just ignore
		}
		try {
			_calibrationEndedMethod = parent.getClass().getMethod("onCalibrationEnded",new Class[] { int.class, boolean.class });																									
		} 
		catch (Exception e) 
		{
		// no such method, or an error.. which is fine, just ignore
		}
		
		// pose callbacks
		try {
			_poseStartedMethod = parent.getClass().getMethod("onPoseStarted",new Class[] { String.class,int.class });																									
		} 
		catch (Exception e) 
		{
		// no such method, or an error.. which is fine, just ignore
		}
		try {
			_poseEndedMethod = parent.getClass().getMethod("onPoseEnded",new Class[] { String.class,int.class });																									
		} 
		catch (Exception e) 
		{
		// no such method, or an error.. which is fine, just ignore
		}
		
		this.init(parent.dataPath(initXMLFile));
	}

	/**
	* 
	*/  
	public void dispose() 
	{
		close();
	}

	public void finalize() 
	{
		close();
	}
  
	public int dataType()
	{
		return _dataType;
	}
	
	/**
	* Enable the depthMap data collection
	*/  
	public boolean enableDepth() 
	{
		if(super.enableDepth())
		{	// setup the var for depth calc
			this._dataType |= DEPTH;
			_depthImage = new PImage(depthWidth(), depthHeight(),PConstants.RGB);
			return true;
		}
		else
			return false;
	}
	
		
	public PImage depthImage() 
	{
		return _depthImage;
	}
	
	public int depthMap(int[] map)
	{
		return super.depthMap(map);
	}
	
	/**
	* Enable the camera image collection
	*/  
	public boolean enableRGB() 
	{
		if(super.enableRGB())
		{	// setup the var for depth calc
			this._dataType |= IMAGE;
			_rgbImage = new PImage(rgbWidth(), rgbHeight(),PConstants.RGB);
			return true;
		}
		else
			return false;
	}	

	public PImage rgbImage() 
	{
		return _rgbImage;
	}
		

	/**
	* Enable the irMap data collection
	* ir is only available if there is no rgbImage activated at the same time 
	*/  
	public boolean enableIR() 
	{
		if(super.enableIR())
		{	// setup the var for depth calc
			this._dataType |= IR;
			_irImage = new PImage(irWidth(), irHeight(),PConstants.RGB);
			return true;
		}
		else
			return false;
	}
	
		
	public PImage irImage() 
	{
		return _irImage;
	}

	/**
	* Enable the scene data collection
	*/  
	public boolean enableScene() 
	{
		if(super.enableScene())
		{	// setup the var for depth calc
			this._dataType |= SCENE;
			_sceneImage = new PImage(sceneWidth(), sceneHeight(),PConstants.RGB);
			return true;
		}
		else
			return false;
	}
	
	public PImage sceneImage()
	{
		return _sceneImage;
	}
	
	public void getSceneFloor(PVector point,PVector normal)
	{
		XnVector3D p = new XnVector3D();
		XnVector3D n = new XnVector3D();
		
		super.getSceneFloor(p, n);
		point.set(p.getX(),p.getY(),p.getZ());
		normal.set(n.getX(),n.getY(),n.getZ());
	}
	

	/**
	* Enable the user data collection
	*/  


	public void update() 
	{
		super.update();
		
		// copy the depthImage map
		if((_dataType & DEPTH) > 0)
		{
			_depthImage.loadPixels();
				depthImage(_depthImage.pixels);
			_depthImage.updatePixels();
		}
		
		// copy the depthImage map
		if((_dataType & IMAGE) > 0)
		{
			_rgbImage.loadPixels();
				rgbImage(_rgbImage.pixels);
			_rgbImage.updatePixels();
		}
		
		// copy the depthImage map
		if((_dataType & IR) > 0)
		{
			_irImage.loadPixels();
				irImage(_irImage.pixels);
			_irImage.updatePixels();
		}
		
		// copy the depthImage map
		if((_dataType & SCENE) > 0)
		{
			_sceneImage.loadPixels();
				sceneImage(_sceneImage.pixels);
			_sceneImage.updatePixels();
		}
			
		
	}	
	
	/**
	* Draws a limb from joint1 to joint2
	* 
	* @param userId
	*          int
	* @param joint1
	*          int
	* @param joint2
	*          int
	*/
	public void drawLimb(int userId, int joint1, int  joint2)
	{
		if (!isCalibratedSkeleton(userId))
			return;
		if (!isTrackingSkeleton(userId))
			return;

		XnSkeletonJointPosition joint1Pos = new XnSkeletonJointPosition();
		XnSkeletonJointPosition joint2Pos = new XnSkeletonJointPosition();
		
		getJointPositionSkeleton(userId, joint1, joint1Pos);
		getJointPositionSkeleton(userId, joint2, joint2Pos);

		if (joint1Pos.getFConfidence() < 0.5 || joint2Pos.getFConfidence() < 0.5)
			return;
			
		// calc the 3d coordinate to screen coordinates
		XnVector3D pt1 = new XnVector3D();
		XnVector3D pt2 = new XnVector3D();
		
		convertRealWorldToProjective(joint1Pos.getPosition(), pt1);
		convertRealWorldToProjective(joint2Pos.getPosition(), pt2);
		
		_parent.line(pt1.getX(), pt1.getY(),
					 pt2.getX(), pt2.getY());

	}

	/**
	* get the coordinates of a joint
	* 
	* @param userId
	*          int
	* @param joint
	*          int
	* @return jointPos
	*          PVector
	*/	
	public float getJointPositionSkeleton(int userId,int joint,PVector jointPos)
	{
		if (!isCalibratedSkeleton(userId))
			return 0.0f;
		if (!isTrackingSkeleton(userId))
			return 0.0f;

		XnSkeletonJointPosition jointPos1 = new XnSkeletonJointPosition();
		
		getJointPositionSkeleton(userId, joint, jointPos1);
		jointPos.set(jointPos1.getPosition().getX(),
					 jointPos1.getPosition().getY(),
					 jointPos1.getPosition().getZ());

		return jointPos1.getFConfidence();
	}

	///////////////////////////////////////////////////////////////////////////
	// callbacks
	protected void onNewUserCb(long userId) 
	{
		try {
			_userNewMethod.invoke(_parent, new Object[] { (int)userId });
		} 
		catch (Exception e) 
		{
		}	
	}

	protected void onLostUserCb(long userId)
	{
		try {
			_userLostMethod.invoke(_parent, new Object[] { (int)userId });		
		} 
		catch (Exception e) 
		{
		}	
	}

	protected void onCalibrationStartedCb(long userId) 
	{
		try {
			_calibrationStartedMethod.invoke(_parent, new Object[] { (int)userId });	
		} 
		catch (Exception e) 
		{
		}	
	}

	protected void onCalibrationEndedCb(long userId, boolean successFlag) 
	{
		try {
			_calibrationEndedMethod.invoke(_parent, new Object[] { (int)userId, successFlag});
		} 
		catch (Exception e) 
		{
		}	
	}

	protected void onPoseStartedCb(String strPose, long userId) 
	{
		try {
			_poseStartedMethod.invoke(_parent, new Object[] { strPose,(int)userId });
		} 
		catch (Exception e) 
		{
		}	
	}

	protected void onPoseEndedCb(String strPose, long userId)
	{
		try {
			_poseEndedMethod.invoke(_parent, new Object[] { strPose,(int)userId });
		} 
		catch (Exception e) 
		{
		}	
	}

}

