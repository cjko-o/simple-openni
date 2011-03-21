# -----------------------------------------------------------------------------
# SimpleNite
# -----------------------------------------------------------------------------
# Processing Wrapper for the OpenNI/Kinect library
# prog:  Max Rheiner / Interaction Design / zhdh / http://iad.zhdk.ch/
# -----------------------------------------------------------------------------

# ----------------------------------------------------------------------------
# Virtual method test




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

