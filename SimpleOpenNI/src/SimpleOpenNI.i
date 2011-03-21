# -----------------------------------------------------------------------------
# SimpleOpenNI 
# -----------------------------------------------------------------------------
# Processing Wrapper for the OpenNI/Kinect library
# prog:  Max Rheiner / Interaction Design / zhdk / http://iad.zhdk.ch/
# -----------------------------------------------------------------------------

%module(directors="1") SimpleOpenNI

%{
#include "ContextWrapper.h"
#include "NITE_Helpers.h"
%}

%include "arrays_java.i"
%include "cpointer.i"
%include "typemaps.i"
%include "carrays.i"

%apply int[] {int *};

# ----------------------------------------------------------------------------
# Xn

JAVA_ARRAYSOFCLASSES(XnVector3D)

typedef	bool			XnBool;
typedef	char			XnChar;
typedef	unsigned int	XnUInt32;
typedef	float			XnFloat;
typedef XnUInt32		XnVHandle;
typedef XnUInt32		XnStatus;

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

typedef struct XnMatrix3X3
{
	XnFloat elements[9];
} XnMatrix3X3;

typedef struct XnSkeletonJointOrientation
{
	XnMatrix3X3		orientation;
	XnConfidence	fConfidence;
} XnSkeletonJointOrientation;

typedef struct XnVCircle
{
    XnPoint3D ptCenter;
    XnFloat fRadius;
}XnVCircle;


# ----------------------------------------------------------------------------
# stl

%include "std_vector.i"
namespace std {
   %template(IntVector) vector<int>;
   %template(Vector3D) vector<XnVector3D>;
};

# ----------------------------------------------------------------------------
# ContextWrapper

namespace sOpenNI{

typedef XnPoint3D*	XnPoint3DArray;
JAVA_ARRAYSOFCLASSES(XnPoint3DArray)
%apply XnPoint3D[] {XnPoint3DArray};

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

%constant int CODEC_NONE			= XN_CODEC_NULL;		
%constant int CODEC_UNCOMPRESSED	= XN_CODEC_UNCOMPRESSED;		
%constant int CODEC_JPEG			= XN_CODEC_JPEG;		
%constant int CODEC_16Z				= XN_CODEC_16Z;		
%constant int CODEC_16Z_EMB_TABLES	= XN_CODEC_16Z_EMB_TABLES;		
%constant int CODEC_CODEC_8Z		= XN_CODEC_8Z;		

%constant int RECORD_MEDIUM_FILE	= XN_CODEC_NULL;		


%constant int IMG_MODE_DEFAULT	= DepthImgMode_Default;		
%constant int IMG_MODE_RGB_FADE	= DepthImgMode_RgbFade;		



%feature("director") ContextWrapper;
class ContextWrapper
{
public:

	ContextWrapper();

	int version();

	bool init(const char* xmlInitFile);
	bool init();

	int nodes();

	void addLicense(const char* vendor,const char* license);
	
	bool isInit();
	void close();
	
	virtual bool enableDepth();
	virtual bool enableDepth(int width,int height,int fps);

	virtual bool enableRGB();
	virtual bool enableRGB(int width,int height,int fps);
	
	virtual bool enableIR();
	virtual bool enableIR(int width,int height,int fps);

	virtual bool enableScene();
	virtual bool enableScene(int width,int height,int fps);

	virtual bool enableUser(int flags);
	virtual bool enableHands();
	virtual bool enableGesture();

	virtual void update();

	int depthWidth();
	int	depthHeight();
	int	depthImage(int* map);	
	void setDepthImageColor(int r,int g,int b);
	void setDepthImageColorMode(int mode);
	int depthImageColorMode();
	
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
	
	int		userWidth();
	int		userHeight();

	bool	getCoM(int user, XnPoint3D&  com);
	int		getNumberOfUsers();
	int		getUsers(std::vector<int>* userList);
	int		getUserPixels(int user,int* userSceneData);


	
	bool	isCalibratedSkeleton(int user);
	bool	isCalibratingSkeleton(int user);
	void	requestCalibrationSkeleton(int user, bool force);
	void	abortCalibrationSkeleton(int user);
	
	bool	saveCalibrationDataSkeleton(int user,int slot);
	bool	loadCalibrationDataSkeleton(int user,int slot);
	void	clearCalibrationDataSkeleton(int slot);
	bool	isCalibrationDataSkeleton(int slot);

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
				   
	void setMirror(bool flag);
	bool mirror();
		
	void convertRealWorldToProjective(XnVector3D* world,XnVector3D* proj);	
	void convertRealWorldToProjective(std::vector<XnVector3D>* worldArray,std::vector<XnVector3D>* projArray);

	void convertProjectiveToRealWorld(XnVector3D* proj,XnVector3D* world);	
	void convertProjectiveToRealWorld(std::vector<XnVector3D>* projArray,std::vector<XnVector3D>* worldArray);


	// ---------------------------------------------------------------------------
	// XnVSessionMananger
	XnVSessionManager* createSessionManager(const XnChar* strUseAsFocus, const XnChar* strUseAsQuickRefocus,
											 xn::HandsGenerator*	pTracker = NULL, 
											 xn::GestureGenerator*	pFocusGenerator = NULL,
											 xn::GestureGenerator*	pQuickRefocusGenerator = NULL);

	void update(XnVSessionManager* sessionManager);

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

	virtual void onStartSessionCb(const XnPoint3D& ptPosition);
	virtual void onEndSessionCb();
	virtual void onFocusSessionCb(const XnChar* strFocus, const XnPoint3D& ptPosition, XnFloat fProgress);
	
};

};

# -----------------------------------------------------------------------------

%{
#include <XnOpenNI.h>
#include <XnCppWrapper.h>
#include <XnVNite.h>
#include <XnVSessionGenerator.h> 
%}

# -----------------------------------------------------------------------------
# XnVHandPointContext

typedef struct XnVHandPointContext
{
    XnPoint3D ptPosition;
    XnUInt32 nID;
    XnUInt32 nUserID;
    XnFloat fTime;
    XnFloat fConfidence;
} XnVHandPointContext;


# -----------------------------------------------------------------------------
# XnVMessage

%feature("director") XnVMessage;
class  XnVMessage
{
public:
	XnVMessage(const XnChar* strType, void* pData);
	virtual ~XnVMessage();

	void* GetData();
	
	//virtual XnVMessage* operator[](const XnChar* strType);
	%extend{
		virtual XnVMessage* Get(const XnChar* strType)
		{
			return $self->operator[](strType);
		}
	}
	
	const XnChar* GetType() const;
	virtual XnVMessage* Clone() const = 0;
};


# -----------------------------------------------------------------------------
# XnVMessageListener

%{
typedef void (XN_CALLBACK_TYPE* MessageUpdateCB)(XnVMessage* pMessage, void* cxt);
%}

typedef void (MessageUpdateCB)(XnVMessage* pMessage, void* cxt);
typedef void (ActivateCB)(void* cxt);
typedef void (DeactivateCB)(void* cxt);


%feature("director") XnVMessageListener;
class XnVMessageListener
{
public:
/*
    typedef void (XN_CALLBACK_TYPE* MessageUpdateCB)(XnVMessage* pMessage, void* cxt);
    typedef void (XN_CALLBACK_TYPE* ActivateCB)(void* cxt);
    typedef void (XN_CALLBACK_TYPE* DeactivateCB)(void* cxt);
*/

    XnVMessageListener(const XnChar* strName = "XnVMessageListener");
    virtual ~XnVMessageListener();

    void BaseUpdate(XnVMessage* pMessage);
    virtual void Update(XnVMessage* pMessage) = 0;
    
    virtual void HandleCCMessages(XnVMessage* pMessage);

    virtual void Activate(XnBool bActive) {}

    const XnChar* GetListenerName() const;

    void Run(XnUInt32 nSessionMaxLength = ms_nSessionDefaultLength);
    XnStatus RunAsThread();
    void SetThreadId(XN_THREAD_ID hThread);
    void SetCurrentThread();

/*
    XnCallbackHandle RegisterUpdate(void* cxt, MessageUpdateCB CB);
    XnCallbackHandle RegisterActivate(void* cxt, ActivateCB CB);
    XnCallbackHandle RegisterDeactivate(void* cxt, DeactivateCB CB);

    void UnregisterUpdate(XnCallbackHandle hCB);
    void UnregisterActivate(XnCallbackHandle hCB);
    void UnregisterDeactivate(XnCallbackHandle hCB);
*/

    void SetThreadProtectionQueueMode(XnBool bMode);
    XnBool GetThreadProtectecionQueueMode() const;
    virtual void ClearQueue();
protected:
/*
    XN_DECLARE_THREAD_SAFE_QUEUE_DECL(XNV_NITE_API, XnVMessage*, XnVMessageQueue);
    XN_DECLARE_EVENT_1ARG(XnVMessageSpecificEvent, XnVMessageEvent, XnVMessage*, pMessage);

    XnBool IsInActivityThread() const;

    static XN_THREAD_PROC MessageListenerThread(XN_THREAD_PARAM param);
    void MainLoop();
*/

# -----------------------------------------------------------------------------
// addin native code
// methods for callbacks
	
%typemap(javaimports) XnVMessageListener%{
import java.lang.reflect.Method;	
%}		


%typemap(javacode) XnVMessageListener%{
	protected Method 		_messageUpdateMethod;
	protected Method 		_activateMethod;	
	protected Method 		_deactivateMethod;	
	
	
    public boolean RegisterUpdate(Object listner)
    {
		//_RegisterUpdate();
		
		_messageUpdateMethod = getMethodRef(listner,"onMessageUpdate",new Class[] { XnVMessage.class });
		return _messageUpdateMethod != null;
    }
    
    public boolean RegisterActivate(Object listner)
    {
		//_messagUpdateMethod = getMethodRef(listner,"onMessageUpdate",Class[] paraList);
		return _messageUpdateMethod != null;
    }
     
    public boolean RegisterDeactivate(Object listner)
    {
		//_messagUpdateMethod = getMethodRef(listner,"onMessageUpdate",Class[] paraList);
		return _messageUpdateMethod != null;
    }
 		
	protected Method getMethodRef(Object obj,String methodName,Class[] paraList)
	{
		Method	ret = null;
		try {
			ret = obj.getClass().getMethod(methodName,paraList);																									
		} 
		catch (Exception e) 
		{ // no such method, or an error.. which is fine, just ignore
		}
		return ret;
	}
%}

// callback extension

public:
/*
%extend{

	void __stdcall registerUpdateCB(XnVMessage* pMessage, void* cxt)
	{
	
	}

	void _RegisterUpdate()
	{
		$self->RegisterUpdate($self,XnVMessageListener_registerUpdateCB);
	}
}
*/
};


# -----------------------------------------------------------------------------
# XnVMessageGenerator

%feature("director") XnVMessageGenerator;
class XnVMessageGenerator
{
public:
    XnVMessageGenerator(const XnChar* strName = "XnVMessageGenerator");
    virtual ~XnVMessageGenerator();

    XnVHandle AddListener(XnVMessageListener* pListener);
    XnVMessageListener* RemoveListener(XnVHandle hListener);
    XnVMessageListener* RemoveListener(XnVMessageListener* pListener);

    void Generate(XnVMessage* pMessage);

    void ClearAllQueues();

    const XnChar* GetGeneratorName() const;
protected:
/*
    XN_DECLARE_DEFAULT_HASH_DECL(XNV_NITE_API, XnUInt32, XnVMessageListener*, XnVIntMessageListenerHash);

    void OpenNewSession(XnVMessageListener* pListener);
    void CloseOldSession(XnVMessageListener* pListener);
*/
};

# -----------------------------------------------------------------------------
# XnVSessionGenerator

%feature("director") XnVSessionGenerator;
class XnVSessionGenerator: public XnVMessageGenerator
{
public:
    XnVSessionGenerator(const XnChar* strName = "XnVSessionGenerator");
    virtual ~XnVSessionGenerator();

    XnVHandle RegisterSession(XnVSessionListener* pListener);
    XnVHandle RegisterSession(void* cxt, XnVSessionListener::OnSessionStartCB StartCB, XnVSessionListener::OnSessionEndCB EndCB, XnVSessionListener::OnFocusStartDetectedCB MidCB = NULL);
	
%typemap(javaimports) XnVSessionGenerator%{
//import java.lang.reflect.Method;	
%}	

%typemap(javacode) XnVSessionGenerator%{
	//public void  RegisterSession(PApplet parent)
	public void  RegisterSession(Object obj)
	{
		//find
		SimpleOpenNI.getMethodRef(obj,"onRecognizeGesture",new Class[] { int.class,int.class,int.class  });
	}
%}

	
    void UnregisterSession(XnVSessionListener* pSessionListener);
    void UnregisterSession(XnVHandle nHandle);

    XnBool IsInSession() const;

    virtual XnStatus LosePoint(XnUInt32 nID) = 0;
    virtual XnStatus LosePoints() = 0;

    virtual XnStatus EndSession() = 0;
    virtual XnStatus ForceSession(const XnPoint3D& ptFocus) = 0;
    virtual XnStatus TrackPoint(const XnPoint3D& pt) = 0;

    XnStatus GetFocusPoint(XnPoint3D& ptFocus) const;
    
protected:
    virtual void SessionStart(const XnPoint3D& ptPosition);
    virtual void SessionMidGesture(const XnChar* strFocus, const XnPoint3D& ptFocus, XnFloat fProgress);
    virtual void SessionStop();
};

# -----------------------------------------------------------------------------
# XnVPointControl

%feature("director") XnVPointControl;
class XnVPointControl : public XnVMessageListener
{
public:
/*
    typedef void (XN_CALLBACK_TYPE*PointCreateCB)(const XnVHandPointContext* pContext, void* cxt);
    typedef void (XN_CALLBACK_TYPE*PointUpdateCB)(const XnVHandPointContext* pContext, void* cxt);
    typedef void (XN_CALLBACK_TYPE*PointDestroyCB)(XnUInt32 nID, void* cxt);

    typedef void (XN_CALLBACK_TYPE*PrimaryPointCreateCB)(const XnVHandPointContext* pContext, const XnPoint3D& ptFocus, void* cxt);
    typedef void (XN_CALLBACK_TYPE*PrimaryPointUpdateCB)(const XnVHandPointContext* pContext, void* cxt);
    typedef void (XN_CALLBACK_TYPE*PrimaryPointReplaceCB)(XnUInt32 nOldId, const XnVHandPointContext* pContext, void* cxt);
    typedef void (XN_CALLBACK_TYPE*PrimaryPointDestroyCB)(XnUInt32 nID, void* cxt);

    typedef void (XN_CALLBACK_TYPE*NoPointsCB)(void* cxt);

    typedef void (XN_CALLBACK_TYPE*HandsUpdateCB)(const XnVMultipleHands& mh, void* cxt);
*/

    XnVPointControl(const XnChar* strName = "XnVPointControl");
    ~XnVPointControl();
    void Update(XnVMessage* pMessage);
    virtual void Update(const XnVMultipleHands& hands);

    virtual void OnPointCreate(const XnVHandPointContext* pContext) {}
    virtual void OnPointUpdate(const XnVHandPointContext* pContext) {}
    virtual void OnPointDestroy(XnUInt32 nID) {}

    virtual void OnPrimaryPointCreate(const XnVHandPointContext* pContext, const XnPoint3D& ptSessionStarter) {}
    virtual void OnPrimaryPointUpdate(const XnVHandPointContext* pContext) {}
    virtual void OnPrimaryPointReplace(XnUInt32 nOldId, const XnVHandPointContext* pContext) {}
    virtual void OnPrimaryPointDestroy(XnUInt32 nID) {}

    virtual void OnNoPoints() {}

/*
    XnCallbackHandle RegisterPointCreate(void* cxt, PointCreateCB CB);
    XnCallbackHandle RegisterPointUpdate(void* cxt, PointUpdateCB CB);
    XnCallbackHandle RegisterPointDestroy(void* cxt, PointDestroyCB CB);

    XnCallbackHandle RegisterPrimaryPointCreate(void* cxt, PrimaryPointCreateCB CB);
    XnCallbackHandle RegisterPrimaryPointUpdate(void* cxt, PrimaryPointUpdateCB CB);
    XnCallbackHandle RegisterPrimaryPointReplace(void* cxt, PrimaryPointReplaceCB CB);
    XnCallbackHandle RegisterPrimaryPointDestroy(void* cxt, PrimaryPointDestroyCB CB);
    XnCallbackHandle RegisterNoPoints(void* cxt, NoPointsCB CB);

    XnCallbackHandle RegisterHandsUpdate(void* cxt, HandsUpdateCB CB);

    void UnregisterPointCreate(XnCallbackHandle hCB);
    void UnregisterPointUpdate(XnCallbackHandle hCB);
    void UnregisterPointDestroy(XnCallbackHandle hCB);

    void UnregisterPrimaryPointCreate(XnCallbackHandle hCB);
    void UnregisterPrimaryPointUpdate(XnCallbackHandle hCB);
    void UnregisterPrimaryPointReplace(XnCallbackHandle hCB);
    void UnregisterPrimaryPointDestroy(XnCallbackHandle hCB);
    void UnregisterNoPoints(XnCallbackHandle hCB);

    void UnregisterHandsUpdate(XnCallbackHandle hCB);
*/

    XnUInt32 GetPrimaryID() const;
    
///////////////////////////////////////////////////////////////////////////////
// add java methods to register callbacks
%typemap(javacode) XnVPointControl%{

/*
    XnCallbackHandle RegisterPointCreate(void* cxt, PointCreateCB CB);
    XnCallbackHandle RegisterPointUpdate(void* cxt, PointUpdateCB CB);
    XnCallbackHandle RegisterPointDestroy(void* cxt, PointDestroyCB CB);

    XnCallbackHandle RegisterPrimaryPointCreate(void* cxt, PrimaryPointCreateCB CB);
    XnCallbackHandle RegisterPrimaryPointUpdate(void* cxt, PrimaryPointUpdateCB CB);
    XnCallbackHandle RegisterPrimaryPointReplace(void* cxt, PrimaryPointReplaceCB CB);
    XnCallbackHandle RegisterPrimaryPointDestroy(void* cxt, PrimaryPointDestroyCB CB);
    XnCallbackHandle RegisterNoPoints(void* cxt, NoPointsCB CB);

    XnCallbackHandle RegisterHandsUpdate(void* cxt, HandsUpdateCB CB);
*/
	
	public void RegisterPointCreate(Object objCb)
	{
		RegisterPointCreateSub(objCb,XnVPointControl.getCPtr(this));
	}

	public void RegisterPointDestroy(Object objCb)
	{
		RegisterPointDestroySub(objCb,XnVPointControl.getCPtr(this));
	}
	
	public void RegisterPointUpdate(Object objCb)
	{
		RegisterPointUpdateSub(objCb,XnVPointControl.getCPtr(this));
	}

	public native void RegisterPointCreateSub(Object objCb,long ptr);
	public native void RegisterPointDestroySub(Object objCb,long ptr);
	public native void RegisterPointUpdateSub(Object objCb,long ptr);
	

	public void RegisterPrimaryPointCreate(Object objCb)
	{
		RegisterPrimaryPointCreateSub(objCb,XnVPointControl.getCPtr(this));
	}

	public void RegisterPrimaryPointDestroy(Object objCb)
	{
		RegisterPrimaryPointDestroySub(objCb,XnVPointControl.getCPtr(this));
	}

	public native void RegisterPrimaryPointCreateSub(Object objCb,long ptr);
	public native void RegisterPrimaryPointDestroySub(Object objCb,long ptr);
	
	/* unregister
	-------------------------------------------------------------------------
	*/
%}
	

};





# -----------------------------------------------------------------------------
# XnVPushDetector

%feature("director") XnVPushDetector;
class XnVPushDetector : public XnVPointControl
{
public:
/*
    typedef void (XN_CALLBACK_TYPE *PushCB)(XnFloat fVelocity, XnFloat fAngle, void* UserCxt);
    typedef void (XN_CALLBACK_TYPE *StabilizedCB)(XnFloat fVelocity, void* UserCxt);
*/
    XnVPushDetector(const XnChar* strName = "XnVPushDetector");
    ~XnVPushDetector();

    void OnPrimaryPointCreate(const XnVHandPointContext* pContext, const XnPoint3D& ptFocus);
    void OnPrimaryPointUpdate(const XnVHandPointContext* pContext);

/*
    XnCallbackHandle RegisterPush(void* cxt, PushCB pCB);
    XnCallbackHandle RegisterStabilized(void* cxt, StabilizedCB pCB);

    void UnregisterPush(XnCallbackHandle handle);
    void UnregisterStabilized(XnCallbackHandle handle);
*/

    XnUInt32 GetPushDuration() const;

    void Reset();

    XnFloat GetPushImmediateMinimumVelocity() const;
    XnUInt32 GetPushImmediateDuration() const;
    XnUInt32 GetPushImmediateOffset() const;

    XnFloat GetPushPreviousMinimumVelocity() const;
    XnUInt32 GetPushPreviousDuration() const;
    XnUInt32 GetPushPreviousOffset() const;

    XnFloat GetPushMaximumAngleBetweenImmediateAndZ() const;
    XnFloat GetPushMinimumAngleBetweenImmediateAndPrevious() const;
    
    XnFloat GetStableMaximumVelocity() const;
    XnUInt32 GetStableDuration() const;

    void SetPushImmediateMinimumVelocity(XnFloat fVelocity);
    void SetPushImmediateDuration(XnUInt32 nDuration);
    void SetPushImmediateOffset(XnUInt32 nOffset);

    void SetPushPreviousMinimumVelocity(XnFloat fVelocity);
    void SetPushPreviousDuration(XnUInt32 nDuration);
    void SetPushPreviousOffset(XnUInt32 nOffset);

    void SetPushMaximumAngleBetweenImmediateAndZ(XnFloat fAngle);
    void SetPushMinimumAngleBetweenImmediateAndPrevious(XnFloat fAngle);

    void SetStableMaximumVelocity(XnFloat fVelocity);
    void SetStableDuration(XnUInt32 nDuration);
    
protected:
    XnBool IsPushDetected(const XnV3DVector& vImmediateVelocity, const XnV3DVector& vPreviousVelocity, XnFloat& fZAngle);
    XnBool IsStabilized(XnFloat fTime, XnFloat& fVelocity);
    void UpdateLines(XnFloat fTime);

    void AddPoint(const XnPoint3D& pt, XnFloat fTime);

    XnFloat AngleBetweenVectors(const XnV3DVector& v1, const XnV3DVector& v2);

}; 


# -----------------------------------------------------------------------------
# XnVSessionListener

%feature("director") XnVSessionListener;
class XnVSessionListener
{
public:
/*
    typedef void (XN_CALLBACK_TYPE *OnFocusStartDetectedCB)(const XnChar* strFocus, const XnPoint3D& ptPosition, XnFloat fProgress, void* UserCxt);
    typedef void (XN_CALLBACK_TYPE *OnSessionStartCB)(const XnPoint3D& ptPosition, void* UserCxt);
    typedef void (XN_CALLBACK_TYPE *OnSessionEndCB)(void* UserCxt);
*/
    virtual void OnSessionStart(const XnPoint3D& ptPosition) = 0;
    virtual void OnSessionEnd() = 0;
    virtual void OnFocusStartDetected(const XnChar* strFocus, const XnPoint3D& ptPosition, XnFloat fProgress) = 0;
};

# -----------------------------------------------------------------------------
# XnVContextControl

%feature("director") XnVContextControl;
class XnVContextControl : public XnVMessageListener
{
public:
    XnVContextControl(const XnChar* strName = "XnVContextControl");
    virtual ~XnVContextControl();

    void Update(XnVMessage* pMessage);
    virtual void Update(const xn::Context* pContext) = 0;
};

# -----------------------------------------------------------------------------
# XnVSessionManager

%feature("director") XnVSessionManager;
class XnVSessionManager :public XnVSessionGenerator // ,public XnVContextControl // java doesn't allow multiple inheritance !!!!!!! 
{
public:
    XnVSessionManager(const XnChar* strName = "XnVSessionManager");
    ~XnVSessionManager();

    XnStatus Initialize(xn::Context* pContext,
                        const XnChar* strUseAsFocus, const XnChar* strUseAsQuickRefocus,
                        xn::HandsGenerator* pTracker = NULL, xn::GestureGenerator* pFocusGenerator = NULL,
                        xn::GestureGenerator* pQuickRefocusGenerator = NULL);

    XnStatus Initialize(XnVGesture* pFocusGesture, XnVGesture* pQuickRefocusGesture, XnVPointTracker* pTracker);

    void Update(XnVMessage* pMessage);
    void Update(const xn::Context* pContext);
    void ProcessPoints(const XnVMultipleHands* pHands);

    void SetGesture(XnVGesture* pGesture);
    void SetGesture(xn::GestureGenerator gestureGenerator, const XnChar* strGestures);
    void SetQRGesture(XnVGesture* pGesture);
    void SetQRGesture(xn::GestureGenerator gestureGenerator, const XnChar* strGestures);
    void SetTracker(XnVPointTracker* pTracker);
    void SetTracker(xn::HandsGenerator generator);

    void SetQuickRefocusTimeout(XnUInt32 nMilliseconds);
    XnUInt32 GetQuickRefocusTimeout() const;

    XnStatus LosePoint(XnUInt32 nID);
    XnStatus LosePoints();

    XnStatus EndSession();
    XnStatus ForceSession(const XnPoint3D& ptFocus);
    XnStatus TrackPoint(const XnPoint3D& pt);

    void ClearQueue();

    XnStatus SetQuickRefocusArea(const XnBoundingBox3D& bbQuickRefocusArea);
    XnStatus SetQuickRefocusArea(XnFloat fLengthX, XnFloat fLengthY, XnFloat fLengthZ);

    void GetQuickRefocusArea(XnFloat& fLengthX, XnFloat& fLengthY, XnFloat& fLengthZ);
    void ForceQuickRefocus(XnBoundingBox3D* pbbForcedArea, XnUInt32 nForcedTimeout);
 

// add manually the XnVContextControl methods, due the multiple inheritance problem
/*
%extend{
	
	virtual void  Update(const xn::Context *pContext)
	{
		%self->Update(pContext);
	}
}
 */
 
/*
protected:
    void SessionStop();
    void StartQuickRefocus(XnBoundingBox3D* pbbROI, XnUInt32 nTimeout);

    XnStatus FindTracker(xn::Context* pContext, xn::HandsGenerator* pTracker, xn::HandsGenerator& tracker);
    XnStatus FindFocusGesture(xn::Context* pContext, xn::GestureGenerator* pFocusGenerator, const XnChar* strUseAsFocus, xn::GestureGenerator& focusGesture);

    static void XN_CALLBACK_TYPE Gesture_Recognized(const XnChar* strGesture, const XnPoint3D& ptIDPosition, const XnPoint3D& ptEndPosition, void* cxt);
    static void XN_CALLBACK_TYPE Gesture_StartRecognized(const XnChar* strGesture, const XnPoint3D& pos, XnFloat fProgress, void* cxt);
    void GestureRecognized(const XnChar* strGesture, const XnPoint3D& ptIDPosition, const XnPoint3D& ptEndPosition);
    void GestureStartRecognized(const XnChar* strGesture, const XnPoint3D& pos, XnFloat fProgress);

    XnUInt64 GetTime();


    enum
    {
        SMGR_ILLEGAL        = 0x0000,
        SMGR_NOT_IN_SESSION = 0x0001,
        SMGR_IN_SESSION     = 0x0002,
        SMGR_QUICK_REFOCUS  = SMGR_IN_SESSION | SMGR_NOT_IN_SESSION,
        SMGR_START_SESSION  = 0x0004,
    } m_eSessionState;

    inline XnBool IsInSession() const {return (m_eSessionState & SMGR_IN_SESSION) != 0;}
    inline XnBool IsNotInSession() const {return (m_eSessionState & SMGR_NOT_IN_SESSION) != 0;}
    inline XnBool IsQuickRefocus() const {return m_eSessionState == SMGR_QUICK_REFOCUS;}
*/
};


# -----------------------------------------------------------------------------
# XnVFlowRouter

%feature("director") XnVFlowRouter;
class XnVFlowRouter : public XnVMessageListener
{
public:
    XnVFlowRouter(const XnChar* strName = "XnVFlowRouter");
    virtual ~XnVFlowRouter();

    XnStatus SetActive(XnVMessageListener* pActive);
    XnVMessageListener* GetActive() const;

    void Update(XnVMessage* pMessage);

    void ClearQueue();
protected:
    virtual void CloseOldSession();
    virtual void OpenNewSession();
};

# -----------------------------------------------------------------------------
# XnVCircleDetector

%include <windows.i>


%constant int NO_CIRCLE_ILLEGAL			= XnVCircleDetector::NO_CIRCLE_ILLEGAL;		
%constant int NO_CIRCLE_NO_INPUT		= XnVCircleDetector::NO_CIRCLE_NO_INPUT;		
%constant int NO_CIRCLE_BAD_POINTS		= XnVCircleDetector::NO_CIRCLE_BAD_POINTS;		
%constant int NO_CIRCLE_MANUAL			= XnVCircleDetector::NO_CIRCLE_MANUAL;		


%feature("director") XnVCircleDetector;
class XnVCircleDetector :public XnVPointControl
{
public:
/*
    enum XnVNoCircleReason
    {
        NO_CIRCLE_ILLEGAL	= 0,
        NO_CIRCLE_NO_INPUT	= 1,
        NO_CIRCLE_BAD_POINTS= 2,
        NO_CIRCLE_MANUAL	= 3,
    };

    typedef void (XN_CALLBACK_TYPE *CircleCB)(XnFloat fTimes, XnBool bConfident, const XnVCircle* pCircle, void* pUserCxt);
    typedef void (XN_CALLBACK_TYPE *NoCircleCB)(XnFloat fLastValue, XnVNoCircleReason eReason, void* pUserCxt);
*/
    XnVCircleDetector(const XnChar* strName = "XnVCircleDetector");
    ~XnVCircleDetector();

    void OnPrimaryPointCreate(const XnVHandPointContext* pContext, const XnPoint3D& ptFocus);
    void OnPrimaryPointUpdate(const XnVHandPointContext* pContext);
    void OnPrimaryPointDestroy(XnUInt32 nID);

/*
    XnCallbackHandle RegisterCircle(void* cxt, CircleCB pCB);
    XnCallbackHandle RegisterNoCircle(void* cxt, NoCircleCB pCB);
*/
    void UnregisterCircle(XnCallbackHandle handle);
    void UnregisterNoCircle(XnCallbackHandle handle);

    void Reset();

    XnStatus SetMinimumPoints(XnUInt32 nMinimumPoints);
    XnStatus SetCloseToExistingRadius(XnFloat fCloseToExistingRadius);
    XnStatus SetCloseEnough(XnFloat fCloseEnough);
    XnStatus SetMinRadius(XnFloat fMinRadius);
    XnStatus SetMaxRadius(XnFloat fMaxRadius);
    XnStatus SetExistingWeight(XnFloat fExistingWeight);
    XnStatus SetMaxErrors(XnUInt32 nMaxErrors);

    XnStatus GetMinimumPoints(XnUInt32& nMinimumPoints) const;
    XnStatus GetCloseToExistingRadius(XnFloat& fCloseToExistingRadius) const;
    XnStatus GetCloseEnough(XnFloat& fCloseEnough) const;
    XnStatus GetMinRadius(XnFloat& fMinRadius) const;
    XnStatus GetMaxRadius(XnFloat& fMaxRadius) const;
    XnStatus GetExistingWeight(XnFloat& fExistingWeight) const;
    XnStatus GetMaxErrors(XnUInt32& nMaxErrors) const;

protected:
/*
    XN_DECLARE_EVENT_2ARG(XnVNoCircleSpecificEvent, XnVNoCircleEvent, XnFloat, fValue, XnVNoCircleReason, eReason);
    XN_DECLARE_EVENT_3ARG(XnVCircleSpecificEvent, XnVCircleEvent, XnFloat, fTimes, XnBool, bConfidence,  const XnVCircle*, pCircle);

    void AddPoint(const XnPoint3D& pt, XnFloat fTime);
*/ 

///////////////////////////////////////////////////////////////////////////////
// add java methods to register callbacks
%typemap(javacode) XnVCircleDetector%{

	
	public void RegisterCircle(Object objCb)
	{
		RegisterCircleSub(objCb,XnVCircleDetector.getCPtr(this));
	}

	public void RegisterNoCircle(Object objCb)
	{
		RegisterNoCircleSub(objCb,XnVCircleDetector.getCPtr(this));
	}

	public native void RegisterCircleSub(Object objCb,long ptr);
	public native void RegisterNoCircleSub(Object objCb,long ptr);
	
	/*
	public native void UnregisterCircleSub();
	*/
%}

};


# -----------------------------------------------------------------------------
# Context

namespace xn{

/*
class EnumerationErrors
{
public:
    EnumerationErrors();
    EnumerationErrors(XnEnumerationErrors* pErrors, XnBool bOwn = FALSE);
    
    ~EnumerationErrors();

    class Iterator
    {
    public:
        friend class EnumerationErrors;

        XnBool operator==(const Iterator& other) const;
        XnBool operator!=(const Iterator& other) const;
        Iterator& operator++();
        Iterator operator++(int);

        const XnProductionNodeDescription& Description();
        XnStatus Error();
		
		Iterator(XnEnumerationErrorsIterator it);
    };

    Iterator Begin() const;
    Iterator End() const;

    XnStatus ToString(XnChar* csBuffer, XnUInt32 nSize);
    void Free();
    XnEnumerationErrors* GetUnderlying();
};
*/

class Context
{
public:
    
    Context();
    Context(XnContext* pContext);
    Context(const Context& other);

    ~Context();

    XnContext* GetUnderlyingObject() const;

    XnStatus Init();

    /*
    XnStatus RunXmlScript(const XnChar* strScript, EnumerationErrors* pErrors = NULL);

    XnStatus RunXmlScriptFromFile(const XnChar* strFileName, EnumerationErrors* pErrors = NULL);
	
    XnStatus InitFromXmlFile(const XnChar* strFileName, EnumerationErrors* pErrors = NULL);
	*/

/*
    XnStatus OpenFileRecording(const XnChar* strFileName);

    XnStatus CreateMockNode(XnProductionNodeType type, const XnChar* strName, ProductionNode& node);

    XnStatus CreateMockNodeBasedOn(ProductionNode& originalNode, const XnChar* strName, ProductionNode& mockNode);

    XnStatus CreateCodec(XnCodecID codecID, ProductionNode& initializerNode, Codec& codec);

    void Shutdown();

    XnStatus AddLicense(const XnLicense& License);

    XnStatus EnumerateLicenses(XnLicense*& aLicenses, XnUInt32& nCount) const;

    static void FreeLicensesList(XnLicense aLicenses[]);

//    EnumerateProductionTrees(XnProductionNodeType Type, Query* pQuery, NodeInfoList& TreesList, EnumerationErrors* pErrors = NULL) const;
 
    XnStatus CreateAnyProductionTree(XnProductionNodeType type, Query* pQuery, ProductionNode& node, EnumerationErrors* pErrors = NULL);

    XnStatus CreateProductionTree(NodeInfo& Tree);

    XnStatus EnumerateExistingNodes(NodeInfoList& list) const;

    XnStatus EnumerateExistingNodes(NodeInfoList& list, XnProductionNodeType type) const;

    XnStatus FindExistingNode(XnProductionNodeType type, ProductionNode& node) const;

    XnStatus GetProductionNodeByName(const XnChar* strInstanceName, ProductionNode& node) const;

    XnStatus GetProductionNodeInfoByName(const XnChar* strInstanceName, NodeInfo& nodeInfo) const;
    
    XnStatus StartGeneratingAll();

    XnStatus StopGeneratingAll();

    XnStatus SetGlobalMirror(XnBool bMirror);

    XnBool GetGlobalMirror();

    XnStatus GetGlobalErrorState();

    XnStatus RegisterToErrorStateChange(XnErrorStateChangedHandler handler, void* pCookie, XnCallbackHandle& hCallback);

    void UnregisterFromErrorStateChange(XnCallbackHandle hCallback);

    XnStatus WaitAndUpdateAll();

    XnStatus WaitAnyUpdateAll();

    XnStatus WaitOneUpdateAll(ProductionNode& node);

    XnStatus WaitNoneUpdateAll();

    XnStatus AutoEnumerateOverSingleInput(NodeInfoList& List, XnProductionNodeDescription& description, const XnChar* strCreationInfo, XnProductionNodeType InputType, EnumerationErrors* pErrors, Query* pQuery = NULL) const;

    void SetHandle(XnContext* pContext);
    */
    
};


};


//%include "SimpleNite.i"

