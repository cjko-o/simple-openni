# -----------------------------------------------------------------------------
# SimpleNite
# -----------------------------------------------------------------------------
# Processing Wrapper for the OpenNI/Kinect library
# prog:  Max Rheiner / Interaction Design / zhdk / http://iad.zhdk.ch/
# -----------------------------------------------------------------------------


# -----------------------------------------------------------------------------
# NITE

%{
#include <XnOpenNI.h>
#include <XnCppWrapper.h>
#include <XnVNite.h>
#include <XnVSessionGenerator.h> 
#include <XnVSlider3D.h>    // not definec in XnVNite.h ?
%}

# now docs for the nite part
# %disabledoc old version

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

/*
typedef enum XnVDirection
{
    DIRECTION_LEFT,
    DIRECTION_RIGHT,
    DIRECTION_UP,
    DIRECTION_DOWN,
    DIRECTION_BACKWARD,
    DIRECTION_FORWARD,
    DIRECTION_ILLEGAL
}XnVDirection;

typedef enum XnVAxis
{
    AXIS_X,
    AXIS_Y,
    AXIS_Z,
    AXIS_ILLEGAL
} XnVAxis;
*/

typedef	int	XnVDirection;
typedef	int	XnVAxis;

%constant int NITE_DIRECTION_LEFT		= DIRECTION_LEFT;
%constant int NITE_DIRECTION_RIGHT		= DIRECTION_RIGHT;
%constant int NITE_DIRECTION_UP			= DIRECTION_UP;
%constant int NITE_DIRECTION_DOWN		= DIRECTION_DOWN;
%constant int NITE_DIRECTION_BACKWARD	= DIRECTION_BACKWARD;
%constant int NITE_DIRECTION_FORWARD	= DIRECTION_FORWARD;
%constant int NITE_DIRECTION_ILLEGAL	= DIRECTION_ILLEGAL;


XnVAxis XnVDirectionAsAxis(XnVDirection eDir);
const XnChar* XnVDirectionAsString(XnVDirection eDir);

# -----------------------------------------------------------------------------
# NITE macros

%define NITE_JNI_JAVA_CALLBACK_DECL(Class,FuncName)
	public native void Register##FuncName##Sub(Object objCb,long ptr);
	
	public void Register##FuncName##(Object objCb)
	{
		Register##FuncName##Sub(objCb, Class##.getCPtr(this));
	}	
%enddef

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

%typemap(javacode,noblock=1) XnVPointControl{


	NITE_JNI_JAVA_CALLBACK_DECL(XnVPointControl,PointCreate)
	NITE_JNI_JAVA_CALLBACK_DECL(XnVPointControl,PointDestroy)
	NITE_JNI_JAVA_CALLBACK_DECL(XnVPointControl,PointUpdate)
	
	NITE_JNI_JAVA_CALLBACK_DECL(XnVPointControl,PrimaryPointCreate)
	NITE_JNI_JAVA_CALLBACK_DECL(XnVPointControl,PrimaryPointDestroy)

	
	/* unregister
	-------------------------------------------------------------------------
	*/
}
	

};

# -----------------------------------------------------------------------------
# XnVPointFilter

class XnVPointFilter :
    public XnVPointControl
//    public XnVMessageGenerator // java doesnt allow multiple inheritance
{
public:
    XnVPointFilter(const XnChar* strName = "XnVPointFilter");

    void Update(XnVMessage* pMessage);

    void ClearQueue();
    void GenerateReplaced(XnVMessage* pMessage, XnVMultipleHands& newHands);

    void OverridePrimary(XnUInt32 nNewPrimary);


// add the XnVMessageGenerator methods


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

///////////////////////////////////////////////////////////////////////////////
// add java methods to register callbacks
%typemap(javacode,noblock=1) XnVPushDetector{

    NITE_JNI_JAVA_CALLBACK_DECL(XnVPushDetector,Push)
    NITE_JNI_JAVA_CALLBACK_DECL(XnVPushDetector,Stabilized)
}
};

# -----------------------------------------------------------------------------
# XnVSteadyDetector

%feature("director") XnVSteadyDetector;
class XnVSteadyDetector : public XnVPointControl
{
public:
/*
    typedef void (XN_CALLBACK_TYPE *SteadyCB)(XnUInt32 nId, XnFloat fStdDev, void* pUserCxt);
    typedef void (XN_CALLBACK_TYPE *NotSteadyCB)(XnUInt32 nId, XnFloat fStdDev, void* pUserCxt);
*/

    XnVSteadyDetector(XnUInt32 nCooldownFrames,
                      XnUInt32 nDetectionDuration,
                      XnFloat fMaximumStdDevForSteady ,
                      const XnChar* strName = "XnVSteadyDetector");

/*
    XnVSteadyDetector(XnUInt32 nCooldownFrames = ms_nDefaultInitialCooldown,
                      XnUInt32 nDetectionDuration = ms_nDefaultDetectionDuration,
                      XnFloat fMaximumStdDevForSteady = ms_fDefaultMaximumStdDevForSteady,
                      const XnChar* strName = "XnVSteadyDetector");
    ~XnVSteadyDetector();
*/

/*
    XnCallbackHandle RegisterSteady(void* cxt, SteadyCB CB);
    void UnregisterSteady(XnCallbackHandle hCB);

    XnCallbackHandle RegisterNotSteady(void* cxt, NotSteadyCB CB);
    void UnregisterNotSteady(XnCallbackHandle hCB);
    void Reset();
*/

    XnUInt32 GetDetectionDuration() const;
    XnFloat GetMaximumStdDevForSteady() const;
    XnFloat GetMinimumStdDevForNotSteady() const;

    void SetDetectionDuration(XnUInt32 nDuration);
    void SetMaximumStdDevForSteady(XnFloat fStdDev);
    void SetMinimumStdDevForNotSteady(XnFloat fStdDev);

%immutable;
    static const XnUInt32 ms_nDefaultDetectionDuration;     // = 200 ms
    static const XnUInt32 ms_nDefaultInitialCooldown;       // = 0
   // static const XnFloat ms_fDefaultMaximumStdDevForSteady; // 0.01 m/s
   // static const XnFloat ms_fDefaultMinimumStdDevForNotSteady;  // 0.02 m/s
%mutable;

    void OnPointCreate(const XnVHandPointContext* cxt);
    void OnPointUpdate(const XnVHandPointContext* cxt);
protected:
    void Reset(XnUInt32 id);
    // called whenever we have a new point
    XnStatus DetectSteady(XnUInt32 nId, const XnPoint3D& pt, XnFloat fTime);

    // broadcasts the event to all listeners
    virtual void OnSteadyDetected(XnUInt32 nId, XnFloat fStdDev);
    virtual void OnNotSteadyDetected(XnUInt32 nId, XnFloat fStdDev);

///////////////////////////////////////////////////////////////////////////////
// add java methods to register callbacks
%typemap(javacode,noblock=1) XnVSteadyDetector{

    NITE_JNI_JAVA_CALLBACK_DECL(XnVSteadyDetector,Steady)
    NITE_JNI_JAVA_CALLBACK_DECL(XnVSteadyDetector,NotSteady)
}

}; // XnVSteadyDetector

# -----------------------------------------------------------------------------
# XnVSwipeDetector

%feature("director") XnVSwipeDetector;
class XnVSwipeDetector : public XnVPointControl
{
public:
/*
        typedef void (XN_CALLBACK_TYPE *SwipeCB)(XnFloat fVelocity, XnFloat fAngle, void* pUserCxt);
        typedef void (XN_CALLBACK_TYPE *GeneralSwipeCB)(XnVDirection eDir, XnFloat fVelocity, XnFloat fAngle, void* pUserCxt);
*/
        XnVSwipeDetector(XnBool bUseSteadyBeforeSwipe = true, const XnChar* strName = "XnVSwipeDetector");
        ~XnVSwipeDetector();
        void OnPrimaryPointCreate(const XnVHandPointContext* pContext, const XnPoint3D& ptFocus);
        void OnPrimaryPointUpdate(const XnVHandPointContext* pContext);
        void Reset();

/*
        XnCallbackHandle RegisterSwipeUp(void* cxt, SwipeCB pCB); // Add CB to list
        XnCallbackHandle RegisterSwipeDown(void* cxt, SwipeCB pCB); // Add CB to list
        XnCallbackHandle RegisterSwipeLeft(void* cxt, SwipeCB pCB); // Add CB to list
        XnCallbackHandle RegisterSwipeRight(void* cxt, SwipeCB pCB); // Add CB to list
        XnCallbackHandle RegisterSwipe(void* cxt, GeneralSwipeCB pCB);
*/
        void SetMotionSpeedThreshold(XnFloat fThreshold);
        XnFloat GetMotionSpeedThreshold() const;
        void SetMotionTime(XnUInt32 nThreshold);
        XnUInt32 GetMotionTime() const;
        void SetXAngleThreshold(XnFloat fThreshold);
        XnFloat GetXAngleThreshold() const;
        void SetYAngleThreshold(XnFloat fThreshold);
        XnFloat GetYAngleThreshold() const;

		/*	v1.3.0
        void SetSteadyMaxVelocity(XnFloat fVelocity);
        XnFloat GetSteadyMaxVelocity() const;
		*/
        void SetSteadyMaxStdDev(XnFloat fVelocity);
        XnFloat GetSteadyMaxStdDev() const;

        void SetSteadyDuration(XnUInt32 nDuration);
        XnUInt32 GetSteadyDuration() const;
        void SetUseSteady(XnBool bUse);
        XnBool GetUseSteady() const;
protected:
        void AddPoint(const XnPoint3D& pt, XnFloat fTime);


///////////////////////////////////////////////////////////////////////////////
// add java methods to register callbacks
%typemap(javacode,noblock=1) XnVSwipeDetector{

    NITE_JNI_JAVA_CALLBACK_DECL(XnVSwipeDetector,SwipeUp)
    NITE_JNI_JAVA_CALLBACK_DECL(XnVSwipeDetector,SwipeDown)
    NITE_JNI_JAVA_CALLBACK_DECL(XnVSwipeDetector,SwipeLeft)
    NITE_JNI_JAVA_CALLBACK_DECL(XnVSwipeDetector,SwipeRight)
    NITE_JNI_JAVA_CALLBACK_DECL(XnVSwipeDetector,Swipe)
}
}; 


# -----------------------------------------------------------------------------
# XnVWaveDetector 

%feature("director") XnVSwipeDetector;
class XnVWaveDetector  : public XnVPointControl
{
public:
/*
        typedef void (XN_CALLBACK_TYPE *WaveCB)(void* pUserCxt);
*/

  XnVWaveDetector(const XnChar* strName = "XnVWaveDetector");
  ~XnVWaveDetector();

  void OnPrimaryPointCreate(const XnVHandPointContext* pContext, const XnPoint3D& ptFocus);
  void OnPrimaryPointUpdate(const XnVHandPointContext* pContext);
  void OnPrimaryPointReplace(XnUInt32 nOldId, const XnVHandPointContext* pContext);
  void OnPrimaryPointDestroy(XnUInt32 nID);



/*
    XnCallbackHandle RegisterWave(void* cxt, WaveCB pCB);
    void UnregisterWave(XnCallbackHandle handle);
*/

    void Reset();

    void SetFlipCount(XnInt32 nFlipCount);
    void SetMinLength(XnInt32 nMinLength);
    void SetMaxDeviation(XnInt32 nMaxDeviation);

    XnInt32 GetFlipCount() const;
    XnInt32 GetMinLength() const;
    XnInt32 GetMaxDeviation() const;

protected:

///////////////////////////////////////////////////////////////////////////////
// add java methods to register callbacks
%typemap(javacode,noblock=1) XnVWaveDetector{
    NITE_JNI_JAVA_CALLBACK_DECL(XnVWaveDetector,Wave)
}
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
    class XnVSessionManager :public XnVSessionGenerator // ,public XnVContextControl // java doesnt allow multiple inheritance
{
public:
    XnVSessionManager(const XnChar* strName = "XnVSessionManager");
    ~XnVSessionManager();

    XnStatus Initialize(xn::Context* pContext,
                        const XnChar* strUseAsFocus, const XnChar* strUseAsQuickRefocus,
                        xn::HandsGenerator* pTracker = NULL, xn::GestureGenerator* pFocusGenerator = NULL,
                        xn::GestureGenerator* pQuickRefocusGenerator = NULL);


    void Update(XnVMessage* pMessage);
    void Update(const xn::Context* pContext);
    void ProcessPoints(XnVMultipleHands* pHands);


    /*  deprecated
    XnStatus Initialize(XnVGesture* pFocusGesture, XnVGesture* pQuickRefocusGesture, XnVPointTracker* pTracker);

    void SetGesture(XnVGesture* pGesture);
    void SetGesture(xn::GestureGenerator gestureGenerator, const XnChar* strGestures);
    void SetQRGesture(XnVGesture* pGesture);
    void SetQRGesture(xn::GestureGenerator gestureGenerator, const XnChar* strGestures);
    */

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
 

    XnUInt32 AddGesture(XnVGesture* pGesture);
    XnUInt32 AddGesture(xn::GestureGenerator& generator, const XnChar* strName);
    XnUInt32 AddGesture(xn::Context& context, const XnChar* strName);
    void RemoveGesture(XnUInt32 nId);

    XnUInt32 AddQuickRefocus(XnVGesture* pGesture);
    XnUInt32 AddQuickRefocus(xn::GestureGenerator& generator, const XnChar* strName);
    XnUInt32 AddQuickRefocus(xn::Context& context, const XnChar* strName);
    void RemoveQuickRefocus(XnUInt32 nId);

    void StartPrimaryStatic();
    void StopPrimaryStatic();
    void SetPrimaryStaticTimeout(XnFloat fTimeout);
    XnFloat GetPrimarySteadyTimeout() const;

    void SetPrimaryStaticBoundingBox(XnFloat fX, XnFloat fY, XnFloat fZ);
    void GetPrimaryStaticBoundingBox(XnFloat& fX, XnFloat& fY, XnFloat& fZ);

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
%typemap(javacode,noblock=1) XnVCircleDetector{

	NITE_JNI_JAVA_CALLBACK_DECL(XnVCircleDetector,Circle)
	NITE_JNI_JAVA_CALLBACK_DECL(XnVCircleDetector,NoCircle)
}
};

# -----------------------------------------------------------------------------
# XnVBorderScrollController1D

class XnVBorderScrollController1D;

class XnVSelectableSlider1D :  public XnVPointControl
{
public:
/*
    typedef void (XN_CALLBACK_TYPE *ItemHoverCB)(XnInt32 nItemIndex, void* pUserCxt);
    typedef void (XN_CALLBACK_TYPE *ItemSelectCB)(XnInt32 nItemIndex, XnVDirection nDirection, void* pUserCxt);
    typedef void (XN_CALLBACK_TYPE *ScrollCB)(XnFloat fScrollValue, void* pUserCxt);
    typedef void (XN_CALLBACK_TYPE *ValueChangeCB)(XnFloat fValue, void* pUserCxt);
    typedef void (XN_CALLBACK_TYPE *OffAxisMovementCB)(XnVDirection dir, void* pUserCxt);
*/

    XnVSelectableSlider1D(XnInt32 nCount, XnFloat fBorderWidth = 0, XnVAxis eAxis = AXIS_X,
                          XnBool bRecenter = TRUE,
                          XnFloat fHysteresisRatio = XnVMultiItemHysteresis1D::ms_fDefaultHysteresisRatio,
                          XnFloat fPrimarySliderSize = ms_fDefaultPrimarySliderSize, XnFloat fFirstValue = 0.5,
                          const XnChar* strName = "XnVSelectableSlider1D");
    ~XnVSelectableSlider1D();

    void OnPrimaryPointCreate(const XnVHandPointContext* pContext, const XnPoint3D& ptFocus);
    void OnPrimaryPointUpdate(const XnVHandPointContext* pContext);
    void OnPrimaryPointDestroy(XnUInt32 nID);

    static const XnFloat ms_fDefaultPrimarySliderSize;  // = 250

/*
    XnCallbackHandle RegisterItemHover(void* cxt, ItemHoverCB pCB);
    XnCallbackHandle RegisterItemSelect(void* cxt, ItemSelectCB pCB);
    XnCallbackHandle RegisterScroll(void* cxt, ScrollCB pCB);
    XnCallbackHandle RegisterValueChange(void* cxt, ValueChangeCB pCB);
    XnCallbackHandle RegisterOffAxisMovement(void* cxt, OffAxisMovementCB pCB);

    void UnregisterItemHover(XnCallbackHandle handle);
    void UnregisterItemSelect(XnCallbackHandle handle);
    void UnregisterScroll(XnCallbackHandle handle);
    void UnregisterValueChange(XnCallbackHandle handle);
    void UnregisterOffAxisMovement(XnCallbackHandle handle);
*/

    void ItemHover(XnInt32 nItemIndex);
    void ItemSelect(XnVDirection nDirection);
    void Scroll(XnFloat fScrollValue);

    void Reposition(const XnPoint3D& ptCenter);
    void GetCenter(XnPoint3D& ptCenter) const;

    XnUInt32 GetItemCount() const;
    void SetItemCount(XnUInt32 nItems);

    XnFloat GetBorderWidth() const;
    XnStatus SetBorderWidth(XnFloat fWidth);

    XnFloat GetSliderSize() const;
    void SetSliderSize(XnFloat fSliderSize);

    void SetValueChangeOnOffAxis(XnBool bReport);
    XnBool GetValueChangeOnOffAxis() const;

    void SetHysteresisRatio(XnFloat fRatio);
    XnFloat GetHysteresisRatio() const;
protected:
///////////////////////////////////////////////////////////////////////////////
// add java methods to register callbacks
%typemap(javacode,noblock=1) XnVSelectableSlider1D{

        NITE_JNI_JAVA_CALLBACK_DECL(XnVSelectableSlider1D,ItemHover)
        NITE_JNI_JAVA_CALLBACK_DECL(XnVSelectableSlider1D,ItemSelect)
        NITE_JNI_JAVA_CALLBACK_DECL(XnVSelectableSlider1D,Scroll)
        NITE_JNI_JAVA_CALLBACK_DECL(XnVSelectableSlider1D,ValueChange)
        NITE_JNI_JAVA_CALLBACK_DECL(XnVSelectableSlider1D,OffAxisMovement)
}

}; // XnVSelectableSlider1D

# -----------------------------------------------------------------------------
# XnVSelectableSlider2D

%feature("director") XnVSelectableSlider2D;
class XnVSelectableSlider2D : public XnVPointControl
{
public:

	XnVSelectableSlider2D(XnInt32 nXItems, XnInt32 nYItems,
        XnFloat fSliderSizeX = ms_fDefaultSliderSize, XnFloat fSliderSizeY = ms_fDefaultSliderSize,
        XnFloat fBorderWidth = 0, const XnChar* strName = "XnVSelectableSlider2D");
    virtual ~XnVSelectableSlider2D();

    void OnPrimaryPointCreate(const XnVHandPointContext* pContext, const XnPoint3D& ptFocus);
    void OnPrimaryPointUpdate(const XnVHandPointContext* pContext);
    void OnPrimaryPointDestroy(XnUInt32 nID);


///////////////////////////////////////////////////////////////////////////////
// add java methods to register callbacks
%typemap(javacode,noblock=1) XnVSelectableSlider2D{

	NITE_JNI_JAVA_CALLBACK_DECL(XnVSelectableSlider2D,ItemHover)
	NITE_JNI_JAVA_CALLBACK_DECL(XnVSelectableSlider2D,Scroll)
	NITE_JNI_JAVA_CALLBACK_DECL(XnVSelectableSlider2D,ValueChange)
	NITE_JNI_JAVA_CALLBACK_DECL(XnVSelectableSlider2D,ItemSelect)
	NITE_JNI_JAVA_CALLBACK_DECL(XnVSelectableSlider2D,OffAxisMovement)
}

/*

    typedef void (XN_CALLBACK_TYPE *ItemHoverCB)(XnInt32 nXIndex, XnInt32 nYIndex, void* pUserCxt);
    typedef void (XN_CALLBACK_TYPE *ItemSelectCB)(XnInt32 nXIndex, XnInt32 nYIndex, XnVDirection eDir, void* pUserCxt);
    typedef void (XN_CALLBACK_TYPE *OffAxisMovementCB)(XnVDirection eDir, void* pUserCxt);
    typedef void (XN_CALLBACK_TYPE *ValueChangeCB)(XnFloat fXValue, XnFloat fYValue, void* pUserCxt);
    typedef void (XN_CALLBACK_TYPE *ScrollCB)(XnFloat fXValue, XnFloat fYValue, void* pUserCxt);

    XnCallbackHandle RegisterItemHover(void* cxt, ItemHoverCB CB);
    XnCallbackHandle RegisterScroll(void* cxt, ScrollCB CB);
    XnCallbackHandle RegisterValueChange(void* cxt, ValueChangeCB CB);
    XnCallbackHandle RegisterItemSelect(void* cxt, ItemSelectCB CB);
    XnCallbackHandle RegisterOffAxisMovement(void* cxt, OffAxisMovementCB CB);

    void UnregisterItemHover(XnCallbackHandle hCB);
    void UnregisterScroll(XnCallbackHandle hCB);
    void UnregisterValueChange(XnCallbackHandle hCB);
    void UnregisterItemSelect(XnCallbackHandle hCB);
    void UnregisterOffAxisMovement(XnCallbackHandle hCB);
*/
    static const XnFloat ms_fDefaultSliderSize; // = 450

    void Reposition(const XnPoint3D& ptCenter);
    void GetCenter(XnPoint3D& ptCenter) const;

    void GetSliderSize(XnFloat& fSliderXSize, XnFloat& fSliderYSize) const;
    void SetSliderSize(XnFloat fSliderXSize, XnFloat fSliderYSize);

    XnUInt32 GetItemXCount() const;
    XnUInt32 GetItemYCount() const;
    void SetItemCount(XnUInt32 nItemXCount, XnUInt32 nItemYCount);
    void SetItemXCount(XnUInt32 nItemXCount);
    void SetItemYCount(XnUInt32 nItemYCount);

    void SetValueChangeOnOffAxis(XnBool bReport);
    XnBool GetValueChangeOnOffAxis() const;

    XnFloat GetBorderWidth() const;
    XnStatus SetBorderWidth(XnFloat fWidth);
    void SetHysteresisRatio(XnFloat fRatio);
    XnFloat GetHysteresisRatio() const;

protected:
/*
    XN_DECLARE_EVENT_3ARG(XnVItemSelectSpecificEvent, XnVItemSelectEvent, XnInt32, nItemX, XnInt32, nItemY, XnVDirection, eDir);

    void UpdateSlider(XnFloat fXValue, XnFloat fYValue);

    void PointDeleted(XnBool bReason);
    void PointMoved(const XnPoint3D& pt, XnFloat fTime);

    // Invoke events
    void ItemHover(XnInt32 nXIndex, XnInt32 nYIndex);
    void Scroll(XnFloat fXValue, XnFloat fYValue);
    void ValueChange(XnFloat fXValue, XnFloat fYValue);
    void ItemSelect(XnVDirection eDir);
    void OffAxisMovement(XnVDirection eDir);

    // Callbacks
    static void XN_CALLBACK_TYPE Slider_ValueChange(XnFloat fXValue, XnFloat fYValue, void* pContext);
    static void XN_CALLBACK_TYPE Slider_OffAxis(XnVDirection eDir, void* cxt);
    static void XN_CALLBACK_TYPE Hysteresis_ItemSelected(XnInt32 nXItem, XnInt32 nYItem, void* pContext);
    static void XN_CALLBACK_TYPE Scroller2D_Scrolled(XnFloat fXValue, XnFloat fYValue, void *pContext);

    static void XN_CALLBACK_TYPE SecondarySlider_OffAxisMovement(XnVDirection eDir, void* cxt);
    static void XN_CALLBACK_TYPE SecondarySlider_ValueChange(XnFloat fValue, void* cxt);
    static void XN_CALLBACK_TYPE OffAxisHysteresis_ItemSelected(XnInt32 nItem, void* cxt);
*/

};


# -----------------------------------------------------------------------------
# XnVMultipleHands
# add some defitions to use the inner classes of XnVMultipleHands

// Suppress SWIG warning
#pragma SWIG nowarn=SWIGWARN_PARSE_NESTED_CLASS

class XnVMultipleHands_ConstIterator
{
public:
    friend class XnVMultipleHands;

    ConstIterator(const ConstIterator& other);

    ConstIterator& operator++();
    ConstIterator operator++(int);

    XnBool operator==(const ConstIterator& other) const;
    XnBool operator!=(const ConstIterator& other) const;

    const XnVHandPointContext* operator*() const;

    XnBool IsNew() const;
    XnBool IsActive() const;
    XnBool IsValid() const;
protected:
    ConstIterator(const XnVMultipleHands* pHands);
    ConstIterator(const XnVMultipleHands* pHands, XnUInt32 nPosition);

    const XnVMultipleHands* m_pHands;
    XnUInt32 m_nPosition;
    XnBool m_bValid;
};

class XnVMultipleHands_Iterator : public XnVMultipleHands_ConstIterator
{
public:
    friend class XnVMultipleHands;

    Iterator(const Iterator& other);

    Iterator& operator++();
    Iterator operator++(int);

    XnVHandPointContext* operator*() const;
protected:
    Iterator(XnVMultipleHands* pHands);
    Iterator(XnVMultipleHands* pHands, XnUInt32 nPosition);
};

%{
// SWIG thinks that Inner is a global class, so we need to trick the C++
// compiler into understanding this so called global type.
typedef XnVMultipleHands::ConstIterator XnVMultipleHands_ConstIterator;
typedef XnVMultipleHands::Iterator      XnVMultipleHands_Iterator;
%}



%feature("director") XnVMultipleHands;
class XnVMultipleHands
{
public:
    XnVMultipleHands();
    XnVMultipleHands(const XnVMultipleHands& other);
    ~XnVMultipleHands();

    XnStatus Add(const XnVHandPointContext* pContext);
    XnStatus Remove(XnUInt32 nID);

    XnVHandPointContext* GetContext(XnUInt32 nID);
    const XnVHandPointContext* GetContext(XnUInt32 nID) const;
    XnVHandPointContext* GetPrimaryContext();
    const XnVHandPointContext* GetPrimaryContext() const;

    void MarkNew(XnUInt32 nID);
    void MarkOld(XnUInt32 nID);
    void MarkActive(XnUInt32 nID);

    void RemoveNew(XnUInt32 nID);
    void RemoveOld(XnUInt32 nID);
    void RemoveActive(XnUInt32 nID);

    XnUInt32 NewEntries() const;
    XnUInt32 OldEntries() const;
    XnUInt32 ActiveEntries() const;

    void Clone(XnVMultipleHands& other) const;

    void Clear();
    void ClearLists();
    void ClearNewList();
    void ClearOldList();

/*
    class ConstIterator
    {
    public:
        friend class XnVMultipleHands;

        ConstIterator(const ConstIterator& other);

        ConstIterator& operator++();
        ConstIterator operator++(int);

        XnBool operator==(const ConstIterator& other) const;
        XnBool operator!=(const ConstIterator& other) const;

        const XnVHandPointContext* operator*() const;

        XnBool IsNew() const;
        XnBool IsActive() const;
        XnBool IsValid() const;
    protected:
        ConstIterator(const XnVMultipleHands* pHands);
        ConstIterator(const XnVMultipleHands* pHands, XnUInt32 nPosition);

        const XnVMultipleHands* m_pHands;
        XnUInt32 m_nPosition;
        XnBool m_bValid;
    };

    class Iterator : public ConstIterator
    {
    public:
        friend class XnVMultipleHands;

        Iterator(const Iterator& other);

        Iterator& operator++();
        Iterator operator++(int);

        XnVHandPointContext* operator*() const;
    protected:
        Iterator(XnVMultipleHands* pHands);
        Iterator(XnVMultipleHands* pHands, XnUInt32 nPosition);
    };
*/

    XnVMultipleHands_Iterator begin();
    XnVMultipleHands_ConstIterator begin() const;
    XnVMultipleHands_Iterator end();
    XnVMultipleHands_ConstIterator end() const;

    XnVMultipleHands_Iterator Find(XnUInt32 nID);
    XnVMultipleHands_ConstIterator Find(XnUInt32 nID) const;
    XnBool IsNew(XnUInt32 nID) const;
    XnBool IsOld(XnUInt32 nID) const;
    XnBool IsActive(XnUInt32 nID) const;

    /*
    XnVIntList::Iterator beginOld();
    XnVIntList::ConstIterator beginOld() const;
    XnVIntList::Iterator endOld();
    XnVIntList::ConstIterator endOld() const;
    */

    void ReassignPrimary(XnUInt32 nHint = 0);

    void SetFocusPoint(const XnPoint3D& ptFocusPoint);
    const XnPoint3D& GetFocusPoint() const;

};


# -----------------------------------------------------------------------------
# XnVSlider1D


%feature("director") XnVSlider1D;
class XnVSlider1D
{
public:
/*
    typedef void (XN_CALLBACK_TYPE* ValueChangeCB)(XnFloat fValue, void* cxt);
    typedef void (XN_CALLBACK_TYPE* OffAxisMovementCB)(XnVDirection eDir, void* cxt);
*/
    XnVSlider1D(XnVAxis eAxis, const XnPoint3D& ptInitialPosition, XnPoint3D ptMinPoint, XnPoint3D ptMaxPoint,
                XnFloat fMinOutput, XnFloat fMaxOutput,
                XnFloat fOffAxisDetectionAngle = ms_fOffAxisDefaultDetectionAngle,
                XnFloat fOffAxisDetectionMinimumVelocity = ms_fDefaultMinimumOffAxisVelocity);
    XnVSlider1D(XnVAxis eAxis, const XnPoint3D& ptInitialPosition, XnFloat fSliderLength, XnFloat fInitialValue,
                XnFloat fMinOutput, XnFloat fMaxOutput,
                XnFloat fOffAxisDetectionAngle = ms_fOffAxisDefaultDetectionAngle,
                XnFloat fOffAxisDetectionMinimumVelocity = ms_fDefaultMinimumOffAxisVelocity);

    ~XnVSlider1D();

    void Reinitialize(XnVAxis eAxis, const XnPoint3D& ptInitialPoint, const XnPoint3D& ptMinPoint,
                      const XnPoint3D& ptMaxPoint, XnFloat fMinOutput, XnFloat fMaxOutput);
    void Reinitialize(XnVAxis eAxis, const XnPoint3D& ptInitialPoint, XnFloat fSliderLength,
                      XnFloat fInitialValue, XnFloat fMinOutput, XnFloat fMaxOutput);

    XnFloat ValueAtPosition(const XnPoint3D& pt);

    XnStatus Update(const XnPoint3D& pt, XnFloat fTime, XnBool bCheckOffAxis = true);

    void LostPoint();

/*
    XnCallbackHandle RegisterValueChange(void* cxt, ValueChangeCB CB);
    XnCallbackHandle RegisterOffAxisMovement(void* cxt, OffAxisMovementCB CB);

    void UnregisterValueChange(XnCallbackHandle hCB);
    void UnregisterOffAxisMovement(XnCallbackHandle hCB);
*/

    XnFloat GetValue() const;
    const XnPoint3D& GetPosition() const;
    XnBool IsValid() const;

    XnVAxis GetAxis() const;

    XnFloat  GetOffAxisDetectionVelocity() const;
    XnFloat  GetOffAxisDetectionAngle() const;
    XnUInt32 GetOffAxisDetectionTime() const;

    void SetOffAxisDetectionVelocity(XnFloat fVelocity);
    void SetOffAxisDetectionAngle(XnFloat fAngle);
    void SetOffAxisDetectionTime(XnUInt32 nTime);

///////////////////////////////////////////////////////////////////////////////
// add java methods to register callbacks
%typemap(javacode,noblock=1) XnVSlider1D{

        NITE_JNI_JAVA_CALLBACK_DECL(XnVSlider1D,ValueChange)
        NITE_JNI_JAVA_CALLBACK_DECL(XnVSlider1D,OffAxisMovement)
}

};


# -----------------------------------------------------------------------------
# XnVSlider2D

%feature("director") XnVSlider2D;
class XnVSlider2D
{
public:
/*
    typedef void (XN_CALLBACK_TYPE *ValueChangeCB)(XnFloat fXValue, XnFloat fYValue, void* pUserCxt);
    typedef void (XN_CALLBACK_TYPE *OffAxisMovementCB)(XnVDirection eDir, void* pUserCxt);
*/

    XnVSlider2D(const XnPoint3D& ptMin ,const XnPoint3D& ptMax);
    XnVSlider2D(const XnPoint3D& ptInitialPosition, XnFloat fSliderXLength, XnFloat fSliderYLength,
                XnFloat fInitialXValue, XnFloat fInitialYValue);

    ~XnVSlider2D();
    XnStatus Update(const XnPoint3D& pt, XnFloat fTime, XnBool bCheckOffAxis = true);

/*
    XnCallbackHandle RegisterValueChange(void* cxt, ValueChangeCB CB); // Add CB to list
    XnCallbackHandle RegisterOffAxisMovement(void* cxt, OffAxisMovementCB CB);
    void UnregisterValueChange(XnCallbackHandle hCB);
    void UnregisterOffAxisMovement(XnCallbackHandle hCB);
*/

    XnPoint3D GetPosition() const {return m_ptCurrentPosition;}

    XnFloat  GetOffAxisDetectionVelocity() const;
    XnFloat  GetOffAxisDetectionAngle() const;
    XnUInt32 GetOffAxisDetectionTime() const;

    void SetOffAxisDetectionVelocity(XnFloat fVelocity);
    void SetOffAxisDetectionAngle(XnFloat fAngle);
    void SetOffAxisDetectionTime(XnUInt32 nTime);

///////////////////////////////////////////////////////////////////////////////
// add java methods to register callbacks
%typemap(javacode,noblock=1) XnVSlider2D{

        NITE_JNI_JAVA_CALLBACK_DECL(XnVSlider2D,ValueChange)
        NITE_JNI_JAVA_CALLBACK_DECL(XnVSlider2D,OffAxisMovement)
}

};


# -----------------------------------------------------------------------------
# XnVSlider3D

%feature("director") XnVSlider3D;
class XnVSlider3D
{
public:
/*
    typedef void (XN_CALLBACK_TYPE *ValueChangeCB)(XnFloat fXValue, XnFloat fYValue, XnFloat fZValue, void* pUserCxt);
*/
    XnVSlider3D(const XnPoint3D& ptMin ,const XnPoint3D& ptMax);

    ~XnVSlider3D();

    XnStatus Update(const XnPoint3D& pt);

/*
    XnCallbackHandle RegisterValueChange(void* cxt, ValueChangeCB CB); // Add CB to list
    void UnregisterValueChange(XnCallbackHandle hCB);
*/

///////////////////////////////////////////////////////////////////////////////
// add java methods to register callbacks
%typemap(javacode,noblock=1) XnVSlider3D{

        NITE_JNI_JAVA_CALLBACK_DECL(XnVSlider3D,ValueChange)
}

};
