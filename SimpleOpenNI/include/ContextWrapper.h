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

#ifndef _CONTEXWRAPPER_H_
#define _CONTEXWRAPPER_H_

#include <vector>

// OpenNI
#include <XnOS.h>
#include <XnCppWrapper.h>

///////////////////////////////////////////////////////////////////////////////
// defines

#define		Node_None		(0)
#define		Node_Depth		(1 << 0)
#define		Node_Image		(1 << 1)
#define		Node_Ir			(1 << 2)
#define		Node_Scene		(1 << 3)
#define		Node_User		(1 << 4)
#define		Node_Hands		(1 << 5)
#define		Node_Gesture	(1 << 6)
#define		Node_Recorder	(1 << 7)
#define		Node_Player		(1 << 8)


#define		MAX_DEPTH		10000	// 10m
#define		STRING_BUFFER	255

/*
#define		SIMPELOPENNI_CALLBACK_FUNC(FuncName,...) \
public: \
	static void XN_CALLBACK_TYPE FuncName##Cb(__VA_ARGS__);\
protected:\
	virtual void on##FuncName##Cb(__VA_ARGS__);\
	void on##FuncName##Cb(__VA_ARGS__);
*/

namespace sOpenNI{

typedef XnPoint3D*	XnPoint3DArray;

class ContextWrapper
{
public:


	ContextWrapper();
	~ContextWrapper();

	int version();

	// init methods
	bool init(const char* xmlInitFile);
	bool init();

	int nodes();

	void addLicense(const char* vendor,const char* license);

	bool isInit(){	return _initFlag; }
	void close();

	virtual void update();

	

	// depth methods
	virtual bool enableDepth();
	virtual bool enableDepth(int width,int height,int fps);

	int depthWidth();
	int	depthHeight();

	int	depthImage(int* map);		// argb 4-Bytes / alpha is not used
	void setDepthImageColor(int r,int g,int b);
	void setDepthImageColorRange(XnRGB24Pixel* colors,int count);

	int depthMapSize();
	int	depthMap(int* map);					// in milimeters
	int depthMapRealWorld(XnPoint3D map[]);	
	XnPoint3DArray depthMapRealWorldA();	

	int depthHistSize();
	int depthHistMap(float* histMap);

	float hFieldOfView();
	float vFieldOfView();

	// cam image
	virtual bool enableRGB();
	virtual bool enableRGB(int width,int height,int fps);

	int rgbWidth();
	int rgbHeight();

	int	rgbImage(int* map);			// argb 4-Bytes / alpha is not used

	// ir image
	virtual bool enableIR();
	virtual bool enableIR(int width,int height,int fps);

	int irWidth();
	int irHeight();

	int irMap(int* map);			// 16-bit value
	int irImage(int* map);			// argb 4-Bytes / alpha is not used

	// scene analyzer
	virtual bool enableScene();
	virtual bool enableScene(int width,int height,int fps);

	int sceneWidth();
	int	sceneHeight();

	int sceneMap(int* map);			
	int sceneImage(int* map);		// 16-bit value, with the labels, size of the depth map
	void getSceneFloor(XnVector3D* point,	
					   XnVector3D* normal);	

	// users
	virtual bool enableUser(int flags);

	int		getUsers(std::vector<int>* userList);

	bool	isCalibratedSkeleton(int user);
	void	requestCalibrationSkeleton(int user, bool force);

	bool	isTrackingSkeleton(int user);
	void	startTrackingSkeleton(int user);
	void	stopTrackingSkeleton(int user);

	void	startPoseDetection(const char* pose,int user);
	void	stopPoseDetection(int user);

	bool	getJointPositionSkeleton(int user,int joint,XnSkeletonJointPosition* jointPos);
	bool	getJointOrientationSkeleton(int user,
									    int joint,
										XnSkeletonJointOrientation* jointOrientation);

	// hands
	virtual bool enableHands();
	void	startTrackingHands(const XnVector3D& pos);
	void	stopTrackingHands(int handId);
	void	stopTrackingAllHands();
	void	setSmoothingHands(float smoothingFactor);

	// gesture
	virtual bool enableGesture();
	void addGesture(const char* gesture);
	void removeGesture(const char* gesture);
	bool availableGesture(const char *strGesture);
	// void addGesture(const char* gesture,XnBoundingBox3D *  pArea);

	// audio
	//bool enableAudio();

	// recorder
	virtual bool enableRecorder(int recordMedium,const char* filePath);
	bool addNodeToRecording(int nodeType,int compression);
	bool removeNodeFromRecording(int nodeType);

	virtual bool openFileRecording(const char* filePath);

	// access methods
	void setMirror(bool flag);
	bool mirror();

	// converter methods
	void convertRealWorldToProjective(XnVector3D* world,XnVector3D* proj);	
	void convertRealWorldToProjective(std::vector<XnVector3D>* worldArray,std::vector<XnVector3D>* projArray);

	void convertProjectiveToRealWorld(XnVector3D* proj,XnVector3D* world);	
	void convertProjectiveToRealWorld(std::vector<XnVector3D>* projArray,std::vector<XnVector3D>* worldArray);

	///////////////////////////////////////////////////////////////////////////
	// callbacks

	// user
	static void XN_CALLBACK_TYPE newUserCb(xn::UserGenerator& generator, XnUserID user, void* cxt);
	static void XN_CALLBACK_TYPE lostUserCb(xn::UserGenerator& generator, XnUserID user, void* cxt);
	
	// calibration
	static void XN_CALLBACK_TYPE startCalibrationCb(xn::SkeletonCapability& skeleton, XnUserID user, void* cxt);
	static void XN_CALLBACK_TYPE endCalibrationCb(xn::SkeletonCapability& skeleton, XnUserID user, XnBool bSuccess, void* cxt);

	// pose
	static void XN_CALLBACK_TYPE startPoseCb(xn::PoseDetectionCapability& pose, const XnChar* strPose, XnUserID user, void* cxt);
	static void XN_CALLBACK_TYPE endPoseCb(xn::PoseDetectionCapability& pose, const XnChar* strPose, XnUserID user, void* cxt);

	// hands
	static void XN_CALLBACK_TYPE createHandsCb(xn::HandsGenerator& generator, XnUserID nId, const XnPoint3D* pPosition, XnFloat fTime, void* cxt);
	static void XN_CALLBACK_TYPE updateHandsCb(xn::HandsGenerator& generator, XnUserID nId, const XnPoint3D* pPosition, XnFloat fTime, void* cxt);
	static void XN_CALLBACK_TYPE destroyHandsCb(xn::HandsGenerator& generator, XnUserID nId, XnFloat fTime, void* cxt);

	// gesture
	static void XN_CALLBACK_TYPE recognizeGestureCb(xn::GestureGenerator& generator,const XnChar* strGesture, const XnPoint3D* pIdPosition,const XnPoint3D* pEndPosition, void* cxt);
	static void XN_CALLBACK_TYPE progressGestureCb(xn::GestureGenerator& generator,const XnChar* strGesture, const XnPoint3D* pPosition,XnFloat fProgress, void* cxt);

	static int getNodeType(int internalType);
	xn::ProductionNode* getNode(int internalType);

protected:
	
	enum LogOutMsg{
		MsgNode_End		= 0,
		MsgNode_Info	= 1,
		MsgNode_Error	= 2,

	};

	void logOut(int msgType,const char* msg,...);	// must end with null
	char	_strBuffer[STRING_BUFFER];

	//////////////////////////////////////////////////////////////////////////////
	// internal callback wrappers
	virtual void onNewUserCb(unsigned int userId);
	virtual void onLostUserCb(unsigned int userId);
	
	virtual void onStartCalibrationCb(unsigned int userId);
	virtual void onEndCalibrationCb(unsigned int userId,bool successFlag);

	virtual void onStartPoseCb(const char* strPose, unsigned int user);
	virtual void onEndPoseCb(const char* strPose, unsigned int user);

	void onNewUserCb(xn::UserGenerator& generator, XnUserID user);
	void onLostUserCb(xn::UserGenerator& generator, XnUserID user);
	
	void onStartCalibrationCb(xn::SkeletonCapability& skeleton, XnUserID user);
	void onEndCalibrationCb(xn::SkeletonCapability& skeleton, XnUserID user, XnBool bSuccess);

	void onStartPoseCb(xn::PoseDetectionCapability& pose, const XnChar* strPose, XnUserID user);
	void onEndPoseCb(xn::PoseDetectionCapability& pose, const XnChar* strPose, XnUserID user);
	
	// hands
	void			onCreateHandsCb(xn::HandsGenerator& generator, XnUserID nId, const XnPoint3D* pPosition, XnFloat fTime);
	virtual void	onCreateHandsCb(unsigned int nId, const XnPoint3D* pPosition, float fTime);

	void			onUpdateHandsCb(xn::HandsGenerator& generator, XnUserID nId, const XnPoint3D* pPosition, XnFloat fTime);
	virtual void	onUpdateHandsCb(unsigned int nId, const XnPoint3D* pPosition, float fTime);

	void			onDestroyHandsCb(xn::HandsGenerator& generator, XnUserID nId, XnFloat fTime);
	virtual void	onDestroyHandsCb(unsigned int nId, float fTime);

	// gesture
	void			onRecognizeGestureCb(xn::GestureGenerator& generator,const XnChar* strGesture, const XnPoint3D* pIdPosition,const XnPoint3D* pEndPosition);
	virtual void	onRecognizeGestureCb(const char* strGesture, const XnPoint3D* pIdPosition,const XnPoint3D* pEndPosition);

	void			onProgressGestureCb(xn::GestureGenerator& generator,const XnChar* strGesture, const XnPoint3D* pPosition,XnFloat fProgress);
	virtual void	onProgressGestureCb(const char* strGesture, const XnPoint3D* pPosition,float fProgress);


	//////////////////////////////////////////////////////////////////////////////
	// create methods
	bool createDepth(bool force = true);
	bool createRgb(bool force = true);
	bool createIr(bool force = true);
	bool createScene(bool force = true);
	bool createUser(int flags,bool force = true);
	bool createGesture(bool force = true);
	bool createHands(bool force = true);

	void calcHistogram();
	void createDepthImage();
	void calcDepthImageRealWorld();
	void createIrImage();
	void calcSceneData();

	bool _initFlag;
	bool _generatingFlag;
	
	XnStatus			_rc;
	xn::Context			_context;

	int					_nodes;

	// depht
	xn::DepthGenerator	_depth;
	xn::DepthMetaData	_depthMD;
	XnMapOutputMode		_depthMapOutputMode;
	float				_pDepthHist[MAX_DEPTH];
	XnRGB24Pixel*		_pDepthImage;
	int					_depthBufSize;
	float				_depthImageColor[3];
	XnPoint3D*			_depthMapRealWorld;

	// cam image
	xn::ImageGenerator	_image;
	xn::ImageMetaData	_imageMD;
	XnMapOutputMode		_imageMapOutputMode;
	int					_rgbBufSize;

	// ir
	xn::IRGenerator		_ir;
	xn::IRMetaData		_irMD;
	XnMapOutputMode		_irMapOutputMode;
	XnRGB24Pixel*		_pIrImage;
	int					_irBufSize;

	// scene
	xn::DepthGenerator	_sceneDepth;
	xn::SceneAnalyzer	_sceneAnalyzer;
	xn::SceneMetaData	_sceneMD;
	XnMapOutputMode		_sceneMapOutputMode;
	XnRGB24Pixel*		_pSceneImage;
	int					_sceneBufSize;

	// user
	xn::UserGenerator	_userGenerator;
	XnCallbackHandle	_hUserCb;
	XnCallbackHandle	_hCalibrationCb;
	XnCallbackHandle	_hPoseCb;

	// hands
	xn::HandsGenerator	 _handsGenerator;
	XnCallbackHandle	 _hHandsCb;

	// gesture
	xn::GestureGenerator _gestureGenerator; 
	XnCallbackHandle	 _hGestureCb;
		
	// recorder / player
	xn::Recorder		_recorder;

	bool				_firstTimeUpdate;

};

};

#endif // _CONTEXWRAPPER_H_