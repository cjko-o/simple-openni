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

#ifdef WIN32
	#pragma warning( disable : 4251 )	// disable warnings from NITE
	#pragma warning( disable : 4275 )
#endif

#include <vector>
#include <iostream>

// boost
#include <boost/thread.hpp>
#include <boost/thread/mutex.hpp>
#include <boost/thread/locks.hpp>
#include <boost/shared_ptr.hpp>
#include <boost/cstdint.hpp>

// eigen
#include <Eigen/Geometry>

// OpenNI
#include <XnOS.h>
#include <XnCppWrapper.h>

#include <XnVHandPointContext.h>
#include <XnVSessionManager.h>
#include <XnVSelectableSlider2D.h>

#include "KinectMotor.h"

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

#define		DepthImgMode_Default	0
#define		DepthImgMode_RgbFade	1

#define		RunMode_Default			0
#define		RunMode_SingleThreaded	RunMode_Default
#define		RunMode_MultiThreaded	(RunMode_SingleThreaded + 1)


#define		MAX_DEPTH		10000	// 10m
#define		STRING_BUFFER	255


#define SOPENNI_CB_NAME(FuncName)     FuncName##Cb
#define SOPENNI_CB_STATIC(FuncName,...)\
    public: \
    static void XN_CALLBACK_TYPE FuncName##Cb(__VA_ARGS__);
#define SOPENNI_CB_MEMBER(FuncName,...)\
    protected:\
    void on##FuncName##Cb(__VA_ARGS__);
#define SOPENNI_CB_VIRTUAL(FuncName,...)\
    protected:\
    virtual void on##FuncName##Cb(__VA_ARGS__){;}


namespace sOpenNI{


class ContextWrapper
{
public:

    ContextWrapper();
    ~ContextWrapper();

    int version();

    //////////////////////////////////////////////////////////////////////////////
    // init methods
    static bool initContext();
    bool init(const char* xmlInitFile,int runMode=RunMode_SingleThreaded);
    bool init(int runMode=RunMode_SingleThreaded);

    bool init(int deviceIndex,int runMode);

    void addLicense(const char* vendor,const char* license);

    bool isInit(){	return _initFlag; }
    void close();

    virtual void update();
    static void updateAll();

    int nodes();

    //////////////////////////////////////////////////////////////////////////////
    // multiple devices
    static int deviceCount();
    static int deviceNames(std::vector<std::string>* nodeNames);
    int deviceIndex() const { return _deviceIndex; }


    //////////////////////////////////////////////////////////////////////////////
    // depth methods
    virtual bool enableDepth();
    virtual bool enableDepth(int width,int height,int fps);

    xn::DepthGenerator& getDepthGenerator() { return _depth; }


    int depthWidth();
    int depthHeight();

    int     depthImage(int* map);		// argb 4-Bytes / alpha is not used
    void    setDepthImageColor(int r,int g,int b);
    void    setDepthImageColorMode(int mode);
    int     depthImageColorMode();

    int     depthMapSize();
    int	depthMap(int* map);					// in milimeters
    int     depthMapRealWorld(XnPoint3D map[]);
    int     depthMapRealWorldA(XnPoint3D* map)
    {
        return depthMapRealWorld(map);
    }

    XnPoint3D* depthMapRealWorldA();
    int depthMapRealWorldA(XnPoint3D* map,int count);

    int depthHistSize();
    int depthHistMap(float* histMap);

    float hFieldOfView();
    float vFieldOfView();

    //////////////////////////////////////////////////////////////////////////////
    // cam image
    virtual bool enableRGB();
    virtual bool enableRGB(int width,int height,int fps);

    xn::ImageGenerator& getImageGenerator() { return _image; }

    int rgbWidth();
    int rgbHeight();

    int	rgbImage(int* map);			// argb 4-Bytes / alpha is not used

    //////////////////////////////////////////////////////////////////////////////
    // ir image
    virtual bool enableIR();
    virtual bool enableIR(int width,int height,int fps);

    xn::IRGenerator& getIRGenerator() { return _ir; }

    int irWidth();
    int irHeight();

    int irMap(int* map);			// 16-bit value
    int irImage(int* map);			// argb 4-Bytes / alpha is not used

    //////////////////////////////////////////////////////////////////////////////
    // scene analyzer
    virtual bool enableScene();
    virtual bool enableScene(int width,int height,int fps);

    xn::SceneAnalyzer& getSceneAnalyzer() { return _sceneAnalyzer; }

    int sceneWidth();
    int sceneHeight();

    int sceneMap(int* map);
    int sceneImage(int* map);		// 16-bit value, with the labels, size of the depth map
    void getSceneFloor(XnVector3D* point,
                       XnVector3D* normal);
    void getSceneFloorCoordsys(float* matrix);		// 4*4 matrix, rotation + translation to the nearest point
    // on the floor plane to the camera as null point

    //////////////////////////////////////////////////////////////////////////////
    // users
    virtual bool enableUser(int flags);

    xn::UserGenerator& getUserGenerator() { return _userGenerator; }

    int	userWidth();
    int	userHeight();

    bool	getCoM(int user, XnPoint3D&  com);
    int     getNumberOfUsers();
    int     getUsers(std::vector<int>* userList);
    int     getUserPixels(int user,int* userSceneData);

    bool	getUserPostition(int user, XnBoundingBox3D*  pPosition );

    bool	isCalibratedSkeleton(int user);
    bool	isCalibratingSkeleton(int user);
    void	requestCalibrationSkeleton(int user, bool force);
    void	abortCalibrationSkeleton(int user);

    bool	saveCalibrationDataSkeleton(int user,int slot);
    bool	loadCalibrationDataSkeleton(int user,int slot);
    void	clearCalibrationDataSkeleton(int slot);
    bool	isCalibrationDataSkeleton(int slot);

    bool	saveCalibrationDataSkeleton(int user,const char* calibrationFile);
    bool	loadCalibrationDataSkeleton(int user,const char* calibrationFile);

    void	setSmoothingSkeleton(float factor);

    bool	isTrackingSkeleton(int user);
    void	startTrackingSkeleton(int user);
    void	stopTrackingSkeleton(int user);

    void	startPoseDetection(const char* pose,int user);
    void	stopPoseDetection(int user);

    bool	getJointPositionSkeleton(int user,int joint,XnSkeletonJointPosition* jointPos);
    bool	getJointOrientationSkeleton(int user,
                                        int joint,
                                        XnSkeletonJointOrientation* jointOrientation);


    //////////////////////////////////////////////////////////////////////////////
    // hands
    virtual bool enableHands();

    xn::HandsGenerator& getHandsGenerator() { return _handsGenerator; }

    void	startTrackingHands(const XnVector3D& pos);
    void	stopTrackingHands(int handId);
    void	stopTrackingAllHands();
    void	setSmoothingHands(float smoothingFactor);

    //////////////////////////////////////////////////////////////////////////////
    // gesture
    virtual bool enableGesture();

    xn::GestureGenerator& getGestureGenerator() { return _gestureGenerator; }

    void addGesture(const char* gesture);
    void removeGesture(const char* gesture);
    bool availableGesture(const char *strGesture);
    // void addGesture(const char* gesture,XnBoundingBox3D *  pArea);

    //////////////////////////////////////////////////////////////////////////////
    // audio
    //bool enableAudio();

    //////////////////////////////////////////////////////////////////////////////
    // recorder
    virtual bool enableRecorder(int recordMedium,const char* filePath);
    bool addNodeToRecording(int nodeType,int compression);
    bool removeNodeFromRecording(int nodeType);

    //////////////////////////////////////////////////////////////////////////////
    // player
    virtual bool openFileRecording(const char* filePath);

    void setPlaybackSpeedPlayer(float speed);
    float playbackSpeedPlayer();

    void setRepeatPlayer(bool loop);
    bool repeatPlayer();

    unsigned int curFramePlayer();
    unsigned int framesPlayer();
    void seekPlayer(int offset,int seekType);

    bool isEndPlayer();

    //////////////////////////////////////////////////////////////////////////////
    // access methods
    void setMirror(bool flag);
    bool mirror();

    //////////////////////////////////////////////////////////////////////////////
    // converter methods
    void convertRealWorldToProjective(XnVector3D* world,XnVector3D* proj);
    void convertRealWorldToProjective(std::vector<XnVector3D>* worldArray,std::vector<XnVector3D>* projArray);

    void convertProjectiveToRealWorld(XnVector3D* proj,XnVector3D* world);
    void convertProjectiveToRealWorld(std::vector<XnVector3D>* projArray,std::vector<XnVector3D>* worldArray);

    bool alternativeViewPointDepthToImage();

    ///////////////////////////////////////////////////////////////////////////
    // kinect motor
    void moveKinect(float angle);
	
    ///////////////////////////////////////////////////////////////////////////
    // calibration
    void setUserCoordsys(float centerX,float centerY,float centerZ,
						float xDirX,float xDirY,float xDirZ,
						float zDirX,float zDirY,float zDirZ);
    bool setUserCoordsys(XnPoint3D fromPoints[],
                         XnPoint3D toPoints[]);
    bool setUserCoordsys(float mat[]);

    void resetUserCoordsys();
    bool hasUserCoordsys() const;
    float* getUserCoordsysTransMat();	// returns the 4x4 matrix
    void getUserCoordsysTransMat(float* mat);	// needs a 4x4 float array

    bool getOrigUserCoordsys(float* nullPointX,float* nullPointY,float* nullPointZ,
                             float* xAxisX,float* xAxisY,float* xAxisZ,
                             float* yAxisX,float* yAxisY,float* yAxisZ,
                             float* zAxisX,float* zAxisY,float* zAxisZ);
    void calcUserCoordsys(XnPoint3D& point);
    void calcUserCoordsys(XnMatrix3X3& mat);

    void calcUserCoordsysBack(XnPoint3D& point);
    void calcUserCoordsysBack(XnMatrix3X3& mat);

    void getUserCoordsys(float mat[]);	// needs a 4x4 float array
    void getUserCoordsysBack(float mat[]);	// needs a 4x4 float array

    ///////////////////////////////////////////////////////////////////////////
    // geometry helper functions

    static bool rayTriangleIntersection(float p[],
                                        float dir[],
                                        float vec0[],
                                        float vec1[],
                                        float vec2[],
                                        float hit[]);

    static int raySphereIntersection(float p[],
                                     float dir[],
                                     float sphereCenter[],
                                     float sphereRadius,
                                     float hit1[],float hit2[]);

    ///////////////////////////////////////////////////////////////////////////
    // callbacks

    // user
    SOPENNI_CB_STATIC(NewUser,
                      xn::UserGenerator& generator, XnUserID user, void* cxt)
    SOPENNI_CB_MEMBER(NewUser,
                      xn::UserGenerator& generator, XnUserID user)
    SOPENNI_CB_VIRTUAL(NewUser,
                       unsigned int user)

    SOPENNI_CB_STATIC(LostUser,
                      xn::UserGenerator& generator, XnUserID user, void* cxt)
    SOPENNI_CB_MEMBER(LostUser,
                      xn::UserGenerator& generator, XnUserID user)
    SOPENNI_CB_VIRTUAL(LostUser,
                       unsigned int user)

    SOPENNI_CB_STATIC(ExitUser,
                      xn::UserGenerator& generator, XnUserID user, void* cxt)
    SOPENNI_CB_MEMBER(ExitUser,
                      xn::UserGenerator& generator, XnUserID user)
    SOPENNI_CB_VIRTUAL(ExitUser,
                       unsigned int user)

    SOPENNI_CB_STATIC(ReEnterUser,
                      xn::UserGenerator& generator, XnUserID user, void* cxt)
    SOPENNI_CB_MEMBER(ReEnterUser,
                      xn::UserGenerator& generator, XnUserID user)
    SOPENNI_CB_VIRTUAL(ReEnterUser,
                       unsigned int user)

    // calibration
    SOPENNI_CB_STATIC(StartCalibration,
                      xn::SkeletonCapability& skeleton, XnUserID user, void* cxt)
    SOPENNI_CB_MEMBER(StartCalibration,
                      xn::SkeletonCapability& skeleton, XnUserID user)
    SOPENNI_CB_VIRTUAL(StartCalibration,
                       unsigned int user)

    SOPENNI_CB_STATIC(EndCalibration,
                      xn::SkeletonCapability& skeleton, XnUserID user, XnBool bSuccess, void* cxt)
    SOPENNI_CB_MEMBER(EndCalibration,
                      xn::SkeletonCapability& skeleton, XnUserID user, XnBool bSuccess)
    SOPENNI_CB_VIRTUAL(EndCalibration,
                       unsigned int user, bool bSuccess)

public:

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

    ///////////////////////////////////////////////////////////////////////////
    // NITE

    // session
    static void XN_CALLBACK_TYPE onStartSessionCb(const XnPoint3D& ptPosition, void* cxt);
    static void XN_CALLBACK_TYPE onEndSessionCb(void* cxt);
    static void XN_CALLBACK_TYPE onFocusSessionCb(const XnChar* strFocus, const XnPoint3D& ptPosition, XnFloat fProgress, void* UserCxt);


    ///////////////////////////////////////////////////////////////////////////
    // node helper
    static int getNodeType(int internalType);
    xn::ProductionNode* getNode(int internalType);


    ///////////////////////////////////////////////////////////////////////////
    // XnVSessionManager
    XnVSessionManager* createSessionManager(const XnChar* strUseAsFocus, const XnChar* strUseAsQuickRefocus,
                                            xn::HandsGenerator* pTracker = NULL, xn::GestureGenerator* pFocusGenerator = NULL,
                                            xn::GestureGenerator* pQuickRefocusGenerator = NULL);

    void update(XnVSessionManager* sessionManager);

protected:

    enum LogOutMsg{
        MsgNode_End	= 0,
        MsgNode_Info	= 1,
        MsgNode_Error	= 2,

    };

    static void logOut(int msgType,const char* msg,...);	// must end with null

    bool checkLicenses();

    // need NodeInfoList as parameterm otherwise the result in NodeInfo will be destroyed with
    // the destruction of the NodeInfoList
    static bool getNodeInfo(int nodeType,int index,
                            xn::NodeInfoList*   list,
                            xn::NodeInfo*       pNodeInfo,
                            int offset = 1);

    static std::vector<class ContextWrapper*> _classList;
    static KinectMotors _kinectMotors;

    //////////////////////////////////////////////////////////////////////////////
    // internal callback wrappers


    virtual void onStartPoseCb(const char* strPose, unsigned int user);
    virtual void onEndPoseCb(const char* strPose, unsigned int user);

    // calibration

    void onStartPoseCb(xn::PoseDetectionCapability& pose, const XnChar* strPose, XnUserID user);
    void onEndPoseCb(xn::PoseDetectionCapability& pose, const XnChar* strPose, XnUserID user);

    // hands
    void		onCreateHandsCb(xn::HandsGenerator& generator, XnUserID nId, const XnPoint3D* pPosition, XnFloat fTime);
    virtual void	onCreateHandsCb(unsigned int nId, const XnPoint3D* pPosition, float fTime);

    void		onUpdateHandsCb(xn::HandsGenerator& generator, XnUserID nId, const XnPoint3D* pPosition, XnFloat fTime);
    virtual void	onUpdateHandsCb(unsigned int nId, const XnPoint3D* pPosition, float fTime);

    void		onDestroyHandsCb(xn::HandsGenerator& generator, XnUserID nId, XnFloat fTime);
    virtual void	onDestroyHandsCb(unsigned int nId, float fTime);

    // gesture
    void		onRecognizeGestureCb(xn::GestureGenerator& generator,const XnChar* strGesture, const XnPoint3D* pIdPosition,const XnPoint3D* pEndPosition);
    virtual void	onRecognizeGestureCb(const char* strGesture, const XnPoint3D* pIdPosition,const XnPoint3D* pEndPosition);

    void		onProgressGestureCb(xn::GestureGenerator& generator,const XnChar* strGesture, const XnPoint3D* pPosition,XnFloat fProgress);
    virtual void	onProgressGestureCb(const char* strGesture, const XnPoint3D* pPosition,float fProgress);

    ///////////////////////////////////////////////////////////////////////////
    // NITE

    virtual void onStartSessionCb(const XnPoint3D& ptPosition);
    virtual void onEndSessionCb();
    virtual void onFocusSessionCb(const XnChar* strFocus, const XnPoint3D& ptPosition, XnFloat fProgress);

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

    bool updateDepthData();
    bool updateDepthImageData();
    bool updateDepthRealWorldData();

    void updateRgbData();

    void updateIrData();

    void updateSceneData();
    void updateSceneImageData();

    void updateUser();
    void updateHands();
    void updateGesture();

    bool _initFlag;
    bool _generatingFlag;

    static xn::Context      _globalContext;
    static bool             _globalContextFlag;

    xn::Device              _device;
    std::string             _deviceCreationInfo;

    XnStatus		_rc;

    int                     _deviceIndex;
    static int		_deviceCount;
    int                     _nodes;

    // depht
    xn::DepthGenerator	_depth;
    xn::DepthMetaData	_depthMD;
    XnMapOutputMode		_depthMapOutputMode;
    float               _pDepthHist[MAX_DEPTH];
    float               _pDepthGamma[MAX_DEPTH];
    XnRGB24Pixel*		_pDepthImage;
    int                 _depthBufSize;
    XnDepthPixel*       _depthMap;
    float               _depthImageColor[3];
    XnPoint3D*          _depthMapRealWorld;
    int                 _depthImageColorMode;

    // cam image
    xn::ImageGenerator	_image;
    xn::ImageMetaData	_imageMD;
    XnMapOutputMode		_imageMapOutputMode;
    int			_rgbBufSize;

    // ir
    xn::IRGenerator		_ir;
    xn::IRMetaData		_irMD;
    XnMapOutputMode		_irMapOutputMode;
    XnRGB24Pixel*		_pIrImage;
    int			_irBufSize;

    // scene
    xn::DepthGenerator	_sceneDepth;
    xn::SceneAnalyzer	_sceneAnalyzer;
    xn::SceneMetaData	_sceneMD;
    XnMapOutputMode		_sceneMapOutputMode;
    XnRGB24Pixel*		_pSceneImage;
    int			_sceneBufSize;

    // user
    xn::UserGenerator	_userGenerator;
    XnCallbackHandle	_hUserCb;
    XnCallbackHandle	_hUserExitCb;
    XnCallbackHandle	_hUserReEnterCb;
    XnCallbackHandle	_hCalibrationCb;
    XnCallbackHandle	_hToCalibrationCompleteCb;
    XnCallbackHandle	_hToCalibrationStartCb;
    XnCallbackHandle	_hCalibrationToJointConfigurationChangeCb;

    XnCallbackHandle	_hPoseCb;
    int			_userWidth;
    int			_userHeight;
    int			_userSceneBufSize;

    // hands
    xn::HandsGenerator	 _handsGenerator;
    XnCallbackHandle	 _hHandsCb;

    // gesture
    xn::GestureGenerator     _gestureGenerator;
    XnCallbackHandle	 _hGestureCb;

    // recorder / player
    xn::Recorder		_recorder;
    xn::Player          _player;
    bool                _playerRepeat;

    bool			_firstTimeUpdate;

    ///////////////////////////////////////////////////////////////////////////
    // NITE
    std::vector<XnVSessionManager*>		_sessionManagerList;


    ///////////////////////////////////////////////////////////////////////////
    // update flags, performance

    // timestamps
    unsigned long 	_depthMapTimeStamp;
    unsigned long 	_depthImageTimeStamp;
    unsigned long 	_depthRealWorldTimeStamp;

    unsigned long 	_imageTimeStamp;

    unsigned long 	_irTimeStamp;

    unsigned long 	_sceneTimeStamp;
    unsigned long	_sceneImageTimeStamp;

    unsigned long 	_userTimeStamp;
    unsigned long 	_gestureTimeStamp;
    unsigned long 	_handsTimeStamp;

    unsigned long 	_updateTimeStamp;
    unsigned long 	_updateSubTimeStamp;

    ///////////////////////////////////////////////////////////////////////////
    // calibration
	bool										_userCoordsysFlag;
    Eigen::Transform<float,3,Eigen::Affine> 	_userCoordsysForwardMat;
    Eigen::Transform<float,3,Eigen::Affine> 	_userCoordsysRetMat;
    float                                       _userCoordsysMat[16];
	Eigen::Vector3f								_userCoordsysNullPoint;
	Eigen::Vector3f								_userCoordsysXAxis;
	Eigen::Vector3f								_userCoordsysYAxis;
	Eigen::Vector3f								_userCoordsysZAxis;
	
public:
    inline unsigned long depthMapTimeStamp(){ return _depthMapTimeStamp; }
    inline unsigned long depthImageTimeStamp(){ return _depthImageTimeStamp; }
    inline unsigned long depthRealWorldTimeStamp(){ return _depthRealWorldTimeStamp; }
    inline unsigned long imageTimeStamp(){ return _imageTimeStamp; }
    inline unsigned long irTimeStamp(){ return _irTimeStamp; }
    inline unsigned long sceneTimeStamp(){ return _sceneTimeStamp; }
    inline unsigned long userTimeStamp(){ return _userTimeStamp; }
    inline unsigned long handsTimeStamp(){ return _handsTimeStamp; }

    inline unsigned long updateTimeStamp(){ return _updateTimeStamp; }
    inline unsigned long updateSubTimeStamp(){ return _updateSubTimeStamp; }

    inline bool newThreadData()
    {
        return(_updateTimeStamp != _updateSubTimeStamp);
    }

    inline bool newDepthMapThreadData()
    {
        return(_depthMapTimeStamp != _updateTimeStamp) && newThreadData();
    }

    inline bool newDepthImageThreadData()
    {
        return(_depthImageTimeStamp != _updateTimeStamp) && newThreadData();
    }

    inline bool newDepthRealWorldThreadData()
    {
        return(_depthRealWorldTimeStamp != _updateTimeStamp) && newThreadData();
    }

    ///////////////////////////////////////////////////////////////////////////
    // threading

private:

    void updateSub();
    void run();

    boost::shared_ptr<boost::thread>	_thread;
    boost::mutex				_mainMutex;
    bool					_threadRun;
    int									_threadMode;

};


};


// virtual method test

class TestClass
{
public:
    TestClass()
    {}

    virtual void test1(int i)
    {
        std::cout << "TestClass::test1 - " << i << std::endl;
    }

    virtual void testX(XnVector3D* p)
    {
        std::cout << "TestClass::testX - " << std::endl;
    }

    static void test(TestClass* p)
    {
        p->test1(100);
    }

protected:

};


#endif // _CONTEXWRAPPER_H_
