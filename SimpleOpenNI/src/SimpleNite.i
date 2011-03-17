# -----------------------------------------------------------------------------
# SimpleNite
# -----------------------------------------------------------------------------
# Processing Wrapper for the OpenNI/Kinect library
# prog:  Max Rheiner / Interaction Design / zhdh / http://iad.zhdk.ch/
# -----------------------------------------------------------------------------

# ----------------------------------------------------------------------------
# Virtual method test
/*
%{
#include <XnCppWrapper.h>
#include "XnVMessageListener.h"
#include "XnVDeviceControl.h"
#include <XnVSessionManager.h>
#include <XnPlatformWin32.h>
%}
#define XN_CALLBACK_TYPE XN_STDCALL

#%include <XnCppWrapper.h>
#%include "XnVMessageListener.h"
#%include "XnVDeviceControl.h"
#%include <XnVSessionManager.h>
#%include "XnPlatformWin32.h"
*/


%feature("director") TestClass;
class TestClass
{
public:
	TestClass()
	{}

	virtual void test1(int i);
	static void test(TestClass* p);

protected:

};

