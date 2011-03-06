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


#include <iostream>

#include <XnTypes.h>

#include "ContextWrapper.h"


using namespace sOpenNI;
using namespace xn;

#define		SIMPLEOPENNI_VERSION	13		// 1234 = 12.24

xn::DepthGenerator tempDepth;

XnFloat Colors[][3] =
{
	{0,1,1},
	{0,0,1},
	{0,1,0},
	{1,1,0},
	{1,0,0},
	{1,.5,0},
	{.5,1,0},
	{0,.5,1},
	{.5,0,1},
	{1,1,.5},
	{1,1,1}
};
XnUInt32 nColors = 10;

///////////////////////////////////////////////////////////////////////////////
// ContextWrapper

ContextWrapper::ContextWrapper():
_pDepthImage(NULL),
_pIrImage(NULL),
_pSceneImage(NULL),
_depthMapRealWorld(NULL),
_initFlag(false),
_generatingFlag(false),
_firstTimeUpdate(true),
_nodes(Node_None)
{
	//std::cout << "SimpleOpenNI Version " << (SIMPLEOPENNI_VERSION / 100) << "." <<  (SIMPLEOPENNI_VERSION % 100) << std::endl;
		
	_depthImageColor[0] = 1.0f;
	_depthImageColor[1] = 1.0f;
	_depthImageColor[2] = 1.0f;

	_depthMapOutputMode.nXRes = XN_VGA_X_RES; 
	_depthMapOutputMode.nYRes = XN_VGA_Y_RES; 
	_depthMapOutputMode.nFPS = 30; 

	_imageMapOutputMode.nXRes = XN_VGA_X_RES; 
	_imageMapOutputMode.nYRes = XN_VGA_Y_RES; 
	_imageMapOutputMode.nFPS = 30; 

	_irMapOutputMode.nXRes = XN_VGA_X_RES; 
	_irMapOutputMode.nYRes = XN_VGA_Y_RES; 
	_irMapOutputMode.nFPS = 30; 

	_sceneMapOutputMode.nXRes = XN_VGA_X_RES; 
	_sceneMapOutputMode.nYRes = XN_VGA_Y_RES; 
	_sceneMapOutputMode.nFPS = 30; 

}

ContextWrapper::~ContextWrapper()
{
	close();
}

void ContextWrapper::close()
{
	if(!_initFlag)
		return;

	// stop generators
	_context.StopGeneratingAll();

	_initFlag = false;
	_generatingFlag = false;

	if(_pDepthImage)
		free(_pDepthImage);
	if(_pIrImage)
		free(_pIrImage);
	if(_pSceneImage)
		free(_pSceneImage);
	if(_depthMapRealWorld)
		free(_depthMapRealWorld),

	_pDepthImage= NULL;
	_pIrImage	= NULL;
	_pSceneImage= NULL;
	_depthMapRealWorld= NULL;

	// shutdown the context
	_context.Shutdown();

}
	
int ContextWrapper::version() 
{ 
	return SIMPLEOPENNI_VERSION; 
}

void ContextWrapper::logOut(int msgType,const char* msg,...)
{
	switch(msgType)
	{
	case MsgNode_Error:
		std::cout << "SimpleOpenNI Error: ";
		break;
	case MsgNode_Info:
	default:
		std::cout << "SimpleOpenNI Info: ";
		break;
	};
	
	va_list args;
	va_start(args, msg);
	//vsprintf_s(_strBuffer,STRING_BUFFER,msg, args);
	vsnprintf(_strBuffer,STRING_BUFFER,msg, args);
	va_end(args);
	/*
	va_list vl;
	va_start(vl,amount);
	for(i=0;i<amount;i++)
	{
		val=va_arg(vl,double);
		printf ("\t%.2f",val);
	}
	va_end(vl);
	*/

	std::cout << _strBuffer << std::endl;
}

bool ContextWrapper::init(const char* xmlInitFile)
{
	// init the cam with the xml setup file
	xn::EnumerationErrors errors;
	_rc = _context.InitFromXmlFile(xmlInitFile, &errors);
	if (_rc == XN_STATUS_NO_NODE_PRESENT)
		return false;
	else if (_rc != XN_STATUS_OK)
	{
		logOut(MsgNode_Error,"ContextWrapper::init: Can't init %s\n",xmlInitFile);
		return false;
	}

	_initFlag = true;
	return true;
}
	
bool ContextWrapper::init()
{
	// init the cam with the xml setup file
	xn::EnumerationErrors errors;
	_rc = _context.Init();
	if (_rc == XN_STATUS_NO_NODE_PRESENT)
		return false;
	else if (_rc != XN_STATUS_OK)
	{
		logOut(MsgNode_Error,"ContextWrapper::init\n");
		return false;
	}

	_initFlag = true;
	return true;
}
	
int ContextWrapper::nodes()
{
	return _nodes;
}


void ContextWrapper::addLicense(const char* vendor,const char* license)
{
	XnLicense lic;
	strncpy(lic.strVendor,vendor,XN_MAX_NAME_LENGTH);
	strncpy(lic.strKey,license,XN_MAX_LICENSE_LENGTH);

	_rc = _context.AddLicense(lic);
}

bool ContextWrapper::createDepth(bool force)
{
	if(!_initFlag)
		return false;

	_rc = _context.FindExistingNode(XN_NODE_TYPE_DEPTH, _depth);
	if(_rc != XN_STATUS_OK)
	{	// could not find the depth, create it by default
		if(force == false)
			return false;

		_rc = _depth.Create(_context);

		// set default data
		_rc = _depth.SetMapOutputMode(_depthMapOutputMode);
	}

	_depth.GetMetaData(_depthMD);	

	_depthBufSize		= _depthMD.XRes() * _depthMD.YRes();
	_pDepthImage		= (XnRGB24Pixel*)malloc( _depthBufSize * sizeof(XnRGB24Pixel));
	_depthMapRealWorld	= (XnPoint3D*)malloc( _depthBufSize * sizeof(XnPoint3D));

	_nodes |= Node_Depth;
	return true;
}

bool ContextWrapper::enableDepth()
{
	if(!_initFlag)
	{
		printf("SimpleOpenNI not initialised\n");
		return false;
	}
	else if(_depth.IsValid())
		// already init.
		return true;

	return createDepth();
}

bool ContextWrapper::enableDepth(int width,int height,int fps)
{
	// set default data
	_depthMapOutputMode.nXRes = width; 
	_depthMapOutputMode.nYRes = height; 
	_depthMapOutputMode.nFPS = fps; 

	return ContextWrapper::enableDepth();
}

bool ContextWrapper::createRgb(bool force)
{
	if(!_initFlag)
		return false;

	_rc = _context.FindExistingNode(XN_NODE_TYPE_IMAGE, _image);
	if(_rc != XN_STATUS_OK)
	{	// could not find the depth, create it by default
		if(force == false)
			return false;
		_rc = _image.Create(_context);

		// set default data
		_rc = _image.SetMapOutputMode(_imageMapOutputMode);	
	}
	_image.GetMetaData(_imageMD);

	_rgbBufSize = _imageMD.XRes() * _imageMD.YRes();

	_nodes |= Node_Image;

	return true;
}

bool ContextWrapper::enableRGB()
{
	if(!_initFlag)
	{
		printf("SimpleOpenNI not initialised\n");
		return false;
	}
	else if(_image.IsValid())
		// already init.
		return true;

	return createRgb();
}

bool ContextWrapper::enableRGB(int width,int height,int fps)
{
	// set default data
	_imageMapOutputMode.nXRes = width; 
	_imageMapOutputMode.nYRes = height; 
	_imageMapOutputMode.nFPS = fps; 

	return ContextWrapper::enableRGB();
}

bool ContextWrapper::createIr(bool force)
{
	if(!_initFlag)
		return false;

	_rc = _context.FindExistingNode(XN_NODE_TYPE_IR, _ir);
	if(_rc != XN_STATUS_OK)
	{	// could not find the depth, create it by default
		if(force == false)
			return false;
		_rc = _ir.Create(_context);

		// set default data
		_rc = _ir.SetMapOutputMode(_irMapOutputMode);
	}	
	_ir.GetMetaData(_irMD);

	_irBufSize = _irMD.XRes() * _irMD.YRes();
	_pIrImage  = (XnRGB24Pixel*)malloc( _irBufSize * sizeof(XnRGB24Pixel));

	_nodes |= Node_Ir;
	return true;
}

bool ContextWrapper::enableIR()
{
	if(!_initFlag)
	{
		printf("SimpleOpenNI not initialised\n");
		return false;
	}
	else if(_ir.IsValid())
		// already init.
		return true;

	return createIr();
}

bool ContextWrapper::enableIR(int width,int height,int fps)
{
	// set default data
	_irMapOutputMode.nXRes = width; 
	_irMapOutputMode.nYRes = height; 
	_irMapOutputMode.nFPS = fps; 

	return ContextWrapper::enableIR();
}

bool ContextWrapper::createScene(bool force)
{
	if(!_initFlag)
		return false;

	_rc = _context.FindExistingNode(XN_NODE_TYPE_SCENE, _sceneAnalyzer);
	if(_rc != XN_STATUS_OK)
	{	// could not find the depth, create it by default
		if(force == false)
			return false;

		// depth has to be created before the scene, create a default depth
		if(!_depth.IsValid())
		{
			_rc = _sceneDepth.Create(_context);
			_rc = _sceneDepth.SetMapOutputMode(_depthMapOutputMode);
		}

		_rc = _sceneAnalyzer.Create(_context);

		// set default data
		_rc = _sceneAnalyzer.SetMapOutputMode(_sceneMapOutputMode);	
	}	

	if(_sceneAnalyzer.IsValid())
	{
		_sceneAnalyzer.GetMetaData(_sceneMD);
	
		_sceneBufSize = _sceneMD.XRes() * _sceneMD.YRes();
		_pSceneImage  = (XnRGB24Pixel*)malloc( _sceneBufSize * sizeof(XnRGB24Pixel));

		_nodes |= Node_Scene;
		return true;
	}
	else
		return false;
}

bool ContextWrapper::enableScene()
{
	if(!_initFlag)
	{
		printf("SimpleOpenNI not initialised\n");
		return false;
	}
	else if(_sceneAnalyzer.IsValid())
		// already init.
		return true;

	return createScene();
}


bool ContextWrapper::enableScene(int width,int height,int fps)
{
	// set default data
	_sceneMapOutputMode.nXRes = width; 
	_sceneMapOutputMode.nYRes = height; 
	_sceneMapOutputMode.nFPS = fps; 

	return ContextWrapper::enableScene();
}

bool ContextWrapper::createUser(int flags,bool force)
{
	if(!_initFlag)
		return false;

	_rc = _context.FindExistingNode(XN_NODE_TYPE_USER, _userGenerator);
	if(_rc != XN_STATUS_OK)
	{
		if(force == false)
			return false;
		_rc = _userGenerator.Create(_context);
	}

	// set the skeleton type
	_userGenerator.GetSkeletonCap().SetSkeletonProfile((XnSkeletonProfile)flags);

	// set the callbacks
	_userGenerator.RegisterUserCallbacks(newUserCb, lostUserCb, this, _hUserCb);
	_userGenerator.GetSkeletonCap().RegisterCalibrationCallbacks(startCalibrationCb, endCalibrationCb, this, _hCalibrationCb);
	_userGenerator.GetPoseDetectionCap().RegisterToPoseCallbacks(startPoseCb, endPoseCb, this, _hPoseCb);

	_nodes |= Node_User;
	return true;

}

bool ContextWrapper::enableUser(int flags)
{
	if(!_initFlag)
	{
		printf("SimpleOpenNI not initialised\n");
		return false;
	}
	else if(_userGenerator.IsValid())
		// already init.
		return true;

	return createUser(flags);
}

bool ContextWrapper::createHands(bool force)
{
	if(!_initFlag)
		return false;

	_rc = _context.FindExistingNode(XN_NODE_TYPE_HANDS, _handsGenerator);
	if(_rc != XN_STATUS_OK)
	{	// it's not in the xml, create it
		if(force == false)
			return false;
		_rc = _handsGenerator.Create(_context);
	}

	// set the callbacks
	_handsGenerator.RegisterHandCallbacks(createHandsCb,
										  updateHandsCb,
										  destroyHandsCb,
										  this, 
										  _hHandsCb);

	_nodes |= Node_Hands;
	return true;
}

// hands
bool ContextWrapper::enableHands()
{
	if(!_initFlag)
	{
		logOut(MsgNode_Error,"enableHands: context is not initialized!");
		return false;
	}
	else if(_handsGenerator.IsValid())
		// already init.
		return true;

	return createHands();
}

void ContextWrapper::startTrackingHands(const XnVector3D& pos)
{	
	if(!_handsGenerator.IsValid())
		return;

	_handsGenerator.StartTracking(pos);
}

void ContextWrapper::stopTrackingHands(int handId)
{	
	if(!_handsGenerator.IsValid())
		return;

	_handsGenerator.StopTracking(handId);
}

void ContextWrapper::stopTrackingAllHands()
{	
	if(!_handsGenerator.IsValid())
		return;

	_handsGenerator.StopTrackingAll();
}

void ContextWrapper::setSmoothingHands(float smoothingFactor)
{	
	if(!_handsGenerator.IsValid())
		return;

	_handsGenerator.SetSmoothing(smoothingFactor);
}

bool ContextWrapper::createGesture(bool force)
{
	if(!_initFlag)
		return false;
	_rc = _context.FindExistingNode(XN_NODE_TYPE_GESTURE, _gestureGenerator);
	if(_rc != XN_STATUS_OK)
	{	// it's not in the xml, create it
		if(force == false)
			return false;
		_rc = _gestureGenerator.Create(_context);
	}

	// set the callbacks
	_rc = _gestureGenerator.RegisterGestureCallbacks(recognizeGestureCb,
													 progressGestureCb,
													 this, 
													 _hGestureCb);
	/*
	XnChar* strArray =(XnChar*) new XnChar[200][200];
	XnUInt16 count=200;
	_gestureGenerator.EnumerateGestures(strArray,count); 
	for(int i=0;i<count;i++)
		logOut(MsgNode_Error,"gestures:%d %s",i,strArray[i]);
	*/
	_nodes |= Node_Gesture;

	return true;
}

// gesture
bool ContextWrapper::enableGesture()
{
	if(!_initFlag)
	{
		logOut(MsgNode_Error,"enableGesture: context is not initialized!");
		return false;
	}
	else if(_gestureGenerator.IsValid())
		// already init.
		return true;

	return createGesture();
}

void ContextWrapper::addGesture(const char* gesture)
{
	if(!_gestureGenerator.IsValid())
		return;
	
/*
	if(!_generatingFlag)
	{
		logOut(MsgNode_Info,"_generatingFlag");
		_context.StartGeneratingAll();
		_generatingFlag = true;
	}
*/	

	// default, no bounding box
	/*
	XnBoundingBox3D box;
	box.LeftBottomNear.X = -5000;
	box.LeftBottomNear.Y = -5000;
	box.LeftBottomNear.Z = 0;

	box.RightTopFar.X =   +5000;
	box.RightTopFar.Y =   +5000;
	box.RightTopFar.Z =   10000;

	_rc = _gestureGenerator.AddGesture(gesture,&box);
	*/

	_rc = _gestureGenerator.AddGesture(gesture,NULL);
	/*
	if(_rc == XN_STATUS_OK)
		logOut(MsgNode_Info,"addGesture: %s",gesture);
	*/
}

void ContextWrapper::removeGesture(const char* gesture)
{
	if(!_gestureGenerator.IsValid())
		return;

	_gestureGenerator.RemoveGesture(gesture);
}

bool ContextWrapper::availableGesture(const char* gesture)
{
	if(!_gestureGenerator.IsValid())
		return false;

	return _gestureGenerator.IsGestureAvailable(gesture)>0;
}
	
///////////////////////////////////////////////////////////////////////////////
// recorder

bool ContextWrapper::enableRecorder(int recordMedium,const char* filePath)
{
	if(!_initFlag)
	{
		logOut(MsgNode_Error,"enableRecorder: context is not initialized!");
		return false;
	}
	else if(_recorder.IsValid())
		// already init.
		return true;

	_rc = _context.FindExistingNode(XN_NODE_TYPE_RECORDER, _recorder);
	if(_rc != XN_STATUS_OK)
	{
		_rc = _recorder.Create(_context);
	}

	// set the recording
	_rc = _recorder.SetDestination((XnRecordMedium)recordMedium,filePath);
	if(_rc != XN_STATUS_OK)
	{
		logOut(MsgNode_Error,"enableRecorder: %s",filePath);
		return false;
	}

	_nodes |= Node_Recorder;
	return true;
}
	
bool ContextWrapper::addNodeToRecording(int nodeType,int compression)
{
	if(!_initFlag)
	{
		logOut(MsgNode_Error,"enableRecorder: context is not initialized!");
		return false;
	}
	else if(!_recorder.IsValid())
	{
		logOut(MsgNode_Error,"removeNodeToRecording: recording is not enabled");
		return false;
	}

	xn::ProductionNode* recordNode = getNode(nodeType);
	if(recordNode != NULL)
	{
		_rc = _recorder.AddNodeToRecording(*recordNode, compression);
		return _rc == XN_STATUS_OK;
	}
	return false;
}

bool ContextWrapper::removeNodeFromRecording(int nodeType)
{
	if(!_initFlag)
	{
		logOut(MsgNode_Error,"enableRecorder: context is not initialized!");
		return false;
	}
	else if(!_recorder.IsValid())
	{
		logOut(MsgNode_Error,"removeNodeToRecording: recording is not enabled");
		return false;
	}


	xn::ProductionNode* recordNode = getNode(nodeType);
	if(recordNode != NULL)
	{
		_rc = _recorder.RemoveNodeFromRecording(*recordNode);
		return _rc == XN_STATUS_OK;
	}
	
	return false;
}

bool ContextWrapper::openFileRecording(const char* filePath)
{
	if(!_initFlag)
	{
		logOut(MsgNode_Error,"openFileRecording: context is not initialized!");
		return false;
	}

	_rc = _context.OpenFileRecording(filePath);
	if(_rc != XN_STATUS_OK)
		return false;

	// add all the nodes to the player line
	createDepth(false);
	createRgb(false);
	createIr(false);
	createScene(false);
	createUser(false);
	createGesture(false);
	createHands(false);

	_nodes |= Node_Player;

	return true;
}

///////////////////////////////////////////////////////////////////////////////
// update

void ContextWrapper::update()
{
	if(!_initFlag)
		return;

	// check if everything is all right for the first round
	/*
	if(_firstTimeUpdate)
	{
		_firstTimeUpdate = false;
	}
	*/

	if(!_generatingFlag)
	{	
		_context.StartGeneratingAll();
		_generatingFlag = true;
	}

	// Read a new frame
	_rc = _context.WaitAnyUpdateAll();

	if(_rc != XN_STATUS_OK)
		return;

	// update depthMap
	if(_depth.IsValid())
	{	
		/*
		_rc = _depth.WaitAndUpdateData();
		if(_rc == XN_STATUS_OK)
		{
			_depth.GetMetaData(_depthMD);
			calcHistogram();
			createDepthImage();
		}
		*/
		_depth.GetMetaData(_depthMD);
		calcHistogram();
		createDepthImage();
		calcDepthImageRealWorld();
	}


	// calc the images
	if(_image.IsValid())
	{	
		_image.GetMetaData(_imageMD);
	}

	// calc the infraRed images
	if(_ir.IsValid())
	{	
		_ir.GetMetaData(_irMD);
		createIrImage();
	}
	
	// calc the scene data
	if(_sceneAnalyzer.IsValid())
	{	
		_sceneAnalyzer.GetMetaData(_sceneMD);
		calcSceneData();
	}	

	// update the generator
	// i don't know why, but it only works if i add 'WaitAndUpdateAll'
	if(_gestureGenerator.IsValid() || _handsGenerator.IsValid())
	{
		_rc = _context.WaitAndUpdateAll();
	}

}


void ContextWrapper::calcHistogram()
{
	const XnDepthPixel*	pDepth = _depthMD.Data();

	xnOSMemSet(_pDepthHist, 0, MAX_DEPTH * sizeof(float));

	unsigned int nNumberOfPoints = 0;
	for(XnUInt y = 0; y < _depthMD.YRes(); ++y)
	{
		for(XnUInt x = 0; x < _depthMD.XRes(); ++x, ++pDepth)
		{
			if(*pDepth != 0)
			{
				_pDepthHist[*pDepth]++;
				nNumberOfPoints++;
			}
		}
	}

	for(int nIndex=1; nIndex<MAX_DEPTH; nIndex++)
	{
		_pDepthHist[nIndex] += _pDepthHist[nIndex-1];
	}

	if(nNumberOfPoints)
	{
		for(int nIndex=1; nIndex<MAX_DEPTH; nIndex++)
			_pDepthHist[nIndex] = (float)(unsigned int)(256 * (1.0f - (_pDepthHist[nIndex] / nNumberOfPoints)));
	}

}

void ContextWrapper::calcDepthImageRealWorld()
{
	const XnDepthPixel*	pDepth	= _depthMD.Data();
	XnPoint3D*			map		= _depthMapRealWorld;
	for(int y = 0; y < _depthMD.YRes(); ++y)
	{
		for(int x = 0; x < _depthMD.XRes(); ++x, ++pDepth,++map)
		{
			map->X = (float)x;
			//map->Y = _depthMD.YRes()-y;		// in the coordinatesystem of the image y points down, in the realword it points up
			map->Y = (float)y;		// in the coordinatesystem of the image y points down, in the realword it points up
			map->Z = (float)*pDepth;
		}
	}

	// convert all point into realworld coord
	_depth.ConvertProjectiveToRealWorld(_depthBufSize,
										_depthMapRealWorld,
										_depthMapRealWorld);
}


void ContextWrapper::createDepthImage()
{
	xnOSMemSet(_pDepthImage, 0, _depthMD.XRes()*_depthMD.YRes()*sizeof(XnRGB24Pixel));

	for(XnUInt y = 0; y < _depthMD.YRes(); ++y)
	{
		const XnDepthPixel*	pDepth	= _depthMD.Data()	+ (y * _depthMD.XRes());
		XnRGB24Pixel*		pPixel	= _pDepthImage		+ (y * _depthMD.XRes());

		for(XnUInt x = 0; x < _depthMD.XRes(); ++x, ++pDepth, ++pPixel)
		{
			if(*pDepth != 0)
			{
				int nHistValue = (int)_pDepthHist[*pDepth];
				
				pPixel->nRed	= (XnUInt8)(nHistValue * _depthImageColor[0]);
				pPixel->nGreen	= (XnUInt8)(nHistValue * _depthImageColor[1]);
				pPixel->nBlue	= (XnUInt8)(nHistValue * _depthImageColor[2]);
			}
		}
	}
}


///////////////////////////////////////////////////////////////////////////////
// depth methods

float ContextWrapper::hFieldOfView()
{
	XnFieldOfView fieldOfView;
	_depth.GetFieldOfView(fieldOfView);

	return (float)fieldOfView.fHFOV;
}

float ContextWrapper::vFieldOfView()
{
	XnFieldOfView fieldOfView;
	_depth.GetFieldOfView(fieldOfView);

	return (float)fieldOfView.fVFOV;
}


int ContextWrapper::depthWidth()
{
	return _depthMD.XRes();
}

int	ContextWrapper::depthHeight()
{
	return _depthMD.YRes();
}

int ContextWrapper::depthImage(int* map)
{
	for(int i=0;i < _depthBufSize;i++)
	{
		map[i] = (0xff	<< 24) | 
				 (_pDepthImage[i].nRed	<< 16) | 
				 (_pDepthImage[i].nGreen << 8) |
				 (_pDepthImage[i].nBlue) ;
	}

	return _depthBufSize;
}

int ContextWrapper::depthMap(int* map)
{
	for(int i=0;i < _depthBufSize;i++)
		map[i] = (int)(_depthMD.Data())[i]; 

	return _depthBufSize;
}

int ContextWrapper::depthMapRealWorld(XnPoint3D map[])
{
	// speed up the copy
	memcpy((void*)map,(const void *)_depthMapRealWorld,_depthBufSize * sizeof(XnPoint3D));

	/*
	for(int i=0;i < _depthBufSize;i++)
	{	
		map[i] = _depthMapRealWorld[i]; 
		//logOut(MsgNode_Error,"depthMapRealWorld: x:%f,y:%f,z:%f", _depthMapRealWorld[i].X,_depthMapRealWorld[i].Y,_depthMapRealWorld[i].Z);
		//logOut(MsgNode_Error,"depthMapRealWorld: x:%f,y:%f,z:%f", map[i].X,map[i].Y,map[i].Z);

	}
	*/

	return _depthBufSize;
}

XnPoint3DArray ContextWrapper::depthMapRealWorldA()
{
	return _depthMapRealWorld;
}

int ContextWrapper::depthMapSize()
{
	return _depthBufSize;
}



int ContextWrapper::depthHistSize()
{
	return MAX_DEPTH;
}

int ContextWrapper::depthHistMap(float* histMap)
{
	memcpy((void*)histMap,(const void *)_pDepthHist,MAX_DEPTH * sizeof(float));
/*
	for(int i=0;i < MAX_DEPTH;i++)
		histMap[i] = _pDepthHist[i];
*/
	return MAX_DEPTH;
}

void ContextWrapper::setDepthImageColor(int r,int g,int b)
{
	_depthImageColor[0] = r * 1.0f / 255.0f ;
	_depthImageColor[1] = g * 1.0f / 255.0f ;
	_depthImageColor[2] = b * 1.0f / 255.0f ;

}

void ContextWrapper::setDepthImageColorRange(XnRGB24Pixel* colors,int count)
{

}

		
///////////////////////////////////////////////////////////////////////////////
// rgb image methods

int ContextWrapper::rgbWidth()
{
	return _imageMD.XRes();
}

int	ContextWrapper::rgbHeight()
{
	return _imageMD.YRes();
}

int ContextWrapper::rgbImage(int* map)
{
	const XnRGB24Pixel* rgbImage = _imageMD.RGB24Data();

	for(int i=0;i < _rgbBufSize;i++)
	{
		map[i] = 0xff	<< 24 | 
				 rgbImage[i].nRed	<< 16| 
				 rgbImage[i].nGreen << 8 |
				 rgbImage[i].nBlue ;
	}

	return _rgbBufSize;
}

///////////////////////////////////////////////////////////////////////////////
// ir methods
int ContextWrapper::irWidth()
{
	return _irMD.XRes();
}

int ContextWrapper::irHeight()
{
	return _irMD.YRes();
}

int ContextWrapper::irImage(int* map)
{
	for(int i=0;i < _irBufSize;i++)
	{
		map[i] = 0xff	<< 24 | 
				 _pIrImage[i].nRed	<< 16| 
				 _pIrImage[i].nGreen << 8 |
				 _pIrImage[i].nBlue ;
	}

	return _irBufSize;
}

int ContextWrapper::irMap(int* map)
{
	for(int i=0;i < _irBufSize;i++)
		map[i] = (int)(_irMD.Data())[i]; 
	return _irBufSize;
}


void ContextWrapper::createIrImage()
{
	XnUInt8 val;
	xnOSMemSet(_pIrImage, 0, _irMD.XRes()*_irMD.YRes()*sizeof(XnRGB24Pixel));

	for(XnUInt y = 0; y < _irMD.YRes(); ++y)
	{
		const XnIRPixel*	pIr		= _irMD.Data()	+ (y * _irMD.XRes());
		XnRGB24Pixel*		pPixel	= _pIrImage		+ (y * _irMD.XRes());

		for(XnUInt x = 0; x < _irMD.XRes(); ++x, ++pIr, ++pPixel)
		{
			val = (XnUInt8)((float)*pIr * .5f);
			pPixel->nRed	= val;
			pPixel->nGreen	= val;
			pPixel->nBlue	= val;
		}
	}

}

///////////////////////////////////////////////////////////////////////////////
// scene
int ContextWrapper::sceneWidth()
{
	return _sceneMD.XRes();
}

int	ContextWrapper::sceneHeight()
{
	return _sceneMD.YRes();
}
	
void ContextWrapper::getSceneFloor(XnVector3D* point,	
								   XnVector3D* normal)
{
	if(!_sceneAnalyzer.IsValid())
		return;

	XnPlane3D plane;
	_sceneAnalyzer.GetFloor(plane);

	point->X = plane.ptPoint.X;
	point->Y = plane.ptPoint.Y;
	point->Z = plane.ptPoint.Z;

	normal->X = plane.vNormal.X;
	normal->Y = plane.vNormal.Y;
	normal->Z = plane.vNormal.Z;
}

void ContextWrapper::calcSceneData()
{
	xnOSMemSet(_pSceneImage, 0, _sceneMD.XRes()*_sceneMD.YRes()*sizeof(XnRGB24Pixel));

	if(_depth.IsValid())
	{	// calc with depth shades
		unsigned int		nValue = 0;
		unsigned int		nHistValue = 0;
		const XnDepthPixel*	pDepth = _depthMD.Data();
		const XnLabel*		pLabels= _sceneMD.Data();
		XnUInt32			nIndex = 0;
		XnRGB24Pixel*		pPixel = _pSceneImage;

		for(unsigned int y=0; y < _sceneMD.YRes(); y++)
		{
			for(unsigned int x=0; x < _sceneMD.XRes(); x++, nIndex++)
			{
				nValue = *pDepth;

				XnLabel		label	 = *pLabels;
				XnUInt32	nColorID = label % nColors;
				if (label == 0)
					nColorID = nColors;

				if(nValue != 0)
				{
					nHistValue = (unsigned int)_pDepthHist[nValue];

					pPixel->nRed	= (XnUInt8)(nHistValue * Colors[nColorID][0]); 
					pPixel->nGreen	= (XnUInt8)(nHistValue * Colors[nColorID][1]);
					pPixel->nBlue	= (XnUInt8)(nHistValue * Colors[nColorID][2]);
				}
				else
				{
					pPixel->nRed	= 0;
					pPixel->nGreen	= 0;
					pPixel->nBlue	= 0;
				}

				pDepth++;
				pLabels++;
				pPixel++;
			}
		}
	
	}
	else
	{	// calc with straight colors
		const XnLabel*		pLabels= _sceneMD.Data();
		XnRGB24Pixel*		pPixel = _pSceneImage;

		for(unsigned int y=0; y < _sceneMD.YRes(); y++)
		{
			for(unsigned int x=0; x < _sceneMD.XRes(); x++)
			{
				XnLabel		label	 = *pLabels;
				XnUInt32	nColorID = label % nColors;
				if(label != 0)
				{
					pPixel->nRed	= (XnUInt8)(255 * Colors[nColorID][0]); 
					pPixel->nGreen	= (XnUInt8)(255 * Colors[nColorID][1]);
					pPixel->nBlue	= (XnUInt8)(255 * Colors[nColorID][2]);
				}
	
				pLabels++;
				pPixel++;
			}
		}
	}
}

int ContextWrapper::sceneMap(int* map)
{
	for(int i=0;i < _sceneBufSize;i++)
		map[i] = (int)(_sceneMD.Data())[i]; 
	return _sceneBufSize;
}

int ContextWrapper::sceneImage(int* map)
{
	for(int i=0;i < _sceneBufSize;i++)
	{
		map[i] = 0xff	<< 24 | 
				 _pSceneImage[i].nRed	<< 16| 
				 _pSceneImage[i].nGreen << 8 |
				 _pSceneImage[i].nBlue ;
	}
	return _sceneBufSize;
}

///////////////////////////////////////////////////////////////////////////////
// user methods

int ContextWrapper::getUsers(std::vector<int>* userList)
{
	if(!_userGenerator.IsValid())
		return 0;

	XnUInt16	userCount = _userGenerator.GetNumberOfUsers();
	if(userCount > 0)
	{
		XnUserID usersArray[20];	// never more than 20 users
		_userGenerator.GetUsers(usersArray, userCount);

		userList->clear();
		for(int i=0;i<userCount;i++)
			userList->push_back((int)usersArray[i]);
	}
	return userCount;
}


bool ContextWrapper::isTrackingSkeleton(int user)
{
	if(!_userGenerator.IsValid())
		return false;

	return _userGenerator.GetSkeletonCap().IsTracking(user) > 0;
}

bool ContextWrapper::isCalibratedSkeleton(int user)
{
	if(!_userGenerator.IsValid())
		return false;

	return _userGenerator.GetSkeletonCap().IsCalibrated(user) > 0;
}

void ContextWrapper::requestCalibrationSkeleton(int user, bool force)
{
	if(!_userGenerator.IsValid())
		return;

	_userGenerator.GetSkeletonCap().RequestCalibration(user, force);
}

void ContextWrapper::startTrackingSkeleton(int user)
{
	if(!_userGenerator.IsValid())
		return;

	_userGenerator.GetSkeletonCap().StartTracking(user); 
}

void ContextWrapper::stopTrackingSkeleton(int user)
{
	if(!_userGenerator.IsValid())
		return;

	_userGenerator.GetSkeletonCap().StopTracking(user); 
}

void ContextWrapper::startPoseDetection(const char* pose,int user)
{
	if(!_userGenerator.IsValid())
		return;
		
	_userGenerator.GetPoseDetectionCap().StartPoseDetection(pose, user); 
}

void ContextWrapper::stopPoseDetection(int user)
{
	if(!_userGenerator.IsValid())
		return;

	_userGenerator.GetPoseDetectionCap().StopPoseDetection(user); 
}



bool ContextWrapper::getJointPositionSkeleton(int user,int joint,XnSkeletonJointPosition* jointPos)
{
	if(!_userGenerator.IsValid())
		return false;

	_rc = _userGenerator.GetSkeletonCap().GetSkeletonJointPosition( user, (XnSkeletonJoint)joint, *jointPos);

	return(_rc == XN_STATUS_OK);
}
 
bool ContextWrapper::getJointOrientationSkeleton(int user,
												 int joint,
												 XnSkeletonJointOrientation* jointOrientation)
{
	if(!_userGenerator.IsValid())
		return false;

	_rc = _userGenerator.GetSkeletonCap().GetSkeletonJointOrientation ( user, (XnSkeletonJoint)joint, *jointOrientation);
	
	return(_rc == XN_STATUS_OK);
}


void ContextWrapper::convertRealWorldToProjective(XnVector3D* world,XnVector3D* proj)
{
	if(!_depth.IsValid())
		return;	
	_depth.ConvertRealWorldToProjective(1, world, proj);
}

void ContextWrapper::convertRealWorldToProjective(std::vector<XnVector3D>* worldArray,std::vector<XnVector3D>* projArray)
{
	if(!_depth.IsValid())
		return;	

	projArray->clear();
	
	XnVector3D vec;
	std::vector<XnVector3D>::iterator itr = worldArray->begin();
	for(;itr != worldArray->end();itr++)
	{
		_depth.ConvertRealWorldToProjective(1, &(*itr), &vec);
		projArray->push_back(vec);
	}
}

void ContextWrapper::convertProjectiveToRealWorld (XnVector3D* proj,XnVector3D* world)
{
	if(!_depth.IsValid())
		return;	
	_depth.ConvertProjectiveToRealWorld  (1, proj, world);
}

void ContextWrapper::convertProjectiveToRealWorld(std::vector<XnVector3D>* projArray,std::vector<XnVector3D>* worldArray)
{
	if(!_depth.IsValid())
		return;	

	worldArray->clear();
	
	XnVector3D vec;
	std::vector<XnVector3D>::iterator itr = projArray->begin();
	for(;itr != projArray->end();itr++)
	{
		_depth.ConvertProjectiveToRealWorld(1, &(*itr), &vec);
		worldArray->push_back(vec);
	}
}


///////////////////////////////////////////////////////////////////////////////
// access methods
void ContextWrapper::setMirror(bool flag)
{
	if(!_initFlag)
		return;

	_context.SetGlobalMirror(flag);
}

bool ContextWrapper::mirror()
{
	if(!_initFlag)
		return false;
	else
		return _context.GetGlobalMirror() > 0;

}

///////////////////////////////////////////////////////////////////////////////
// callbacks

void XN_CALLBACK_TYPE ContextWrapper::newUserCb(xn::UserGenerator& generator, XnUserID user, void* cxt)
{
	ContextWrapper* context = static_cast<ContextWrapper*>(cxt);
	if(context == NULL)
		return;
	context->onNewUserCb(generator,user);
}

void XN_CALLBACK_TYPE ContextWrapper::lostUserCb(xn::UserGenerator& generator, XnUserID user, void* cxt)
{	
	ContextWrapper* context = static_cast<ContextWrapper*>(cxt);
	if(context == NULL)
		return;
	context->onLostUserCb(generator,user);
}

void XN_CALLBACK_TYPE ContextWrapper::startCalibrationCb(xn::SkeletonCapability& skeleton, XnUserID user, void* cxt)
{
	ContextWrapper* context = static_cast<ContextWrapper*>(cxt);
	if(context == NULL)
		return;
	context->onStartCalibrationCb(skeleton,user);
}

void XN_CALLBACK_TYPE ContextWrapper::endCalibrationCb(xn::SkeletonCapability& skeleton, XnUserID user, XnBool bSuccess, void* cxt)
{
	ContextWrapper* context = static_cast<ContextWrapper*>(cxt);
	if(context == NULL)
		return;
	context->onEndCalibrationCb(skeleton,user,bSuccess);
}

void XN_CALLBACK_TYPE ContextWrapper::startPoseCb(xn::PoseDetectionCapability& pose, const XnChar* strPose, XnUserID user, void* cxt)
{
	ContextWrapper* context = static_cast<ContextWrapper*>(cxt);
	if(context == NULL)
		return;
	context->onStartPoseCb(pose,strPose,user);
}

void XN_CALLBACK_TYPE ContextWrapper::endPoseCb(xn::PoseDetectionCapability& pose, const XnChar* strPose, XnUserID user, void* cxt)
{
	ContextWrapper* context = static_cast<ContextWrapper*>(cxt);
	if(context == NULL)
		return;
	context->onEndPoseCb(pose,strPose,user);
}

///////////////////////////////////////////////////////////////////////////////
// java virtual callbacks

void ContextWrapper::onNewUserCb(xn::UserGenerator& generator, XnUserID user)
{
	onNewUserCb(user);
}

void ContextWrapper::onLostUserCb(xn::UserGenerator& generator, XnUserID user)
{
	onLostUserCb(user);
}

void ContextWrapper::onStartCalibrationCb(xn::SkeletonCapability& skeleton, XnUserID user)
{
	onStartCalibrationCb(user);	
}

void ContextWrapper::onEndCalibrationCb(xn::SkeletonCapability& skeleton, XnUserID user, XnBool bSuccess)
{
	onEndCalibrationCb(user,bSuccess > 0);
}

void ContextWrapper::onStartPoseCb(xn::PoseDetectionCapability& pose, const XnChar* strPose, XnUserID user)
{
	onStartPoseCb(strPose,user);
}

void ContextWrapper::onEndPoseCb(xn::PoseDetectionCapability& pose, const XnChar* strPose, XnUserID user)
{
	onEndPoseCb(strPose,user);
}

// virtual methods for the java class which inherits this class
void  ContextWrapper::onNewUserCb(unsigned int userId){;}
void  ContextWrapper::onLostUserCb(unsigned int userId){;}

void  ContextWrapper::onStartCalibrationCb(unsigned int userId){;}
void  ContextWrapper::onEndCalibrationCb(unsigned int userId,bool successFlag){;}

void  ContextWrapper::onStartPoseCb(const char* strPose, unsigned int user){;}
void  ContextWrapper::onEndPoseCb(const char* strPose, unsigned int user){;}

// callback hands
void XN_CALLBACK_TYPE ContextWrapper::createHandsCb(xn::HandsGenerator& generator, XnUserID nId, const XnPoint3D* pPosition, XnFloat fTime, void* cxt)
{
	ContextWrapper* context = static_cast<ContextWrapper*>(cxt);
	if(context == NULL)
		return;
	context->onCreateHandsCb(generator, nId, pPosition, fTime);
}

void XN_CALLBACK_TYPE ContextWrapper::updateHandsCb(xn::HandsGenerator& generator, XnUserID nId, const XnPoint3D* pPosition, XnFloat fTime, void* cxt)
{
	ContextWrapper* context = static_cast<ContextWrapper*>(cxt);
	if(context == NULL)
		return;
	context->onUpdateHandsCb(generator, nId, pPosition, fTime);
}

void XN_CALLBACK_TYPE ContextWrapper::destroyHandsCb(xn::HandsGenerator& generator, XnUserID nId,XnFloat fTime, void* cxt)
{
	ContextWrapper* context = static_cast<ContextWrapper*>(cxt);
	if(context == NULL)
		return;
	context->onDestroyHandsCb(generator, nId, fTime);
}


void ContextWrapper::onCreateHandsCb(xn::HandsGenerator& generator, XnUserID nId, const XnPoint3D* pPosition, XnFloat fTime)
{
	onCreateHandsCb(nId,pPosition,fTime);
}
void ContextWrapper::onCreateHandsCb(unsigned int nId, const XnPoint3D* pPosition, float fTime){;}

void ContextWrapper::onUpdateHandsCb(xn::HandsGenerator& generator, XnUserID nId, const XnPoint3D* pPosition, XnFloat fTime)
{
	onUpdateHandsCb(nId,pPosition,fTime);
}
void ContextWrapper::onUpdateHandsCb(unsigned int nId, const XnPoint3D* pPosition, float fTime){;}

void ContextWrapper::onDestroyHandsCb(xn::HandsGenerator& generator, XnUserID nId, XnFloat fTime)
{
	onDestroyHandsCb(nId,fTime);
}
void ContextWrapper::onDestroyHandsCb(unsigned int nId, float fTime){;}


// callback gesture
void XN_CALLBACK_TYPE ContextWrapper::recognizeGestureCb(xn::GestureGenerator& generator,const XnChar* strGesture, const XnPoint3D* pIdPosition,const XnPoint3D* pEndPosition, void* cxt)
{
	ContextWrapper* context = static_cast<ContextWrapper*>(cxt);
	if(context == NULL)
		return;

	context->onRecognizeGestureCb(generator,strGesture,pIdPosition,pEndPosition);
}

void XN_CALLBACK_TYPE ContextWrapper::progressGestureCb(xn::GestureGenerator& generator,const XnChar* strGesture, const XnPoint3D* pPosition,XnFloat fProgress, void* cxt)
{
	ContextWrapper* context = static_cast<ContextWrapper*>(cxt);
	if(context == NULL)
		return;
	context->onProgressGestureCb(generator,strGesture,pPosition,fProgress);
}


void ContextWrapper::onRecognizeGestureCb(xn::GestureGenerator& generator,const XnChar* strGesture, const XnPoint3D* pIdPosition,const XnPoint3D* pEndPosition)
{
	onRecognizeGestureCb(strGesture,pIdPosition,pEndPosition);
}
void ContextWrapper::onRecognizeGestureCb(const char* strGesture, const XnPoint3D* pIdPosition,const XnPoint3D* pEndPosition){;}

void ContextWrapper::onProgressGestureCb(xn::GestureGenerator& generator,const XnChar* strGesture, const XnPoint3D* pPosition,XnFloat fProgress)
{
	onProgressGestureCb(strGesture,pPosition,fProgress);
}
void ContextWrapper::onProgressGestureCb(const char* strGesture, const XnPoint3D* pPosition,float fProgress){;}

	
int ContextWrapper::getNodeType(int internalType)
{
	if(internalType & Node_Depth)
		return XN_NODE_TYPE_DEPTH;
	else if(internalType & Node_Image)
		return XN_NODE_TYPE_IMAGE;
	else if(internalType & Node_Ir)
		return XN_NODE_TYPE_IR;
	else if(internalType & Node_Scene)
		return XN_NODE_TYPE_SCENE;
	else if(internalType & Node_User)
		return XN_NODE_TYPE_USER;
	else if(internalType & Node_Hands)
		return XN_NODE_TYPE_HANDS;
	else if(internalType & Node_Gesture)
		return XN_NODE_TYPE_GESTURE;
	else if(internalType & Node_Recorder)
		return XN_NODE_TYPE_RECORDER;
	else if(internalType & Node_Player)
		return XN_NODE_TYPE_PLAYER;
	else
		return 0;
}

xn::ProductionNode* ContextWrapper::getNode(int internalType)
{
	if(internalType & Node_Depth)
		return &_depth;
	else if(internalType & Node_Image)
		return &_image;
	else if(internalType & Node_Ir)
		return &_ir;
	else if(internalType & Node_Scene)
		return &_sceneAnalyzer;
	else if(internalType & Node_User)
		return &_userGenerator;
	else if(internalType & Node_Hands)
		return &_handsGenerator;
	else if(internalType & Node_Gesture)
		return &_gestureGenerator;
	else if(internalType & Node_Recorder)
		return &_recorder;
	else if(internalType & Node_Player)
		return NULL;
	else
		return NULL;
}