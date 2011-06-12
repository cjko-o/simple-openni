# -----------------------------------------------------------------------------
# SimpleOpenNI 
# -----------------------------------------------------------------------------
# Processing Wrapper for the OpenNI/Kinect library
# prog:  Max Rheiner / Interaction Design / zhdk / http://iad.zhdk.ch/
# -----------------------------------------------------------------------------

# ----------------------------------------------------------------------------
# Xn


JAVA_ARRAYSOFCLASSES(XnVector3D)
JAVA_ARRAYSOFCLASSES(XnPoint3D)



typedef	bool		XnBool;
typedef	char		XnChar;
typedef	unsigned char	XnUInt8;
typedef	unsigned short	XnUInt16;
typedef	unsigned int	XnUInt32;
typedef	int		XnInt32;
typedef	float		XnFloat;
typedef XnUInt32	XnVHandle;
typedef XnUInt32	XnStatus;
//typedef uint64_t	unsigned long;

typedef XnUInt32        XnUserID;
typedef XnUInt16        XnDepthPixel;



typedef struct XnVector3D
{
	XnFloat X;
	XnFloat Y;
	XnFloat Z;
} XnVector3D;

typedef struct XnPoint3D
{
	XnFloat X;
	XnFloat Y;
	XnFloat Z;
} XnPoint3D;
// typedef XnVector3D XnPoint3D;

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

typedef struct XnBoundingBox3D
{
	XnPoint3D LeftBottomNear;
	XnPoint3D RightTopFar;
} XnBoundingBox3D;



%array_class(XnVector3D, XnVector3DArray);
%array_class(XnPoint3D, XnPoint3DArray);

# -----------------------------------------------------------------------------
# Constants

%constant int XN_STATUS_OK = XN_STATUS_OK;


%{
#include "XnCppWrapper.h"
%}

# -----------------------------------------------------------------------------
# Context

namespace xn{


class Query
{
public:

    Query();
    ~Query();

    XnNodeQuery* GetUnderlyingObject() const;

    XnStatus SetVendor(const XnChar* strVendor);
    XnStatus SetName(const XnChar* strName);
    XnStatus SetMinVersion(const XnVersion& minVersion);
    XnStatus SetMaxVersion(const XnVersion& maxVersion);

    XnStatus AddSupportedCapability(const XnChar* strNeededCapability);
    XnStatus AddSupportedMapOutputMode(const XnMapOutputMode& MapOutputMode);

    XnStatus SetSupportedMinUserPositions(const XnUInt32 nCount);
    XnStatus SetExistingNodeOnly(XnBool bExistingNode);

    XnStatus AddNeededNode(const XnChar* strInstanceName);
    XnStatus SetCreationInfo(const XnChar* strCreationInfo);
};



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

# -----------------------------------------------------------------------------
# OutputMetaData

%feature("director") OutputMetaData;
class OutputMetaData
{
public:

    OutputMetaData(const XnUInt8** ppData);
    virtual ~OutputMetaData();

    XnUInt64 Timestamp() const;
    XnUInt64& Timestamp();

    XnUInt32 FrameID() const;
    XnUInt32& FrameID();

    XnUInt32 DataSize() const;
    XnUInt32& DataSize();

    XnBool IsDataNew() const;
    XnBool& IsDataNew();

    const XnOutputMetaData* GetUnderlying() const;
    XnOutputMetaData* GetUnderlying();

/*
    const XnUInt8* Data() const;
*/
    const XnUInt8*& Data();
    XnUInt8* WritableData();
    XnStatus AllocateData(XnUInt32 nBytes);

    void Free();

    XnStatus MakeDataWritable();

};

# -----------------------------------------------------------------------------
# MapMetaData

%feature("director") MapMetaData;
class MapMetaData : public OutputMetaData
{
public:
    MapMetaData(XnPixelFormat format, const XnUInt8** ppData);

    XnUInt32 XRes() const;
    XnUInt32& XRes();

    XnUInt32 YRes() const ;
    XnUInt32& YRes();

    XnUInt32 XOffset() const;
    XnUInt32& XOffset();

    XnUInt32 YOffset() const;
    XnUInt32& YOffset();

    XnUInt32 FullXRes() const;
    XnUInt32& FullXRes();

    XnUInt32 FullYRes() const;
    XnUInt32& FullYRes();

    XnUInt32 FPS() const;
    XnUInt32& FPS();

    XnPixelFormat PixelFormat() const ;

/*
    const XnMapMetaData* GetUnderlying() const ;
    XnMapMetaData* GetUnderlying();
*/

    XnUInt32 BytesPerPixel() const;

    XnStatus AllocateData(XnUInt32 nXRes, XnUInt32 nYRes);
    XnStatus ReAdjust(XnUInt32 nXRes, XnUInt32 nYRes, const XnUInt8* pExternalBuffer);
};

# -----------------------------------------------------------------------------
# DepthMetaData

%rename(ThisData)               DepthMetaData::Data();
%rename(ThisDepthMap)           DepthMetaData::DepthMap();
%rename(ThisWritableDepthMap)   DepthMetaData::WritableData();
%rename(ThisGetUnderlying)      DepthMetaData::GetUnderlying();

%rename(Get)    DepthMetaData::operator[](XnUInt32 nIndex);
%rename(GetAt)  DepthMetaData::operator()(XnUInt32 x, XnUInt32 y);

class DepthMetaData : public MapMetaData
{
public:
    DepthMetaData();
    void InitFrom(const DepthMetaData& other);
    XnStatus InitFrom(const DepthMetaData& other, XnUInt32 nXRes, XnUInt32 nYRes, const XnDepthPixel* pExternalBuffer);

    CopyFrom(const DepthMetaData& other);

    XnStatus ReAdjust(XnUInt32 nXRes, XnUInt32 nYRes, const XnDepthPixel* pExternalBuffer = NULL);

    XnDepthPixel ZRes() const;
    XnDepthPixel& ZRes();

/*
    const XnDepthPixel* Data() const ;
*/
    const XnDepthPixel*& Data();
    XnDepthPixel* WritableData();

    const xn::DepthMap& DepthMap() const;
    xn::DepthMap& WritableDepthMap() ;

    const XnDepthPixel& operator[](XnUInt32 nIndex) const;
    const XnDepthPixel& operator()(XnUInt32 x, XnUInt32 y) const;

/*
    const XnDepthMetaData* GetUnderlying() const;
*/
    XnDepthMetaData* GetUnderlying();
};


# -----------------------------------------------------------------------------
# ImageMetaData

%rename(ThisGetUnderlying)      ImageMetaData::GetUnderlying();

class ImageMetaData : public MapMetaData
{
public:
        ImageMetaData();

        void InitFrom(const ImageMetaData& other);

        XnStatus InitFrom(const ImageMetaData& other, XnUInt32 nXRes, XnUInt32 nYRes, XnPixelFormat format, const XnUInt8* pExternalBuffer);

        XnStatus AllocateData(XnUInt32 nXRes, XnUInt32 nYRes, XnPixelFormat format);
        XnStatus CopyFrom(const ImageMetaData& other);

        XnStatus ReAdjust(XnUInt32 nXRes, XnUInt32 nYRes, XnPixelFormat format, const XnUInt8* pExternalBuffer = NULL);

        XnPixelFormat PixelFormat() const;
        XnPixelFormat& PixelFormat();

        XnUInt8* WritableData();

        const XnRGB24Pixel* RGB24Data() const;
        const XnRGB24Pixel*& RGB24Data() ;
        XnRGB24Pixel* WritableRGB24Data();

        const XnYUV422DoublePixel* YUV422Data() const;
        const XnYUV422DoublePixel*& YUV422Data();
        XnYUV422DoublePixel* WritableYUV422Data();

        const XnGrayscale8Pixel* Grayscale8Data() const;
        const XnGrayscale8Pixel*& Grayscale8Data();
        XnGrayscale8Pixel* WritableGrayscale8Data();

        const XnGrayscale16Pixel* Grayscale16Data() const;
        const XnGrayscale16Pixel*& Grayscale16Data();
        XnGrayscale16Pixel* WritableGrayscale16Data();

        const xn::ImageMap& ImageMap() const;
        xn::ImageMap& WritableImageMap();

        const xn::RGB24Map& RGB24Map() const;
        xn::RGB24Map& WritableRGB24Map();

        const xn::Grayscale8Map& Grayscale8Map() const;
        xn::Grayscale8Map& WritableGrayscale8Map();

        const xn::Grayscale16Map& Grayscale16Map() const;
        xn::Grayscale16Map& WritableGrayscale16Map();
/*
        const XnImageMetaData* GetUnderlying() const;
*/
        XnImageMetaData* GetUnderlying();
};

# -----------------------------------------------------------------------------
# SceneMetaData

%rename(ThisData)               SceneMetaData::Data();
%rename(ThisWritableDepthMap)   SceneMetaData::WritableData();
%rename(ThisGetUnderlying)      SceneMetaData::GetUnderlying();

%rename(Get)                    SceneMetaData::operator[](XnUInt32 nIndex);
%rename(GetAt)                  SceneMetaData::operator()(XnUInt32 x, XnUInt32 y);

class SceneMetaData : public MapMetaData
{
public:
        SceneMetaData();

        void InitFrom(const SceneMetaData& other);
        XnStatus InitFrom(const SceneMetaData& other, XnUInt32 nXRes, XnUInt32 nYRes, const XnLabel* pExternalBuffer);
        XnStatus CopyFrom(const SceneMetaData& other);

        XnStatus ReAdjust(XnUInt32 nXRes, XnUInt32 nYRes, const XnLabel* pExternalBuffer = NULL);
/*
        const XnLabel* Data() const;
*/
        const XnLabel*& Data();
        XnLabel* WritableData();

        const xn::LabelMap& LabelMap() const;
        xn::LabelMap& WritableLabelMap();

        const XnLabel& operator[](XnUInt32 nIndex) const;
        const XnLabel& operator()(XnUInt32 x, XnUInt32 y) const;

/*
        const XnSceneMetaData* GetUnderlying() const;
*/
        XnSceneMetaData* GetUnderlying();
};

# -----------------------------------------------------------------------------
# IRMetaData

%rename(ThisData)               IRMetaData::Data();
%rename(ThisWritableDepthMap)   IRMetaData::WritableData();
%rename(ThisGetUnderlying)      IRMetaData::GetUnderlying();

class IRMetaData : public MapMetaData
{
public:
        IRMetaData();

        void InitFrom(const IRMetaData& other);
        XnStatus InitFrom(const IRMetaData& other, XnUInt32 nXRes, XnUInt32 nYRes, const XnIRPixel* pExternalBuffer);
        XnStatus CopyFrom(const IRMetaData& other);

        XnStatus ReAdjust(XnUInt32 nXRes, XnUInt32 nYRes, const XnIRPixel* pExternalBuffer = NULL);

/*
        const XnIRPixel* Data() const;
*/
        const XnIRPixel*& Data();
        XnIRPixel* WritableData();

        const xn::IRMap& IRMap() const;
        xn::IRMap& WritableIRMap();

/*
        const XnIRMetaData* GetUnderlying() const;
*/
        XnIRMetaData* GetUnderlying();
};


# -----------------------------------------------------------------------------
# Capability

class Capability
{
public:

    Capability(XnNodeHandle hNode);
    void SetUnderlyingHandle(XnNodeHandle hNode);

};

# -----------------------------------------------------------------------------
# SkeletonCapability

class SkeletonCapability : public Capability
{
public:

    SkeletonCapability(XnNodeHandle hNode);

    XnBool IsJointAvailable(XnSkeletonJoint eJoint) const;
    XnBool IsProfileAvailable(XnSkeletonProfile eProfile) const;
    XnStatus SetSkeletonProfile(XnSkeletonProfile eProfile);
    XnStatus SetJointActive(XnSkeletonJoint eJoint, XnBool bState);
    XnBool IsJointActive(XnSkeletonJoint eJoint) const;

/*
    XnStatus RegisterToJointConfigurationChange(StateChangedHandler handler, void* pCookie, XnCallbackHandle& hCallback);
    void UnregisterFromJointConfigurationChange(XnCallbackHandle hCallback);
*/

    XnStatus EnumerateActiveJoints(XnSkeletonJoint* pJoints, XnUInt16& nJoints) const;

    XnStatus GetSkeletonJoint(XnUserID user, XnSkeletonJoint eJoint, XnSkeletonJointTransformation& Joint) const;
    XnStatus GetSkeletonJointPosition(XnUserID user, XnSkeletonJoint eJoint, XnSkeletonJointPosition& Joint) const;
    XnStatus GetSkeletonJointOrientation(XnUserID user, XnSkeletonJoint eJoint, XnSkeletonJointOrientation& Joint) const;

    XnBool IsTracking(XnUserID user) const;

    XnBool IsCalibrated(XnUserID user) const;
    XnBool IsCalibrating(XnUserID user) const;
    XnStatus RequestCalibration(XnUserID user, XnBool bForce);
    XnStatus AbortCalibration(XnUserID user);
    XnStatus SaveCalibrationDataToFile(XnUserID user, const XnChar* strFileName);
    XnStatus LoadCalibrationDataFromFile(XnUserID user, const XnChar* strFileName);
    XnStatus SaveCalibrationData(XnUserID user, XnUInt32 nSlot);
    XnStatus LoadCalibrationData(XnUserID user, XnUInt32 nSlot);
    XnStatus ClearCalibrationData(XnUInt32 nSlot);
    XnBool IsCalibrationData(XnUInt32 nSlot) const;

    XnStatus StartTracking(XnUserID user);
    XnStatus StopTracking(XnUserID user);

    XnStatus Reset(XnUserID user);

    XnBool NeedPoseForCalibration() const;
    XnStatus GetCalibrationPose(XnChar* strPose) const;
    XnStatus SetSmoothing(XnFloat fSmoothingFactor);

/*
    typedef void (XN_CALLBACK_TYPE* CalibrationStart)(SkeletonCapability& skeleton, XnUserID user, void* pCookie);
    typedef void (XN_CALLBACK_TYPE* CalibrationEnd)(SkeletonCapability& skeleton, XnUserID user, XnBool bSuccess, void* pCookie);

    XnStatus RegisterCalibrationCallbacks(CalibrationStart CalibrationStartCB, CalibrationEnd CalibrationEndCB, void* pCookie, XnCallbackHandle& hCallback);
    void UnregisterCalibrationCallbacks(XnCallbackHandle hCallback);
*/
};

# -----------------------------------------------------------------------------
# PoseDetectionCapability

class PoseDetectionCapability : public Capability
{
public:
    PoseDetectionCapability(XnNodeHandle hNode) : Capability(hNode) {}

    XnUInt32 GetNumberOfPoses() const;

    XnStatus GetAvailablePoses(XnChar** pstrPoses, XnUInt32& nPoses) const;
    XnStatus GetAllAvailablePoses(XnChar** pstrPoses, XnUInt32 nNameLength, XnUInt32& nPoses) const;

    XnStatus StartPoseDetection(const XnChar* strPose, XnUserID user);

    XnStatus StopPoseDetection(XnUserID user);

/*
    typedef void (XN_CALLBACK_TYPE* PoseDetection)(PoseDetectionCapability& pose, const XnChar* strPose, XnUserID user, void* pCookie);
    XnStatus RegisterToPoseCallbacks(PoseDetection PoseStartCB, PoseDetection PoseEndCB, void* pCookie, XnCallbackHandle& hCallback);
    void UnregisterFromPoseCallbacks(XnCallbackHandle hCallback);
*/
};

# -----------------------------------------------------------------------------
# MirrorCapability

class MirrorCapability : public Capability
{
public:
    MirrorCapability(XnNodeHandle hNode);

    XnStatus SetMirror(XnBool bMirror);
    XnBool IsMirrored() const;

/*
    XnStatus RegisterToMirrorChange(StateChangedHandler handler, void* pCookie, XnCallbackHandle& hCallback);
    void UnregisterFromMirrorChange(XnCallbackHandle hCallback);
*/
};

# -----------------------------------------------------------------------------
# AlternativeViewPointCapability

class AlternativeViewPointCapability : public Capability
{
public:
    AlternativeViewPointCapability(XnNodeHandle hNode);

    XnBool IsViewPointSupported(xn::ProductionNode& otherNode) const;
    XnStatus SetViewPoint(xn::ProductionNode& otherNode);
    XnStatus ResetViewPoint();
    XnBool IsViewPointAs(xn::ProductionNode& otherNode) const;

/*
    XnStatus RegisterToViewPointChange(StateChangedHandler handler, void* pCookie, XnCallbackHandle& hCallback);
    void UnregisterFromViewPointChange(XnCallbackHandle hCallback);
*/
};


# -----------------------------------------------------------------------------
# FrameSyncCapability

class FrameSyncCapability : public Capability
{
public:
    FrameSyncCapability(XnNodeHandle hNode);

    XnBool CanFrameSyncWith(xn::Generator& other) const;
    XnStatus FrameSyncWith(xn::Generator& other);
    XnStatus StopFrameSyncWith(xn::Generator& other);
    XnBool IsFrameSyncedWith(xn::Generator& other) const;

/*
    XnStatus RegisterToFrameSyncChange(StateChangedHandler handler, void* pCookie, XnCallbackHandle& hCallback);
    void UnregisterFromFrameSyncChange(XnCallbackHandle hCallback);
*/
};

# -----------------------------------------------------------------------------
# CroppingCapability

class CroppingCapability : public Capability
{
public:
    CroppingCapability(XnNodeHandle hNode);

    XnStatus SetCropping(const XnCropping& Cropping);
    XnStatus GetCropping(XnCropping& Cropping) const;

/*
    XnStatus RegisterToCroppingChange(StateChangedHandler handler, void* pCookie, XnCallbackHandle& hCallback);
    void UnregisterFromCroppingChange(XnCallbackHandle hCallback);
*/
};

# -----------------------------------------------------------------------------
# GeneralIntCapability

class GeneralIntCapability : public Capability
{
public:
    GeneralIntCapability(XnNodeHandle hNode, const XnChar* strCap);

    void GetRange(XnInt32& nMin, XnInt32& nMax, XnInt32& nStep, XnInt32& nDefault, XnBool& bIsAutoSupported) const;

    XnInt32 Get();
    XnStatus Set(XnInt32 nValue);

/*
    RegisterToValueChange(StateChangedHandler handler, void* pCookie, XnCallbackHandle& hCallback);
    void UnregisterFromValueChange(XnCallbackHandle hCallback);
*/
};

# -----------------------------------------------------------------------------
# AntiFlickerCapability

class AntiFlickerCapability : public Capability
{
public:
    AntiFlickerCapability(XnNodeHandle hNode);

    XnStatus SetPowerLineFrequency(XnPowerLineFrequency nFrequency);
    XnPowerLineFrequency GetPowerLineFrequency();

/*
    XnStatus RegisterToPowerLineFrequencyChange(StateChangedHandler handler, void* pCookie, XnCallbackHandle& hCallback);
    void UnregisterFromPowerLineFrequencyChange(XnCallbackHandle hCallback);
*/
};

# -----------------------------------------------------------------------------
# UserPositionCapability

class UserPositionCapability : public Capability
{
public:
    UserPositionCapability(XnNodeHandle hNode = NULL);

    XnUInt32 GetSupportedUserPositionsCount() const;
    XnStatus SetUserPosition(XnUInt32 nIndex, const XnBoundingBox3D& Position);
    XnStatus GetUserPosition(XnUInt32 nIndex, XnBoundingBox3D& Position) const;

/*
    XnStatus RegisterToUserPositionChange(StateChangedHandler handler, void* pCookie, XnCallbackHandle& hCallback);
    void UnregisterFromUserPositionChange(XnCallbackHandle hCallback);
*/
};


# -----------------------------------------------------------------------------
# NodeInfo

class NodeInfo
{
public:

    NodeInfo(XnNodeInfo* pInfo);
    NodeInfo(const NodeInfo& other);
    ~NodeInfo();

/*
    NodeInfo& operator=(const NodeInfo& other);
    operator XnNodeInfo*();
*/

    XnStatus SetInstanceName(const XnChar* strName);

    const XnProductionNodeDescription& GetDescription();

    const XnChar* GetInstanceName() const;

    const XnChar* GetCreationInfo() const;

    xn::NodeInfoList& GetNeededNodes() const;

 //   XnStatus GetInstance(ProductionNode& node) const;

    const void* GetAdditionalData() const;

};


# -----------------------------------------------------------------------------
# NodeInfoList

class NodeInfoList
{
public:

/*
    class Iterator;
*/
    NodeInfoList();
    NodeInfoList(XnNodeInfoList* pList);
    ~NodeInfoList();

    XnNodeInfoList* GetUnderlyingObject() const;

    void ReplaceUnderlyingObject(XnNodeInfoList* pList);

    XnStatus Add(XnProductionNodeDescription& description, const XnChar* strCreationInfo, NodeInfoList* pNeededNodes);
    XnStatus AddEx(XnProductionNodeDescription& description, const XnChar* strCreationInfo, NodeInfoList* pNeededNodes, const void* pAdditionalData, XnFreeHandler pFreeHandler);

    XnStatus AddNode(NodeInfo& info);
/*
    XnStatus AddNodeFromAnotherList(Iterator& it);

    Iterator Begin() const;
    Iterator End() const;
    Iterator RBegin() const;
    Iterator REnd() const;
    XnStatus Remove(Iterator& it);
*/
    XnStatus Clear();
    XnStatus Append(NodeInfoList& other);

    XnBool IsEmpty();

/*
    XnStatus FilterList(Context& context, Query& query);
*/
};

/*
class NodeInfoList::Iterator
{
public:
    friend class NodeInfoList;

    XnBool operator==(const Iterator& other) const;
    XnBool operator!=(const Iterator& other) const;
    Iterator& operator++();
    Iterator operator++(int);
    Iterator& operator--();
    Iterator operator--(int);
    NodeInfo operator*();
};
*/


# -----------------------------------------------------------------------------
# NodeWrapper 

class NodeWrapper
{
public:
    friend class Context;

    NodeWrapper(XnNodeHandle hNode);
    ~NodeWrapper();


/*
    operator XnNodeHandle() const;
    XnBool operator==(const NodeWrapper& other);
    XnBool operator!=(const NodeWrapper& other);
*/

    XnBool IsValid() const;


    const XnChar* GetName() const;
    XnStatus AddRef();

    void Release();

    void SetHandle(XnNodeHandle hNode);
};


# -----------------------------------------------------------------------------
# ProductionNode

class ProductionNode : public NodeWrapper
{
public:
    ProductionNode(XnNodeHandle hNode = NULL);

    NodeInfo GetInfo() const ;

    XnStatus AddNeededNode(ProductionNode& needed);

    XnStatus RemoveNeededNode(ProductionNode& needed);
    void GetContext(Context& context) const;

    XnBool IsCapabilitySupported(const XnChar* strCapabilityName) const;

    XnStatus SetIntProperty(const XnChar* strName, XnUInt64 nValue);
    XnStatus SetRealProperty(const XnChar* strName, XnDouble dValue);
    XnStatus SetStringProperty(const XnChar* strName, const XnChar* strValue);
    XnStatus SetGeneralProperty(const XnChar* strName, XnUInt32 nBufferSize, const void* pBuffer);
    XnStatus GetIntProperty(const XnChar* strName, XnUInt64& nValue) const;
    XnStatus GetRealProperty(const XnChar* strName, XnDouble &dValue) const;
    XnStatus GetStringProperty(const XnChar* strName, XnChar* csValue, XnUInt32 nBufSize) const;
    XnStatus GetGeneralProperty(const XnChar* strName, XnUInt32 nBufferSize, void* pBuffer) const;

    XnStatus LockForChanges(XnLockHandle* phLock);
    void UnlockForChanges(XnLockHandle hLock);

    XnStatus LockedNodeStartChanges(XnLockHandle hLock);
    void LockedNodeEndChanges(XnLockHandle hLock);

    /*
        const ErrorStateCapability GetErrorStateCap() const;
        ErrorStateCapability GetErrorStateCap();

        GeneralIntCapability GetGeneralIntCap(const XnChar* strCapability);
    */

};

# -----------------------------------------------------------------------------
# Generator

class Generator : public ProductionNode
{
public:
    Generator(XnNodeHandle hNode = NULL);

    XnStatus StartGenerating();
    XnBool IsGenerating() const;
    XnStatus StopGenerating();

/*
    XnStatus RegisterToGenerationRunningChange(StateChangedHandler handler, void* pCookie, XnCallbackHandle &hCallback)
    void UnregisterFromGenerationRunningChange(XnCallbackHandle hCallback);

    XnStatus RegisterToNewDataAvailable(StateChangedHandler handler, void* pCookie, XnCallbackHandle &hCallback);
    void UnregisterFromNewDataAvailable(XnCallbackHandle hCallback);
*/

    XnBool IsNewDataAvailable(XnUInt64* pnTimestamp = NULL) const;
    XnStatus WaitAndUpdateData();
    XnBool IsDataNew() const;

    const void* GetData();

    XnUInt32 GetDataSize() const;
    XnUInt64 GetTimestamp() const;

    XnUInt32 GetFrameID() const;

    const MirrorCapability GetMirrorCap() const;
    MirrorCapability GetMirrorCap();

    const AlternativeViewPointCapability GetAlternativeViewPointCap() const;
    AlternativeViewPointCapability GetAlternativeViewPointCap();

    const FrameSyncCapability GetFrameSyncCap() const;
    FrameSyncCapability GetFrameSyncCap();

};

# -----------------------------------------------------------------------------
# MapGenerator

class MapGenerator : public Generator
{
public:
    MapGenerator(XnNodeHandle hNode = NULL);

    XnUInt32 GetSupportedMapOutputModesCount() const;
    XnStatus GetSupportedMapOutputModes(XnMapOutputMode* aModes, XnUInt32& nCount) const;
    XnStatus SetMapOutputMode(const XnMapOutputMode& OutputMode);
    XnStatus GetMapOutputMode(XnMapOutputMode &OutputMode) const;

    XnUInt32 GetBytesPerPixel() const;

/*
    XnStatus RegisterToMapOutputModeChange(StateChangedHandler handler, void* pCookie, XnCallbackHandle& hCallback);
    void UnregisterFromMapOutputModeChange(XnCallbackHandle hCallback);
*/

    const CroppingCapability GetCroppingCap() const;
    CroppingCapability GetCroppingCap();
    GeneralIntCapability GetBrightnessCap();
    GeneralIntCapability GetContrastCap();
    GeneralIntCapability GetHueCap();
    GeneralIntCapability GetSaturationCap();
    GeneralIntCapability GetSharpnessCap();
    GeneralIntCapability GetGammaCap();
    GeneralIntCapability GetWhiteBalanceCap();
    GeneralIntCapability GetBacklightCompensationCap();
    GeneralIntCapability GetGainCap();
    GeneralIntCapability GetPanCap();
    GeneralIntCapability GetTiltCap();
    GeneralIntCapability GetRollCap();
    GeneralIntCapability GetZoomCap();
    GeneralIntCapability GetExposureCap();
    GeneralIntCapability GetIrisCap();
    GeneralIntCapability GetFocusCap();
    GeneralIntCapability GetLowLightCompensationCap();
    AntiFlickerCapability GetAntiFlickerCap();
};


# -----------------------------------------------------------------------------
# DepthGenerator

class DepthGenerator : public MapGenerator
{
public:
    DepthGenerator(XnNodeHandle hNode = NULL);
/*
    XnStatus Create(Context& context, Query* pQuery = NULL, EnumerationErrors* pErrors = NULL);
*/
    void GetMetaData(DepthMetaData& metaData) const ;
    const XnDepthPixel* GetDepthMap() const;
    XnDepthPixel GetDeviceMaxDepth() const;
    XnStatus GetFieldOfView(XnFieldOfView& FOV) const;

/*
    XnStatus RegisterToFieldOfViewChange(StateChangedHandler handler, void* pCookie, XnCallbackHandle& hCallback);
    void UnregisterFromFieldOfViewChange(XnCallbackHandle hCallback);
*/

    XnStatus ConvertProjectiveToRealWorld(XnUInt32 nCount, const XnPoint3D aProjective[], XnPoint3D aRealWorld[]) const;
    XnStatus ConvertRealWorldToProjective(XnUInt32 nCount, const XnPoint3D aRealWorld[], XnPoint3D aProjective[]) const;

    const UserPositionCapability GetUserPositionCap() const;
    UserPositionCapability GetUserPositionCap();
};


# -----------------------------------------------------------------------------
# ImageGenerator

class ImageGenerator : public MapGenerator
{
public:
    ImageGenerator(XnNodeHandle hNode = NULL);
/*
    XnStatus Create(Context& context, Query* pQuery = NULL, EnumerationErrors* pErrors = NULL);
*/
    void GetMetaData(ImageMetaData& metaData) const ;
    const XnRGB24Pixel* GetRGB24ImageMap() const;
    const XnYUV422DoublePixel* GetYUV422ImageMap() const;
    const XnGrayscale8Pixel* GetGrayscale8ImageMap() const;
    const XnGrayscale16Pixel* GetGrayscale16ImageMap() const;
    const XnUInt8* GetImageMap() const;

    XnBool IsPixelFormatSupported(XnPixelFormat Format) const;
    XnStatus SetPixelFormat(XnPixelFormat Format);
    XnPixelFormat GetPixelFormat() const;

/*
    XnStatus RegisterToPixelFormatChange(StateChangedHandler handler, void* pCookie, XnCallbackHandle& hCallback);
    void UnregisterFromPixelFormatChange(XnCallbackHandle hCallback);
*/
};

# -----------------------------------------------------------------------------
# IRGenerator

class IRGenerator : public MapGenerator
{
public:
        IRGenerator(XnNodeHandle hNode = NULL);
/*
        XnStatus Create(Context& context, Query* pQuery = NULL, EnumerationErrors* pErrors = NULL);
*/
        void GetMetaData(IRMetaData& metaData) const ;
        const XnIRPixel* GetIRMap() const;
};

# -----------------------------------------------------------------------------
# GestureGenerator

class GestureGenerator : public Generator
{
public:

    GestureGenerator(XnNodeHandle hNode = NULL);
/*
    XnStatus Create(Context& context, Query* pQuery = NULL, EnumerationErrors* pErrors = NULL);
*/
    XnStatus AddGesture(const XnChar* strGesture, XnBoundingBox3D* pArea);

    XnStatus RemoveGesture(const XnChar* strGesture);

    XnStatus GetActiveGestures(XnChar*& astrGestures, XnUInt16& nGestures) const;

    XnStatus GetAllActiveGestures(XnChar** astrGestures, XnUInt32 nNameLength, XnUInt16& nGestures) const;

    XnStatus EnumerateGestures(XnChar*& astrGestures, XnUInt16& nGestures) const;
    XnStatus EnumerateAllGestures(XnChar** astrGestures, XnUInt32 nNameLength, XnUInt16& nGestures) const;

    XnBool IsGestureAvailable(const XnChar* strGesture) const;
    XnBool IsGestureProgressSupported(const XnChar* strGesture) const;

/*
    typedef void (XN_CALLBACK_TYPE* GestureRecognized)(GestureGenerator& generator, const XnChar* strGesture, const XnPoint3D* pIDPosition, const XnPoint3D* pEndPosition, void* pCookie);
    typedef void (XN_CALLBACK_TYPE* GestureProgress)(GestureGenerator& generator, const XnChar* strGesture, const XnPoint3D* pPosition, XnFloat fProgress, void* pCookie);

    XnStatus RegisterGestureCallbacks(GestureRecognized RecognizedCB, GestureProgress ProgressCB, void* pCookie, XnCallbackHandle& hCallback);
    void UnregisterGestureCallbacks(XnCallbackHandle hCallback);

    XnStatus RegisterToGestureChange(StateChangedHandler handler, void* pCookie, XnCallbackHandle& hCallback);
    void UnregisterFromGestureChange(XnCallbackHandle hCallback);
*/
};


# -----------------------------------------------------------------------------
# HandsGenerator

class HandsGenerator : public Generator
{
public:
        HandsGenerator(XnNodeHandle hNode = NULL);

/*
        XnStatus Create(Context& context, Query* pQuery = NULL, EnumerationErrors* pErrors = NULL);
*/

/*
        typedef void (XN_CALLBACK_TYPE* HandCreate)(HandsGenerator& generator, XnUserID user, const XnPoint3D* pPosition, XnFloat fTime, void* pCookie);
        typedef void (XN_CALLBACK_TYPE* HandUpdate)(HandsGenerator& generator, XnUserID user, const XnPoint3D* pPosition, XnFloat fTime, void* pCookie);
        typedef void (XN_CALLBACK_TYPE* HandDestroy)(HandsGenerator& generator, XnUserID user, XnFloat fTime, void* pCookie);

        XnStatus RegisterHandCallbacks(HandCreate CreateCB, HandUpdate UpdateCB, HandDestroy DestroyCB, void* pCookie, XnCallbackHandle& hCallback);
        void UnregisterHandCallbacks(XnCallbackHandle hCallback);
*/

        XnStatus StopTracking(XnUserID user);
        XnStatus StopTrackingAll();

        XnStatus StartTracking(const XnPoint3D& ptPosition);
        XnStatus SetSmoothing(XnFloat fSmoothingFactor);
};

# -----------------------------------------------------------------------------
# SceneAnalyzer

class SceneAnalyzer : public MapGenerator
{
public:
        SceneAnalyzer(XnNodeHandle hNode = NULL);

/*
        XnStatus Create(Context& context, Query* pQuery = NULL, EnumerationErrors* pErrors = NULL);
*/
        void GetMetaData(SceneMetaData& metaData) const;
        const XnLabel* GetLabelMap() const;
        XnStatus GetFloor(XnPlane3D& Plane) const;
};

# -----------------------------------------------------------------------------
# UserGenerator

class UserGenerator : public Generator
{
public:

    UserGenerator(XnNodeHandle hNode = NULL) ;
/*
    XnStatus Create(Context& context, Query* pQuery = NULL, EnumerationErrors* pErrors = NULL);
*/

    XnUInt16 GetNumberOfUsers() const;

    XnStatus GetUsers(XnUserID aUsers[], XnUInt16& nUsers) const;
    XnStatus GetCoM(XnUserID user, XnPoint3D& com) const;
/*
    XnStatus GetUserPixels(XnUserID user, SceneMetaData& smd) const;
*/

/*
    typedef void (XN_CALLBACK_TYPE* UserHandler)(UserGenerator& generator, XnUserID user, void* pCookie);
    XnStatus RegisterUserCallbacks(UserHandler NewUserCB, UserHandler LostUserCB, void* pCookie, XnCallbackHandle& hCallback);
    void UnregisterUserCallbacks(XnCallbackHandle hCallback);
*/

    const SkeletonCapability GetSkeletonCap() const;
    SkeletonCapability GetSkeletonCap();

    const PoseDetectionCapability GetPoseDetectionCap() const;
    PoseDetectionCapability GetPoseDetectionCap();

};


};

