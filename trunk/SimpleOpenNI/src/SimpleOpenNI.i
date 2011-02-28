# -----------------------------------------------------------------------------
# SimpleOpenNI 
# -----------------------------------------------------------------------------
# Processing Wrapper for the OpenNI/Kinect library
# prog:  Max Rheiner / Interaction Design / zhkd / http://iad.zhdk.ch/
# -----------------------------------------------------------------------------

%module(directors="1") SimpleOpenNI

%{
#include "ContextWrapper.h"
%}

%include "arrays_java.i"
%include "cpointer.i"
%include "typemaps.i"
%include "carrays.i"

%apply int[] {int *};

# ----------------------------------------------------------------------------/
# Xn

JAVA_ARRAYSOFCLASSES(XnVector3D)

typedef	float XnFloat;

typedef struct XnVector3D
{
	XnFloat X;
	XnFloat Y;
	XnFloat Z;
} XnVector3D;

typedef XnVector3D XnPoint3D;

typedef XnFloat  XnConfidence;

typedef struct XnSkeletonJointPosition
{
	XnVector3D		position;

	XnConfidence	fConfidence;
} XnSkeletonJointPosition;


# ----------------------------------------------------------------------------/
# stl

%include "std_vector.i"
namespace std {
   %template(IntVector) vector<int>;
   %template(Vector3D) vector<XnVector3D>;
};

# ----------------------------------------------------------------------------/
# ContextWrapper

namespace sOpenNI{

typedef XnPoint3D*	XnPoint3DArray;
JAVA_ARRAYSOFCLASSES(XnPoint3DArray)
%apply XnPoint3D[] {XnPoint3DArray};

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

%feature("director") ContextWrapper;
class ContextWrapper
{
public:
	ContextWrapper();

	int version();

	bool init(const char* xmlInitFile);
	bool isInit();
	void close();
	
	virtual bool enableDepth();
	virtual bool enableRGB();
	virtual bool enableIR();
	virtual bool enableScene();
	virtual bool enableUser(int flags);
	virtual bool enableHands();
	virtual bool enableGesture();

	virtual void update();

	int depthWidth();
	int	depthHeight();
	int	depthImage(int* map);	
	void setDepthImageColor(int r,int g,int b);
	
	int depthMapSize();
	int	depthMap(int* map);					
	int depthMapRealWorld(XnPoint3D map[]);	
	XnPoint3DArray depthMapRealWorldA();		

	float hFieldOfView();
	float vFieldOfView();
	
	int rgbWidth();
	int rgbHeight();
	int	rgbImage(int* map);	
	
	int irWidth();
	int irHeight();
	int	irMap(int* map);	
	int	irImage(int* map);	

	int sceneWidth();
	int sceneHeight();
	int sceneMap(int* map);			
	int sceneImage(int* map);
	void getSceneFloor(XnVector3D* point,
					   XnVector3D* normal);
	
	int		getUsers(std::vector<int>* userList);
	
	bool	isCalibratedSkeleton(int user);
	void	requestCalibrationSkeleton(int user, bool force);

	bool	isTrackingSkeleton(int user);
	void	startTrackingSkeleton(int user);
	void	stopTrackingSkeleton(int user);

	void	startPoseDetection(const char* pose,int user);
	void	stopPoseDetection(int user);
	
	bool getJointPositionSkeleton(int user,int joint,XnSkeletonJointPosition* jointPos);
	
	void	startTrackingHands(const XnVector3D& pos);
	void	stopTrackingHands(int handId);
	void	stopTrackingAllHands();
	void	setSmoothingHands(float smoothingFactor);

	void addGesture(const char* gesture);
	void removeGesture(const char* gesture);
	bool availableGesture(const char *strGesture);
				   
	void setMirror(bool flag);
	bool mirror();
		
	void convertRealWorldToProjective(XnVector3D* world,XnVector3D* proj);	
	void convertRealWorldToProjective(std::vector<XnVector3D>* worldArray,std::vector<XnVector3D>* projArray);

	void convertProjectiveToRealWorld(XnVector3D* proj,XnVector3D* world);	
	void convertProjectiveToRealWorld(std::vector<XnVector3D>* projArray,std::vector<XnVector3D>* worldArray);

protected:
	virtual void onNewUserCb(unsigned int userId);
	virtual void onLostUserCb(unsigned int userId);
	
	virtual void onStartCalibrationCb(unsigned int userId);
	virtual void onEndCalibrationCb(unsigned int userId,bool successFlag);

	virtual void onStartPoseCb(const char* strPose, unsigned int user);
	virtual void onEndPoseCb(const char* strPose, unsigned int user);

	virtual void onCreateHandsCb(unsigned int nId, const XnPoint3D* pPosition, float fTime);
	virtual void onUpdateHandsCb(unsigned int nId, const XnPoint3D* pPosition, float fTime);
	virtual void onDestroyHandsCb(unsigned int nId, float fTime);

	virtual void onRecognizeGestureCb(const char* strGesture, const XnPoint3D* pIdPosition,const XnPoint3D* pEndPosition);
	virtual void onProgressGestureCb(const char* strGesture, const XnPoint3D* pPosition,float fProgress);
	
};

};