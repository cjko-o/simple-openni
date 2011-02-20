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

#include "ContextWrapper.h"


using namespace sOpenNI;
using namespace xn;

#define		SIMPLEOPENNI_VERSION	10		// 1234 = 12.24

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
_initFlag(false),
_generatingFlag(false)
{
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

	_pDepthImage= NULL;
	_pIrImage	= NULL;
	_pSceneImage= NULL;

	// shutdown the context
	_context.Shutdown();

}
	
int ContextWrapper::version() 
{ 
	return SIMPLEOPENNI_VERSION; 
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
		printf("ContextWrapper::init: Can't init %s\n",xmlInitFile);
		return false;
	}

	_initFlag = true;
	return true;
}

bool ContextWrapper::enableDepth()
{
	if(!_initFlag)
	{
		printf("SimpleOpenNI not initialised\n");
		return false;
	}

	_rc = _context.FindExistingNode(XN_NODE_TYPE_DEPTH, _depth);
	_depth.GetMetaData(_depthMD);	

	_depthBufSize = _depthMD.XRes() * _depthMD.YRes();
	_pDepthImage  = (XnRGB24Pixel*)malloc( _depthBufSize * sizeof(XnRGB24Pixel));

	return true;
}

bool ContextWrapper::enableRGB()
{
	if(!_initFlag)
	{
		printf("SimpleOpenNI not initialised\n");
		return false;
	}

	_rc = _context.FindExistingNode(XN_NODE_TYPE_IMAGE, _image);
	_image.GetMetaData(_imageMD);

	_rgbBufSize = _imageMD.XRes() * _imageMD.YRes();

	return true;
}

bool ContextWrapper::enableIR()
{
	if(!_initFlag)
	{
		printf("SimpleOpenNI not initialised\n");
		return false;
	}

	_rc = _context.FindExistingNode(XN_NODE_TYPE_IR, _ir);
	_ir.GetMetaData(_irMD);

	_irBufSize = _irMD.XRes() * _irMD.YRes();
	_pIrImage  = (XnRGB24Pixel*)malloc( _irBufSize * sizeof(XnRGB24Pixel));

	return true;
}

bool ContextWrapper::enableScene()
{
	if(!_initFlag)
	{
		printf("SimpleOpenNI not initialised\n");
		return false;
	}

	_rc = _context.FindExistingNode(XN_NODE_TYPE_SCENE, _sceneAnalyzer);
	if(_sceneAnalyzer.IsValid())
	{
		_sceneAnalyzer.GetMetaData(_sceneMD);
	
		_sceneBufSize = _sceneMD.XRes() * _sceneMD.YRes();
		_pSceneImage  = (XnRGB24Pixel*)malloc( _sceneBufSize * sizeof(XnRGB24Pixel));
		return true;
	}
	else
		return false;
}

bool ContextWrapper::enableUser(int flags)
{
	if(!_initFlag)
	{
		printf("SimpleOpenNI not initialised\n");
		return false;
	}

	_rc = _context.FindExistingNode(XN_NODE_TYPE_USER, _userGenerator);
	if(_rc != XN_STATUS_OK)
	{
		_rc = _userGenerator.Create(_context);
	}

	// set the skeleton type
	_userGenerator.GetSkeletonCap().SetSkeletonProfile((XnSkeletonProfile)flags);

	// set the callbacks
	_userGenerator.RegisterUserCallbacks(newUserCb, lostUserCb, this, _hUserCB);
	_userGenerator.GetSkeletonCap().RegisterCalibrationCallbacks(calibrationStartedCb, calibrationEndedCb, this, _hCalibrationCB);
	_userGenerator.GetPoseDetectionCap().RegisterToPoseCallbacks(poseStartedCb, poseEndedCb, this, _hPoseCB);


/*
	XnCallbackHandle hUserCallbacks, hCalibrationCallbacks, hPoseCallbacks;
	if (!g_UserGenerator.IsCapabilitySupported(XN_CAPABILITY_SKELETON))
	{
		printf("Supplied user generator doesn't support skeleton\n");
		return 1;
	}
	g_UserGenerator.RegisterUserCallbacks(User_NewUser, User_LostUser, NULL, hUserCallbacks);
	g_UserGenerator.GetSkeletonCap().RegisterCalibrationCallbacks(UserCalibration_CalibrationStart, UserCalibration_CalibrationEnd, NULL, hCalibrationCallbacks);

	if (g_UserGenerator.GetSkeletonCap().NeedPoseForCalibration())
	{
		g_bNeedPose = TRUE;
		if (!g_UserGenerator.IsCapabilitySupported(XN_CAPABILITY_POSE_DETECTION))
		{
			printf("Pose required, but not supported\n");
			return 1;
		}
		g_UserGenerator.GetPoseDetectionCap().RegisterToPoseCallbacks(UserPose_PoseDetected, NULL, NULL, hPoseCallbacks);
		g_UserGenerator.GetSkeletonCap().GetCalibrationPose(g_strPose);
	}

	g_UserGenerator.GetSkeletonCap().SetSkeletonProfile(XN_SKEL_PROFILE_ALL);

	nRetVal = g_Context.StartGeneratingAll();
	CHECK_RC(nRetVal, "StartGenerating");
*/

	return true;
}

void ContextWrapper::update()
{
	if(!_initFlag)
		return;

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
				
				pPixel->nRed	= nHistValue;
				pPixel->nGreen	= nHistValue;
				//pPixel->nBlue	= nHistValue;
				pPixel->nBlue	= 0;
			}
		}
	}
}


///////////////////////////////////////////////////////////////////////////////
// depth methods
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
		map[i] = 0xff	<< 24 | 
				 _pDepthImage[i].nRed	<< 16| 
				 _pDepthImage[i].nGreen << 8 |
				 _pDepthImage[i].nBlue ;
	}

	return _depthBufSize;
}

int ContextWrapper::depthMap(int* map)
{
	for(int i=0;i < _depthBufSize;i++)
		map[i] = (int)(_depthMD.Data())[i]; 
	return _depthBufSize;
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

void XN_CALLBACK_TYPE ContextWrapper::calibrationStartedCb(xn::SkeletonCapability& skeleton, XnUserID user, void* cxt)
{
	ContextWrapper* context = static_cast<ContextWrapper*>(cxt);
	if(context == NULL)
		return;
	context->onCalibrationStartedCb(skeleton,user);
}

void XN_CALLBACK_TYPE ContextWrapper::calibrationEndedCb(xn::SkeletonCapability& skeleton, XnUserID user, XnBool bSuccess, void* cxt)
{
	ContextWrapper* context = static_cast<ContextWrapper*>(cxt);
	if(context == NULL)
		return;
	context->onCalibrationEndedCb(skeleton,user,bSuccess);
}

void XN_CALLBACK_TYPE ContextWrapper::poseStartedCb(xn::PoseDetectionCapability& pose, const XnChar* strPose, XnUserID user, void* cxt)
{
	ContextWrapper* context = static_cast<ContextWrapper*>(cxt);
	if(context == NULL)
		return;
	context->onPoseStartedCb(pose,strPose,user);
}

void XN_CALLBACK_TYPE ContextWrapper::poseEndedCb(xn::PoseDetectionCapability& pose, const XnChar* strPose, XnUserID user, void* cxt)
{
	ContextWrapper* context = static_cast<ContextWrapper*>(cxt);
	if(context == NULL)
		return;
	context->onPoseEndedCb(pose,strPose,user);
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

void ContextWrapper::onCalibrationStartedCb(xn::SkeletonCapability& skeleton, XnUserID user)
{
	onCalibrationStartedCb(user);	
}

void ContextWrapper::onCalibrationEndedCb(xn::SkeletonCapability& skeleton, XnUserID user, XnBool bSuccess)
{
	onCalibrationEndedCb(user,bSuccess > 0);
}

void ContextWrapper::onPoseStartedCb(xn::PoseDetectionCapability& pose, const XnChar* strPose, XnUserID user)
{
	onPoseStartedCb(strPose,user);
}

void ContextWrapper::onPoseEndedCb(xn::PoseDetectionCapability& pose, const XnChar* strPose, XnUserID user)
{
	onPoseEndedCb(strPose,user);
}

// virtual methods for the java class which inherits this class
void  ContextWrapper::onNewUserCb(unsigned int userId){;}
void  ContextWrapper::onLostUserCb(unsigned int userId){;}

void  ContextWrapper::onCalibrationStartedCb(unsigned int userId){;}
void  ContextWrapper::onCalibrationEndedCb(unsigned int userId,bool successFlag){;}

void  ContextWrapper::onPoseStartedCb(const char* strPose, unsigned int user){;}
void  ContextWrapper::onPoseEndedCb(const char* strPose, unsigned int user){;}
