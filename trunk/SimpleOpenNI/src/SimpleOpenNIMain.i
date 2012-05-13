# -----------------------------------------------------------------------------
# SimpleOpenNIMain
# -----------------------------------------------------------------------------
# Processing Wrapper for the OpenNI/Kinect library
# prog:  Max Rheiner / Interaction Design / zhdk / http://iad.zhdk.ch/
# -----------------------------------------------------------------------------

%module(directors="1") SimpleOpenNI

%{
#include "ContextWrapper.h"
#include "NITE_Helpers.h"
#include <string>
#include <vector>
%}

%include "arrays_java.i"
%include "cpointer.i"
%include "typemaps.i"
%include "carrays.i"

%apply int[] {int *};
%apply float[] {float *};


# ----------------------------------------------------------------------------
# OpenNI

%include "SimpleOpenNI.i"


# ----------------------------------------------------------------------------
# stl

%include "std_vector.i"
%include "std_string.i"

%template(IntVector)	std::vector<int>;
%template(Vector3D)	std::vector<XnVector3D>;
%template(Point3D)	std::vector<XnPoint3D>;

%template(StrVector)	std::vector<std::string>;


# ----------------------------------------------------------------------------
# ContextWrapper

namespace sOpenNI{

	/*
typedef XnPoint3D*	XnPoint3DArrayX;
JAVA_ARRAYSOFCLASSES(XnPoint3DArrayX)
%apply XnPoint3D[] {XnPoint3DArrayX};
*/

%constant int USERS_ALL				= 0;		

%constant int SKEL_PROFILE_NONE		= XN_SKEL_PROFILE_NONE;
%constant int SKEL_PROFILE_ALL		= XN_SKEL_PROFILE_ALL;
%constant int SKEL_PROFILE_UPPER	= XN_SKEL_PROFILE_UPPER;
%constant int SKEL_PROFILE_LOWER	= XN_SKEL_PROFILE_LOWER;
%constant int SKEL_PROFILE_HEAD_HANDS = XN_SKEL_PROFILE_HEAD_HANDS;

%constant int SKEL_HEAD				= XN_SKEL_HEAD;		
%constant int SKEL_NECK				= XN_SKEL_NECK;			
%constant int SKEL_TORSO			= XN_SKEL_TORSO;
%constant int SKEL_WAIST			= XN_SKEL_WAIST;		
									 
%constant int SKEL_LEFT_COLLAR		= XN_SKEL_LEFT_COLLAR;
%constant int SKEL_LEFT_SHOULDER	= XN_SKEL_LEFT_SHOULDER;	
%constant int SKEL_LEFT_ELBOW		= XN_SKEL_LEFT_ELBOW;		
%constant int SKEL_LEFT_WRIST		= XN_SKEL_LEFT_WRIST;		
%constant int SKEL_LEFT_HAND		= XN_SKEL_LEFT_HAND;	
%constant int SKEL_LEFT_FINGERTIP	= XN_SKEL_LEFT_FINGERTIP;
									 
%constant int SKEL_RIGHT_COLLAR		= XN_SKEL_RIGHT_COLLAR;	
%constant int SKEL_RIGHT_SHOULDER	= XN_SKEL_RIGHT_SHOULDER;	
%constant int SKEL_RIGHT_ELBOW		= XN_SKEL_RIGHT_ELBOW;		
%constant int SKEL_RIGHT_WRIST		= XN_SKEL_RIGHT_WRIST;		
%constant int SKEL_RIGHT_HAND		= XN_SKEL_RIGHT_HAND;		
%constant int SKEL_RIGHT_FINGERTIP	= XN_SKEL_RIGHT_FINGERTIP;	
									 
%constant int SKEL_LEFT_HIP			= XN_SKEL_LEFT_HIP;		
%constant int SKEL_LEFT_KNEE		= XN_SKEL_LEFT_KNEE;		
%constant int SKEL_LEFT_ANKLE		= XN_SKEL_LEFT_ANKLE;		
%constant int SKEL_LEFT_FOOT		= XN_SKEL_LEFT_FOOT;		
									 
%constant int SKEL_RIGHT_HIP		= XN_SKEL_RIGHT_HIP;		
%constant int SKEL_RIGHT_KNEE		= XN_SKEL_RIGHT_KNEE;		
%constant int SKEL_RIGHT_ANKLE		= XN_SKEL_RIGHT_ANKLE;		
%constant int SKEL_RIGHT_FOOT		= XN_SKEL_RIGHT_FOOT;		


%constant int NODE_NONE			= Node_None;		
%constant int NODE_DEPTH		= Node_Depth;		
%constant int NODE_IMAGE		= Node_Image;		
%constant int NODE_IR			= Node_Ir;		
%constant int NODE_SCENE		= Node_Scene;		
%constant int NODE_USER			= Node_User;		
%constant int NODE_HANDS		= Node_Hands;		
%constant int NODE_GESTURE		= Node_Gesture;		
%constant int NODE_RECORDER		= Node_Recorder;		
%constant int NODE_PLAYER		= Node_Player;		

%constant int CODEC_NONE		= XN_CODEC_NULL;
%constant int CODEC_UNCOMPRESSED	= XN_CODEC_UNCOMPRESSED;		
%constant int CODEC_JPEG		= XN_CODEC_JPEG;
%constant int CODEC_16Z			= XN_CODEC_16Z;
%constant int CODEC_16Z_EMB_TABLES	= XN_CODEC_16Z_EMB_TABLES;		
%constant int CODEC_CODEC_8Z		= XN_CODEC_8Z;		

%constant int RECORD_MEDIUM_FILE	= XN_CODEC_NULL;

%constant int PLAYER_SEEK_SET           = XN_PLAYER_SEEK_SET;
%constant int PLAYER_SEEK_CUR           = XN_PLAYER_SEEK_CUR;
%constant int PLAYER_SEEK_END           = XN_PLAYER_SEEK_END;


%constant int IMG_MODE_DEFAULT          = DepthImgMode_Default;
%constant int IMG_MODE_RGB_FADE         = DepthImgMode_RgbFade;

%constant int RUN_MODE_DEFAULT		= RunMode_Default;
%constant int RUN_MODE_SINGLE_THREADED	= RunMode_SingleThreaded;		
%constant int RUN_MODE_MULTI_THREADED	= RunMode_MultiThreaded;		



%feature("director") ContextWrapper;
class ContextWrapper
{
public:

	ContextWrapper();

	int version();

        static bool initContext();

        bool init(const char* xmlInitFile,int runMode=RunMode_MultiThreaded);
        bool init(int runMode=RunMode_MultiThreaded);
        bool init(int deviceIndex,int runMode);

        int nodes();

        static int deviceCount();
        static int deviceNames(std::vector<std::string>* nodeNames);

	void addLicense(const char* vendor,const char* license);
	
	bool isInit();
	void close();

	virtual bool enableDepth();
	virtual bool enableDepth(int width,int height,int fps);
        xn::DepthGenerator& getDepthGenerator();

	virtual bool enableRGB();
	virtual bool enableRGB(int width,int height,int fps);
        xn::ImageGenerator& getImageGenerator();

	virtual bool enableIR();
	virtual bool enableIR(int width,int height,int fps);
        xn::IRGenerator& getIRGenerator();

	virtual bool enableScene();
	virtual bool enableScene(int width,int height,int fps);
        xn::SceneAnalyzer& getSceneAnalyzer();

	virtual bool enableUser(int flags);
        xn::UserGenerator& getUserGenerator();

	virtual bool enableHands();
        xn::HandsGenerator& getHandsGenerator();

        virtual bool enableGesture();
        xn::GestureGenerator& getGestureGenerator();

	virtual void update();
        static void updateAll();

        int     depthWidth();
	int	depthHeight();
	int	depthImage(int* map);	
        void    setDepthImageColor(int r,int g,int b);
        void    setDepthImageColorMode(int mode);
        int     depthImageColorMode();
	
        int     depthMapSize();
	int	depthMap(int* map);					
        int     depthMapRealWorld(XnPoint3D map[]);
        int     depthMapRealWorldA(XnPoint3DArray* map);
	//int depthMapRealWorldA(XnPoint3DArray map,int count);

	XnPoint3DArray* depthMapRealWorldA();		

	float hFieldOfView();
	float vFieldOfView();
	
	int rgbWidth();
	int rgbHeight();
        int rgbImage(int* map);
	
	int irWidth();
	int irHeight();
        int irMap(int* map);
        int irImage(int* map);

	int sceneWidth();
	int sceneHeight();
	int sceneMap(int* map);			
	int sceneImage(int* map);
	void getSceneFloor(XnVector3D* point,
					   XnVector3D* normal);
	
        int	userWidth();
        int	userHeight();

	bool	getCoM(int user, XnPoint3D&  com);
        int	getNumberOfUsers();
        int	getUsers(std::vector<int>* userList);
        int	getUserPixels(int user,int* userSceneData);

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
	

	
	void	startTrackingHands(const XnVector3D& pos);
	void	stopTrackingHands(int handId);
	void	stopTrackingAllHands();
	void	setSmoothingHands(float smoothingFactor);

	void addGesture(const char* gesture);
	void removeGesture(const char* gesture);
	bool availableGesture(const char *strGesture);
	
	virtual bool enableRecorder(int recordMedium,const char* filePath);
	bool addNodeToRecording(int nodeType,int compression);
	bool removeNodeFromRecording(int nodeType);	
	
	virtual bool openFileRecording(const char* filePath);
        void setPlaybackSpeedPlayer(float speed);
        float playbackSpeedPlayer();

        void setRepeatPlayer(bool loop);
        bool repeatPlayer();

        unsigned int curFramePlayer();
        unsigned int framesPlayer();
        void seekPlayer(int offset,int seekType);

        bool isEndPlayer();


	void setMirror(bool flag);
	bool mirror();
		
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
        void resetUserCoordsys();
        bool hasUserCoordsys() const;
//        float* getUserCoordsysTransMat();	// returns the 4x4 matrix
        void getUserCoordsysTransMat(float* mat);// needs a 4x4 float array


        void calcUserCoordsys(XnPoint3D& point);
        void calcUserCoordsys(XnMatrix3X3& mat);

        void calcUserCoordsysBack(XnPoint3D& point);
        void calcUserCoordsysBack(XnMatrix3X3& mat);

        void getUserCoordsys(float mat[]);	// needs a 4x4 float array
        void getUserCoordsysBack(float mat[]);	// needs a 4x4 float array

/*
        bool getOrigUserCoordsys(float* nullPointX,float* nullPointY,float* nullPointZ,
                                 float* xAxisX,float* xAxisY,float* xAxisZ,
                                 float* yAxisX,float* yAxisY,float* yAxisZ,
                                 float* zAxisX,float* zAxisY,float* zAxisZ);
*/
        ///////////////////////////////////////////////////////////////////////////
	// XnVSessionMananger
	XnVSessionManager* createSessionManager(const XnChar* strUseAsFocus, const XnChar* strUseAsQuickRefocus,
											 xn::HandsGenerator*	pTracker = NULL, 
											 xn::GestureGenerator*	pFocusGenerator = NULL,
											 xn::GestureGenerator*	pQuickRefocusGenerator = NULL);

	void update(XnVSessionManager* sessionManager);



	///////////////////////////////////////////////////////////////////////////
	// time stamps

	unsigned long depthMapTimeStamp();
	unsigned long depthImageTimeStamp();
	unsigned long depthRealWorldTimeStamp();
	unsigned long imageTimeStamp();
	unsigned long irTimeStamp();
	unsigned long sceneTimeStamp();
	unsigned long userTimeStamp();
	unsigned long handsTimeStamp();

	unsigned long updateTimeStamp();
	unsigned long updateSubTimeStamp();

protected:

        virtual void onNewUserCb(unsigned int userId);
        virtual void onLostUserCb(unsigned int userId);

        virtual void onExitUserCb(unsigned int userId);
        virtual void onReEnterUserCb(unsigned int userId);

        virtual void onStartCalibrationCb(unsigned int userId);
	virtual void onEndCalibrationCb(unsigned int userId,bool successFlag);

	virtual void onStartPoseCb(const char* strPose, unsigned int user);
	virtual void onEndPoseCb(const char* strPose, unsigned int user);

	virtual void onCreateHandsCb(unsigned int nId, const XnPoint3D* pPosition, float fTime);
	virtual void onUpdateHandsCb(unsigned int nId, const XnPoint3D* pPosition, float fTime);
	virtual void onDestroyHandsCb(unsigned int nId, float fTime);

	virtual void onRecognizeGestureCb(const char* strGesture, const XnPoint3D* pIdPosition,const XnPoint3D* pEndPosition);
	virtual void onProgressGestureCb(const char* strGesture, const XnPoint3D* pPosition,float fProgress);

	virtual void onStartSessionCb(const XnPoint3D& ptPosition);
	virtual void onEndSessionCb();
	virtual void onFocusSessionCb(const XnChar* strFocus, const XnPoint3D& ptPosition, XnFloat fProgress);

};

};




# ----------------------------------------------------------------------------
# NITE

%include "SimpleNite.i"
