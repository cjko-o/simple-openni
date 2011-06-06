# -----------------------------------------------------------------------------
# SimpleNite
# -----------------------------------------------------------------------------
# Processing Wrapper for the OpenNI/Kinect library
# prog:  Max Rheiner / Interaction Design / zhdh / http://iad.zhdk.ch/
# -----------------------------------------------------------------------------

# ----------------------------------------------------------------------------
# Virtual method test



/*
%feature("director") TestClass;
class TestClass
{
public:
	TestClass()
	{}

	virtual void test1(int i);
	virtual void testX(XnVector3D* p);
	static void test(TestClass* p);

protected:

};

*/

# -----------------------------------------------------------------------------
# NITE

%{
#include <XnOpenNI.h>
#include <XnCppWrapper.h>
#include <XnVNite.h>
#include <XnVSessionGenerator.h> 
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
        void SetSteadyMaxVelocity(XnFloat fVelocity);
        XnFloat GetSteadyMaxVelocity() const;
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
%typemap(javacode,noblock=1) XnVCircleDetector{

	NITE_JNI_JAVA_CALLBACK_DECL(XnVCircleDetector,Circle)
	NITE_JNI_JAVA_CALLBACK_DECL(XnVCircleDetector,NoCircle)
/*
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
}
};

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
