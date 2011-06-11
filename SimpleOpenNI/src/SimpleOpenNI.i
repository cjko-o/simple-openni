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



typedef	bool				XnBool;
typedef	char				XnChar;
typedef	unsigned int		XnUInt32;
typedef	int					XnInt32;
typedef	float				XnFloat;
typedef XnUInt32			XnVHandle;
typedef XnUInt32			XnStatus;
//typedef uint64_t			unsigned long;


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

