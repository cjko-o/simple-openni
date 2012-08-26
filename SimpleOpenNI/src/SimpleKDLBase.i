# -----------------------------------------------------------------------------
# SimpleKDL
# -----------------------------------------------------------------------------
# Processing Wrapper for the KDL - Kinematic Dynamics Library
# prog:  Max Rheiner / Interaction Design / zhdk / http://iad.zhdk.ch/
# -----------------------------------------------------------------------------


# ----------------------------------------------------------------------------
# KDL

%{
// KDL headers
#include <kdl/chain.hpp>
#include <kdl/chainfksolver.hpp>
#include <kdl/chainfksolverpos_recursive.hpp>
#include <kdl/frames_io.hpp>

#include <kdl/chainiksolver.hpp>
#include <kdl/chainiksolverpos_nr.hpp>
#include <kdl/chainiksolverpos_nr_jl.hpp>
#include <kdl/chainiksolverpos_nr.hpp>
#include <kdl/chainiksolverpos_lma.hpp>

#include <kdl/chainiksolvervel_pinv.hpp>
#include <kdl/chainiksolvervel_wdls.hpp>
#include <kdl/chainiksolvervel_pinv_givens.hpp>

#include <kdl/utilities/rall1d.h>
#include <kdl/utilities/traits.h>

#include <kdl/tree.hpp>
#include <kdl/treefksolver.hpp>
#include <kdl/treefksolverpos_recursive.hpp>
#include <kdl/treeiksolver.hpp>
#include <kdl/treeiksolvervel_wdls.hpp>
#include <kdl/treeiksolverpos_nr_jl.hpp>
#include <kdl/treeiksolverpos_online.hpp>

%}

%include "std_string.i"

# -----------------------------------------------------------------------------
# Context

namespace KDL{

class Vector;
class Rotation;
class Frame;
class Wrench;
class Twist;
class Vector2;
class Rotation2;
class Frame2;

class RotationalInertia;
class RigidBodyInertia;

class Vector
{
public:
%extend{
    std::string toString()
    {
        std::ostringstream formatStr;
        formatStr << "[" << self->data[0] << ", \t" <<
                            self->data[1] << ", \t" <<
                            self->data[2] << "]" ;

        return formatStr.str();
    }

    void set(int i,int value)
    {
        (*self)(i) = value;
    }
  
	double get(int i)const
	{	
	  return (*self)(i);
	}
}

    double data[3];

     Vector();
     Vector(double x,double y, double z);
     Vector(const Vector& arg);

/*
     Vector& operator = ( const Vector& arg);
     double operator()(int index) const;
     double& operator() (int index);
     double operator[] ( int index ) const;
     double& operator[] ( int index );
*/
     double x() const;
     double y() const;
     double z() const;
     void x(double);
     void y(double);
     void z(double);

     void ReverseSign();

/*
      Vector& operator-=(const Vector& arg);

      Vector& operator +=(const Vector& arg);

      friend Vector operator*(const Vector& lhs,double rhs);
      friend Vector operator*(double lhs,const Vector& rhs);

      friend Vector operator/(const Vector& lhs,double rhs);
      friend Vector operator+(const Vector& lhs,const Vector& rhs);
      friend Vector operator-(const Vector& lhs,const Vector& rhs);
      friend Vector operator*(const Vector& lhs,const Vector& rhs);
      friend Vector operator-(const Vector& arg);
      friend double dot(const Vector& lhs,const Vector& rhs);
*/
     friend void SetToZero(Vector& v);

     static Vector Zero();

     double Normalize(double eps=epsilon);

     double Norm() const;


/*
     void Set2DXY(const Vector2& v);
     void Set2DYZ(const Vector2& v);
     void Set2DZX(const Vector2& v);
     void Set2DPlane(const Frame& F_someframe_XY,const Vector2& v_XY);
*/

     friend bool Equal(const Vector& a,const Vector& b,double eps=epsilon);
/*
     friend bool operator==(const Vector& a,const Vector& b);
     friend bool operator!=(const Vector& a,const Vector& b);
*/

    friend class Rotation;
    friend class Frame;
};



class Rotation
{
public:
%extend{
    std::string toString()
    {
        std::ostringstream formatStr;
        formatStr << "[\t" << self->data[0] << ", \t" << self->data[1] << ", \t" << self->data[2] << ",\n" <<
                      "\t" << self->data[3] << ", \t" << self->data[4] << ", \t" << self->data[5] << ",\n" <<
                      "\t" << self->data[6] << ", \t" << self->data[7] << ", \t" << self->data[8] << "]";

        return formatStr.str();
    }

    void set(int i,int j,double value)
    {
        (*self)(i,j) = value;
    }
  
    double get(int i,int j)const
    {
        return (*self)(i,j);
    }

    Vector mult(const Vector& v) const
    {
        return (*self) * v;
    }

    static Rotation mult(const Rotation& lhs,const Rotation& rhs)
    {
        return lhs * rhs;
    }

}
     double data[9];

     Rotation();
     Rotation(double Xx,double Yx,double Zx,
     double Xy,double Yy,double Zy,
     double Xz,double Yz,double Zz);
     Rotation(const Vector& x,const Vector& y,const Vector& z);

/*
Rotation& operator=(const Rotation& arg);
Vector operator*(const Vector& v) const;
double& operator()(int i,int j);
double operator() (int i,int j) const;
friend Rotation operator *(const Rotation& lhs,const Rotation& rhs);
*/

      void SetInverse();
      Rotation Inverse() const;
      Vector Inverse(const Vector& v) const;
      Wrench Inverse(const Wrench& arg) const;
      Twist Inverse(const Twist& arg) const;

      static Rotation Identity();

     static Rotation RotX(double angle);
     static Rotation RotY(double angle);
     static Rotation RotZ(double angle);
     void DoRotX(double angle);
     void DoRotY(double angle);
     void DoRotZ(double angle);

    static Rotation Rot(const Vector& rotvec,double angle);
    static Rotation Rot2(const Vector& rotvec,double angle);

    Vector GetRot() const;
    double GetRotAngle(Vector& axis,double eps=epsilon) const;
    static Rotation EulerZYZ(double Alfa,double Beta,double Gamma);
    void GetEulerZYZ(double& alfa,double& beta,double& gamma) const;

    static Rotation Quaternion(double x,double y,double z, double w);
    void GetQuaternion(double& x,double& y,double& z, double& w) const;

    static Rotation RPY(double roll,double pitch,double yaw);
    void GetRPY(double& roll,double& pitch,double& yaw) const;


    static Rotation EulerZYX(double Alfa,double Beta,double Gamma);
    void GetEulerZYX(double& Alfa,double& Beta,double& Gamma) const;

/*
     Twist operator * (const Twist& arg) const;
      Wrench operator * (const Wrench& arg) const;
  */
     Vector UnitX() const;
     void UnitX(const Vector& X);

     Vector UnitY() const;
     void UnitY(const Vector& X);

     Vector UnitZ() const;
     void UnitZ(const Vector& X);

     friend bool Equal(const Rotation& a,const Rotation& b,double eps=epsilon);
/*
     friend bool operator==(const Rotation& a,const Rotation& b);
     friend bool operator!=(const Rotation& a,const Rotation& b);
*/
    friend class Frame;
};

class Frame
{
public:
    Vector p;
    Rotation M;

public:

%extend{
    std::string toString()
    {
        std::ostringstream formatStr;
        formatStr << "p:\n" << self->p << "\n" <<
                     "M:\n" << self->M;
        return formatStr.str();
    }
}

     Frame(const Rotation& R,const Vector& V);

     explicit  Frame(const Vector& V);
     explicit  Frame(const Rotation& R);

     Frame();
     Frame(const Frame& arg);

     void Make4x4(double* d);

/*
      double operator()(int i,int j);
      double operator() (int i,int j) const;
*/

      Frame Inverse() const;
      Vector Inverse(const Vector& arg) const;
      Wrench Inverse(const Wrench& arg) const;
      Twist  Inverse(const Twist& arg) const;
/*
      Frame& operator = (const Frame& arg);
      Vector operator * (const Vector& arg) const;
      Wrench operator * (const Wrench& arg) const;
      Twist operator * (const Twist& arg) const;
*/
      friend Frame operator *(const Frame& lhs,const Frame& rhs);

      static Frame Identity();

      void Integrate(const Twist& t_this,double frequency);


     static Frame DH_Craig1989(double a,double alpha,double d,double theta);
     static Frame DH(double a,double alpha,double d,double theta);

      friend bool Equal(const Frame& a,const Frame& b,double eps=epsilon);
/*
      friend bool operator==(const Frame& a,const Frame& b);
      friend bool operator!=(const Frame& a,const Frame& b);
*/
};

class Twist
{
public:
    Vector vel;
    Vector rot;
public:

    Twist();
    Twist(const Vector& _vel,const Vector& _rot);

/*
     Twist& operator-=(const Twist& arg);
     Twist& operator+=(const Twist& arg);
     double& operator()(int i);

     double operator()(int i) const;

     double operator[] ( int index ) const;
     double& operator[] ( int index );

      friend Twist operator*(const Twist& lhs,double rhs);
      friend Twist operator*(double lhs,const Twist& rhs);
      friend Twist operator/(const Twist& lhs,double rhs);
      friend Twist operator+(const Twist& lhs,const Twist& rhs);
      friend Twist operator-(const Twist& lhs,const Twist& rhs);
      friend Twist operator-(const Twist& arg);
      friend double dot(const Twist& lhs,const Wrench& rhs);
      friend double dot(const Wrench& rhs,const Twist& lhs);
      friend void SetToZero(Twist& v);
     friend Twist operator*(const Twist& lhs,const Twist& rhs);
     friend Wrench operator*(const Twist& lhs,const Wrench& rhs);
*/
     static  Twist Zero();

      void ReverseSign();

      Twist RefPoint(const Vector& v_base_AB) const;

      friend bool Equal(const Twist& a,const Twist& b,double eps=epsilon);
/*
      friend bool operator==(const Twist& a,const Twist& b);
      friend bool operator!=(const Twist& a,const Twist& b);
*/
    friend class Rotation;
    friend class Frame;
};

class Wrench
{
public:
    Vector force;
    Vector torque;
public:

    Wrench();
    Wrench(const Vector& _force,const Vector& _torque);

/*
     inline Wrench& operator-=(const Wrench& arg);
     inline Wrench& operator+=(const Wrench& arg);

     inline double& operator()(int i);

     inline double operator()(int i) const;

     double operator[] ( int index ) const;

     double& operator[] ( int index );

     inline friend Wrench operator*(const Wrench& lhs,double rhs);
     inline friend Wrench operator*(double lhs,const Wrench& rhs);
     inline friend Wrench operator/(const Wrench& lhs,double rhs);

     inline friend Wrench operator+(const Wrench& lhs,const Wrench& rhs);
     inline friend Wrench operator-(const Wrench& lhs,const Wrench& rhs);

     inline friend Wrench operator-(const Wrench& arg);
*/

     inline friend void SetToZero(Wrench& v);

     static inline Wrench Zero();

     inline void ReverseSign();

     inline Wrench RefPoint(const Vector& v_base_AB) const;


     inline friend bool Equal(const Wrench& a,const Wrench& b,double eps=epsilon);
/*
     inline friend bool operator==(const Wrench& a,const Wrench& b);
     inline friend bool operator!=(const Wrench& a,const Wrench& b);
*/
    friend class Rotation;
    friend class Frame;
};


class Vector2
{
public:
     Vector2();
     inline Vector2(double x,double y);
     inline Vector2(const Vector2& arg);

/*
     inline Vector2& operator = ( const Vector2& arg);

     inline double operator()(int index) const;

     inline double& operator() (int index);

        double operator[] ( int index ) const;
        double& operator[] ( int index );
*/

     inline double x() const;
     inline double y() const;
     inline void x(double);
     inline void y(double);

     inline void ReverseSign();
/*
     inline Vector2& operator-=(const Vector2& arg);
     inline Vector2& operator +=(const Vector2& arg);


     inline friend Vector2 operator*(const Vector2& lhs,double rhs);
     inline friend Vector2 operator*(double lhs,const Vector2& rhs);
     inline friend Vector2 operator/(const Vector2& lhs,double rhs);
     inline friend Vector2 operator+(const Vector2& lhs,const Vector2& rhs);
     inline friend Vector2 operator-(const Vector2& lhs,const Vector2& rhs);
     inline friend Vector2 operator*(const Vector2& lhs,const Vector2& rhs);
     inline friend Vector2 operator-(const Vector2& arg);
*/
     inline friend void SetToZero(Vector2& v);

     inline static Vector2 Zero();

     double Normalize(double eps=epsilon);

     double Norm() const;

     inline void Set3DXY(const Vector& v);
     inline void Set3DYZ(const Vector& v);
     inline void Set3DZX(const Vector& v);
     inline void Set3DPlane(const Frame& F_someframe_XY,const Vector& v_someframe);


     inline friend bool Equal(const Vector2& a,const Vector2& b,double eps=epsilon);
/*
        inline friend bool operator==(const Vector2& a,const Vector2& b);
        inline friend bool operator!=(const Vector2& a,const Vector2& b);
*/
};


class Rotation2
{
public:
    Rotation2();

    explicit Rotation2(double angle_rad);
    Rotation2(double ca,double sa);
/*
     inline Rotation2& operator=(const Rotation2& arg);
     inline Vector2 operator*(const Vector2& v) const;
     inline double operator() (int i,int j) const;

     inline friend Rotation2 operator *(const Rotation2& lhs,const Rotation2& rhs);
*/

     inline void SetInverse();
     inline Rotation2 Inverse() const;
     inline Vector2 Inverse(const Vector2& v) const;

     inline void SetIdentity();
     inline static Rotation2 Identity();

     inline void SetRot(double angle);
     inline static Rotation2 Rot(double angle);
     inline double GetRot() const;

     inline friend bool Equal(const Rotation2& a,const Rotation2& b,double eps=epsilon);
};

/* gives troubles on osx (Make4x4,Integrate)
class Frame2
 {
public:
    Vector2 p;
    Rotation2 M;

public:

     inline Frame2(const Rotation2& R,const Vector2& V);
     explicit inline Frame2(const Vector2& V);
     explicit inline Frame2(const Rotation2& R);
     inline Frame2(void);
     inline Frame2(const Frame2& arg);
     inline void Make4x4(double* d);


     inline double operator()(int i,int j);
     inline double operator() (int i,int j) const;

     inline void SetInverse();
     inline Frame2 Inverse() const;
     inline Vector2 Inverse(const Vector2& arg) const;

     inline Frame2& operator = (const Frame2& arg);
     inline Vector2 operator * (const Vector2& arg);
     inline friend Frame2 operator *(const Frame2& lhs,const Frame2& rhs);

     inline void SetIdentity();
     inline void Integrate(const Twist& t_this,double frequency);
     inline static Frame2 Identity();
     inline friend bool Equal(const Frame2& a,const Frame2& b,double eps=epsilon);
};
*/

///////////////////////////////////////////////////////////////////////////////
// kinematic chains

%feature("director") Joint;
class Joint
{
public:
    typedef enum { RotAxis,RotX,RotY,RotZ,TransAxis,TransX,TransY,TransZ,None} JointType;

    Joint(const std::string& name, const JointType& type=None,const double& scale=1,const double& offset=0,
          const double& inertia=0,const double& damping=0,const double& stiffness=0);
    Joint(const JointType& type=None,const double& scale=1,const double& offset=0,
           const double& inertia=0,const double& damping=0,const double& stiffness=0);
    Joint(const std::string& name, const Vector& _origin, const Vector& _axis, const JointType& type, const double& _scale=1, const double& _offset=0,
          const double& _inertia=0, const double& _damping=0, const double& _stiffness=0);
    Joint(const Vector& _origin, const Vector& _axis, const JointType& type, const double& _scale=1, const double& _offset=0,
          const double& _inertia=0, const double& _damping=0, const double& _stiffness=0);

    Frame pose(const double& q)const;
    Twist twist(const double& qdot)const;

    Vector JointAxis() const;

    Vector JointOrigin() const;
    const std::string& getName()const;
    const JointType& getType() const;

    const std::string getTypeName() const;

    virtual ~Joint();

};


class RotationalInertia
{
public:

    RotationalInertia(double Ixx=0,double Iyy=0,double Izz=0,double Ixy=0,double Ixz=0,double Iyz=0);
    static inline RotationalInertia Zero();
/*
    friend RotationalInertia operator*(double a, const RotationalInertia& I);
    friend RotationalInertia operator+(const RotationalInertia& Ia, const RotationalInertia& Ib);
*/
    //KDL::Vector operator*(const KDL::Vector& omega) const;

    ~RotationalInertia();

    friend class RigidBodyInertia;
/*
    friend RigidBodyInertia operator*(double a,const RigidBodyInertia& I);
    friend RigidBodyInertia operator+(const RigidBodyInertia& Ia,const RigidBodyInertia& Ib);
    friend Wrench operator*(const RigidBodyInertia& I,const Twist& t);
    friend RigidBodyInertia operator*(const Frame& T,const RigidBodyInertia& I);
    friend RigidBodyInertia operator*(const Rotation& R,const RigidBodyInertia& I);
*/

    double data[9];
};


class RigidBodyInertia
{
public:

    RigidBodyInertia(double m=0, const Vector& oc=Vector::Zero(), const RotationalInertia& Ic=RotationalInertia::Zero());

    static inline RigidBodyInertia Zero();

    ~RigidBodyInertia(){};
/*
    friend RigidBodyInertia operator*(double a,const RigidBodyInertia& I);
    friend RigidBodyInertia operator+(const RigidBodyInertia& Ia,const RigidBodyInertia& Ib);

    friend Wrench operator*(const RigidBodyInertia& I,const Twist& t);

    friend RigidBodyInertia operator*(const Frame& T,const RigidBodyInertia& I);
    friend RigidBodyInertia operator*(const Rotation& R,const RigidBodyInertia& I);
*/

    RigidBodyInertia RefPoint(const Vector& p);

    double getMass();
    Vector getCOG() const;
    RotationalInertia getRotationalInertia() const;

};


class Segment
{
    friend class Chain;

public:
    Segment(const std::string& name, const Joint& joint=Joint(Joint::None), const Frame& f_tip=Frame::Identity(),const RigidBodyInertia& I = RigidBodyInertia::Zero());
    Segment(const Joint& joint=Joint(Joint::None), const Frame& f_tip=Frame::Identity(),const RigidBodyInertia& I = RigidBodyInertia::Zero());
    Segment(const Segment& in);
    Segment& operator=(const Segment& arg);

    virtual ~Segment();

    Frame pose(const double& q)const;
    Twist twist(const double& q,const double& qdot)const;

    const std::string& getName()const;

    const Joint& getJoint()const;

    const RigidBodyInertia& getInertia()const;
    void setInertia(const RigidBodyInertia& Iin);
    Frame getFrameToTip()const;

};

class Chain
{
public:
    std::vector<Segment> segments;

    Chain();
    Chain(const Chain& in);
    Chain& operator = (const Chain& arg);

    void addSegment(const Segment& segment);
    void addChain(const Chain& chain);

    unsigned int getNrOfJoints()const {return nrOfJoints;};
    unsigned int getNrOfSegments()const {return nrOfSegments;};

    const Segment& getSegment(unsigned int nr)const;

    virtual ~Chain();
};

///////////////////////////////////////////////////////////////////////////////
// Array

    %rename(copy) JntArray::operator=(const JntArray& arg);
    %rename(get) JntArray::operator()(unsigned int i,unsigned int j=0)const;

class JntArray
{
public:
//    Eigen::VectorXd data;

    %rename(copy) operator=(const JntArray& arg);
    %rename(get) operator()(unsigned int i,unsigned int j=0)const;

%extend{
    void set(unsigned int i,double value)
    {
        (*self)(i) = value;
    }
  
	double get(unsigned int i,unsigned int j=0)const
	{	
	  return (*self)(i,j);
	}
}

%extend{
    std::string toString()
    {
        std::stringstream formatStr;
        formatStr << self->data;

        return formatStr.str();
    }
}

    JntArray();
    JntArray(unsigned int size);
    JntArray(const JntArray& arg);
    ~JntArray();
    void resize(unsigned int newSize);
/*
    JntArray& operator = ( const JntArray& arg);
    double operator()(unsigned int i,unsigned int j=0)const;
    double& operator()(unsigned int i,unsigned int j=0);
*/
    unsigned int rows()const;
    unsigned int columns()const;

    friend void Add(const JntArray& src1,const JntArray& src2,JntArray& dest);
    friend void Subtract(const JntArray& src1,const JntArray& src2,JntArray& dest);
    friend void Multiply(const JntArray& src,const double& factor,JntArray& dest);
    friend void Divide(const JntArray& src,const double& factor,JntArray& dest);
    friend void MultiplyJacobian(const Jacobian& jac, const JntArray& src, Twist& dest);
    friend void SetToZero(JntArray& array);
    friend bool Equal(const JntArray& src1,const JntArray& src2,double eps);
/*
    friend bool operator==(const JntArray& src1,const JntArray& src2);
    //friend bool operator!=(const JntArray& src1,const JntArray& src2);
*/
};

class JntArrayAcc
{
public:
    JntArray q;
    JntArray qdot;
    JntArray qdotdot;
public:
  JntArrayAcc();
    JntArrayAcc(unsigned int size);
    JntArrayAcc(const JntArray& q,const JntArray& qdot,const JntArray& qdotdot);
    JntArrayAcc(const JntArray& q,const JntArray& qdot);
    JntArrayAcc(const JntArray& q);

    void resize(unsigned int newSize);

    JntArray value()const;
    JntArray deriv()const;
    JntArray dderiv()const;

    friend void Add(const JntArrayAcc& src1,const JntArrayAcc& src2,JntArrayAcc& dest);
    friend void Add(const JntArrayAcc& src1,const JntArrayVel& src2,JntArrayAcc& dest);
    friend void Add(const JntArrayAcc& src1,const JntArray& src2,JntArrayAcc& dest);
    friend void Subtract(const JntArrayAcc& src1,const JntArrayAcc& src2,JntArrayAcc& dest);
    friend void Subtract(const JntArrayAcc& src1,const JntArrayVel& src2,JntArrayAcc& dest);
    friend void Subtract(const JntArrayAcc& src1,const JntArray& src2,JntArrayAcc& dest);
    friend void Multiply(const JntArrayAcc& src,const double& factor,JntArrayAcc& dest);
    friend void Multiply(const JntArrayAcc& src,const doubleVel& factor,JntArrayAcc& dest);
    friend void Multiply(const JntArrayAcc& src,const doubleAcc& factor,JntArrayAcc& dest);
    friend void Divide(const JntArrayAcc& src,const double& factor,JntArrayAcc& dest);
    friend void Divide(const JntArrayAcc& src,const doubleVel& factor,JntArrayAcc& dest);
    friend void Divide(const JntArrayAcc& src,const doubleAcc& factor,JntArrayAcc& dest);
    friend void SetToZero(JntArrayAcc& array);
    friend bool Equal(const JntArrayAcc& src1,const JntArrayAcc& src2,double eps=epsilon);

};

class JntArrayVel
{
public:
    JntArray q;
    JntArray qdot;
public:
    JntArrayVel();
    JntArrayVel(unsigned int size);
    JntArrayVel(const JntArray& q,const JntArray& qdot);
    JntArrayVel(const JntArray& q);

    void resize(unsigned int newSize);

    JntArray value()const;
    JntArray deriv()const;

    friend void Add(const JntArrayVel& src1,const JntArrayVel& src2,JntArrayVel& dest);
    friend void Add(const JntArrayVel& src1,const JntArray& src2,JntArrayVel& dest);
    friend void Subtract(const JntArrayVel& src1,const JntArrayVel& src2,JntArrayVel& dest);
    friend void Subtract(const JntArrayVel& src1,const JntArray& src2,JntArrayVel& dest);
    friend void Multiply(const JntArrayVel& src,const double& factor,JntArrayVel& dest);
    friend void Multiply(const JntArrayVel& src,const doubleVel& factor,JntArrayVel& dest);
    friend void Divide(const JntArrayVel& src,const double& factor,JntArrayVel& dest);
    friend void Divide(const JntArrayVel& src,const doubleVel& factor,JntArrayVel& dest);
    friend void SetToZero(JntArrayVel& array);
    friend bool Equal(const JntArrayVel& src1,const JntArrayVel& src2,double eps=epsilon);

};

///////////////////////////////////////////////////////////////////////////////
// velocity

class TwistVel;
class VectorVel;
class FrameVel;
class RotationVel;

typedef KDL::Rall1d<double> doubleVel;

class VectorVel
{
public:
    Vector p;       // position vector
    Vector v;       // velocity vector
public:
    VectorVel();
    VectorVel(const Vector& _p,const Vector& _v);
    explicit VectorVel(const Vector& _p);

    Vector value() const;
    Vector deriv() const;
/*
     VectorVel& operator = (const VectorVel& arg);
     VectorVel& operator = (const Vector& arg);
     VectorVel& operator += (const VectorVel& arg);
     VectorVel& operator -= (const VectorVel& arg);
*/
     static VectorVel Zero();
     void ReverseSign();
     doubleVel Norm() const;
/*
     friend VectorVel operator + (const VectorVel& r1,const VectorVel& r2);
     friend VectorVel operator - (const VectorVel& r1,const VectorVel& r2);
     friend VectorVel operator + (const Vector& r1,const VectorVel& r2);
     friend VectorVel operator - (const Vector& r1,const VectorVel& r2);
     friend VectorVel operator + (const VectorVel& r1,const Vector& r2);
     friend VectorVel operator - (const VectorVel& r1,const Vector& r2);
     friend VectorVel operator * (const VectorVel& r1,const VectorVel& r2);
     friend VectorVel operator * (const VectorVel& r1,const Vector& r2);
     friend VectorVel operator * (const Vector& r1,const VectorVel& r2);
     friend VectorVel operator * (const VectorVel& r1,double r2);
     friend VectorVel operator * (double r1,const VectorVel& r2);
     friend VectorVel operator * (const doubleVel& r1,const VectorVel& r2);
     friend VectorVel operator * (const VectorVel& r2,const doubleVel& r1);
     friend VectorVel operator*(const Rotation& R,const VectorVel& x);

     friend VectorVel operator / (const VectorVel& r1,double r2);
     friend VectorVel operator / (const VectorVel& r2,const doubleVel& r1);
*/
     friend void SetToZero(VectorVel& v);


     friend bool Equal(const VectorVel& r1,const VectorVel& r2,double eps=epsilon);
     friend bool Equal(const Vector& r1,const VectorVel& r2,double eps=epsilon);
     friend bool Equal(const VectorVel& r1,const Vector& r2,double eps=epsilon);
     friend VectorVel operator - (const VectorVel& r);
     friend doubleVel dot(const VectorVel& lhs,const VectorVel& rhs);
     friend doubleVel dot(const VectorVel& lhs,const Vector& rhs);
     friend doubleVel dot(const Vector& lhs,const VectorVel& rhs);
};

class RotationVel
{
public:
    Rotation R; // Rotation matrix
    Vector   w; // rotation vector
public:
    RotationVel();
    explicit RotationVel(const Rotation& _R);
    RotationVel(const Rotation& _R,const Vector& _w);


    Rotation value() const;
    Vector   deriv() const;

/*
     RotationVel& operator = (const RotationVel& arg);
     RotationVel& operator = (const Rotation& arg);
*/
         VectorVel UnitX() const;
         VectorVel UnitY() const;
         VectorVel UnitZ() const;
     static RotationVel Identity();
     RotationVel Inverse() const;
     VectorVel Inverse(const VectorVel& arg) const;
     VectorVel Inverse(const Vector& arg) const;
/*
     VectorVel operator*(const VectorVel& arg) const;
     VectorVel operator*(const Vector& arg) const;
*/
     void DoRotX(const doubleVel& angle);
     void DoRotY(const doubleVel& angle);
     void DoRotZ(const doubleVel& angle);
     static RotationVel RotX(const doubleVel& angle);
     static RotationVel RotY(const doubleVel& angle);
     static RotationVel RotZ(const doubleVel& angle);
     static RotationVel Rot(const Vector& rotvec,const doubleVel& angle);
    // rotvec has arbitrary norm
    // rotation around a constant vector !
     static RotationVel Rot2(const Vector& rotvec,const doubleVel& angle);
    // rotvec is normalized.
    // rotation around a constant vector !
/*
     friend RotationVel operator* (const RotationVel& r1,const RotationVel& r2);
     friend RotationVel operator* (const Rotation& r1,const RotationVel& r2);
     friend RotationVel operator* (const RotationVel& r1,const Rotation& r2);
*/
     friend bool Equal(const RotationVel& r1,const RotationVel& r2,double eps=epsilon);
     friend bool Equal(const Rotation& r1,const RotationVel& r2,double eps=epsilon);
     friend bool Equal(const RotationVel& r1,const Rotation& r2,double eps=epsilon);

     TwistVel Inverse(const TwistVel& arg) const;
     TwistVel Inverse(const Twist& arg) const;
/*
     TwistVel operator * (const TwistVel& arg) const;
     TwistVel operator * (const Twist& arg) const;
*/
};

class FrameVel
{
public:
    RotationVel M;
    VectorVel   p;
public:
    FrameVel();
    explicit FrameVel(const Frame& _T);
    FrameVel(const Frame& _T,const Twist& _t);
    FrameVel(const RotationVel& _M,const VectorVel& _p);

    Frame value() const;
    Twist deriv() const;

/*
     FrameVel& operator = (const Frame& arg);
     FrameVel& operator = (const FrameVel& arg);
*/
     static FrameVel Identity();
     FrameVel Inverse() const;
     VectorVel Inverse(const VectorVel& arg) const;
/*
     VectorVel operator*(const VectorVel& arg) const;
     VectorVel operator*(const Vector& arg) const;
*/
     VectorVel Inverse(const Vector& arg) const;
     Frame GetFrame() const;
     Twist GetTwist() const;
/*
     friend FrameVel operator * (const FrameVel& f1,const FrameVel& f2);
     friend FrameVel operator * (const Frame& f1,const FrameVel& f2);
     friend FrameVel operator * (const FrameVel& f1,const Frame& f2);
*/
     friend bool Equal(const FrameVel& r1,const FrameVel& r2,double eps=epsilon);
     friend bool Equal(const Frame& r1,const FrameVel& r2,double eps=epsilon);
     friend bool Equal(const FrameVel& r1,const Frame& r2,double eps=epsilon);

     TwistVel  Inverse(const TwistVel& arg) const;
     TwistVel  Inverse(const Twist& arg) const;
/*
     TwistVel operator * (const TwistVel& arg) const;
     TwistVel operator * (const Twist& arg) const;
*/
};

//very similar to Wrench class.
class TwistVel
{
public:
    VectorVel vel;
    VectorVel rot;
public:

// = Constructors
    TwistVel();
    TwistVel(const VectorVel& _vel,const VectorVel& _rot);
    TwistVel(const Twist& p,const Twist& v);
    TwistVel(const Twist& p);

    Twist value() const;
    Twist deriv() const;
/*
// = Operators
      TwistVel& operator-=(const TwistVel& arg);
      TwistVel& operator+=(const TwistVel& arg);

// = External operators
      friend TwistVel operator*(const TwistVel& lhs,double rhs);
      friend TwistVel operator*(double lhs,const TwistVel& rhs);
      friend TwistVel operator/(const TwistVel& lhs,double rhs);

      friend TwistVel operator*(const TwistVel& lhs,const doubleVel& rhs);
      friend TwistVel operator*(const doubleVel& lhs,const TwistVel& rhs);
      friend TwistVel operator/(const TwistVel& lhs,const doubleVel& rhs);

      friend TwistVel operator+(const TwistVel& lhs,const TwistVel& rhs);
      friend TwistVel operator-(const TwistVel& lhs,const TwistVel& rhs);
      friend TwistVel operator-(const TwistVel& arg);
*/
      friend void SetToZero(TwistVel& v);


// = Zero
     static  TwistVel Zero();

// = Reverse Sign
      void ReverseSign();

// = Change Reference point
      TwistVel RefPoint(const VectorVel& v_base_AB);

      friend bool Equal(const TwistVel& a,const TwistVel& b,double eps=epsilon);
      friend bool Equal(const Twist& a,const TwistVel& b,double eps=epsilon);
      friend bool Equal(const TwistVel& a,const Twist& b,double eps=epsilon);

// = Conversion to other entities
      Twist GetTwist() const;
      Twist GetTwistDot() const;

// = Friends
    friend class RotationVel;
    friend class FrameVel;

};

///////////////////////////////////////////////////////////////////////////////
// accel

class TwistAcc;
typedef KDL::Rall2d<double,double,double> doubleAcc;

class VectorAcc
{
public:
    Vector p;
    Vector v;
    Vector dv;
public:
    VectorAcc();
    explicit VectorAcc(const Vector& _p);
    VectorAcc(const Vector& _p,const Vector& _v);
    VectorAcc(const Vector& _p,const Vector& _v,const Vector& _dv);
/*
     VectorAcc& operator = (const VectorAcc& arg);
     VectorAcc& operator = (const Vector& arg);
     VectorAcc& operator += (const VectorAcc& arg);
     VectorAcc& operator -= (const VectorAcc& arg);
*/
     static VectorAcc Zero();
     void ReverseSign();
     doubleAcc Norm();
/*
     friend VectorAcc operator + (const VectorAcc& r1,const VectorAcc& r2);
     friend VectorAcc operator - (const VectorAcc& r1,const VectorAcc& r2);
     friend VectorAcc operator + (const Vector& r1,const VectorAcc& r2);
     friend VectorAcc operator - (const Vector& r1,const VectorAcc& r2);
     friend VectorAcc operator + (const VectorAcc& r1,const Vector& r2);
     friend VectorAcc operator - (const VectorAcc& r1,const Vector& r2);
     friend VectorAcc operator * (const VectorAcc& r1,const VectorAcc& r2);
     friend VectorAcc operator * (const VectorAcc& r1,const Vector& r2);
     friend VectorAcc operator * (const Vector& r1,const VectorAcc& r2);
     friend VectorAcc operator * (const VectorAcc& r1,double r2);
     friend VectorAcc operator * (double r1,const VectorAcc& r2);
     friend VectorAcc operator * (const doubleAcc& r1,const VectorAcc& r2);
     friend VectorAcc operator * (const VectorAcc& r2,const doubleAcc& r1);
     friend VectorAcc operator*(const Rotation& R,const VectorAcc& x);

     friend VectorAcc operator / (const VectorAcc& r1,double r2);
     friend VectorAcc operator / (const VectorAcc& r2,const doubleAcc& r1);
*/

     friend bool Equal(const VectorAcc& r1,const VectorAcc& r2,double eps=epsilon);
     friend bool Equal(const Vector& r1,const VectorAcc& r2,double eps=epsilon);
     friend bool Equal(const VectorAcc& r1,const Vector& r2,double eps=epsilon);
     friend VectorAcc operator - (const VectorAcc& r);
     friend doubleAcc dot(const VectorAcc& lhs,const VectorAcc& rhs);
     friend doubleAcc dot(const VectorAcc& lhs,const Vector& rhs);
     friend doubleAcc dot(const Vector& lhs,const VectorAcc& rhs);
};



class RotationAcc
{
public:
    Rotation R;
    Vector   w;
    Vector   dw;
public:
    RotationAcc();
    explicit RotationAcc(const Rotation& _R);
    RotationAcc(const Rotation& _R,const Vector& _w,const Vector& _dw);
/*
     RotationAcc& operator = (const RotationAcc& arg);
     RotationAcc& operator = (const Rotation& arg);
*/
     static RotationAcc Identity();
     RotationAcc Inverse() const;
     VectorAcc Inverse(const VectorAcc& arg) const;
     VectorAcc Inverse(const Vector& arg) const;
/*
     VectorAcc operator*(const VectorAcc& arg) const;
     VectorAcc operator*(const Vector& arg) const;

     friend RotationAcc operator* (const RotationAcc& r1,const RotationAcc& r2);
     friend RotationAcc operator* (const Rotation& r1,const RotationAcc& r2);
     friend RotationAcc operator* (const RotationAcc& r1,const Rotation& r2);
     */

     friend bool Equal(const RotationAcc& r1,const RotationAcc& r2,double eps=epsilon);
     friend bool Equal(const Rotation& r1,const RotationAcc& r2,double eps=epsilon);
     friend bool Equal(const RotationAcc& r1,const Rotation& r2,double eps=epsilon);
     TwistAcc Inverse(const TwistAcc& arg) const;
     TwistAcc Inverse(const Twist& arg) const;
/*
     TwistAcc operator * (const TwistAcc& arg) const;
     TwistAcc operator * (const Twist& arg) const;
*/
};

class FrameAcc
{
public:
    RotationAcc M;
    VectorAcc   p;
public:
    FrameAcc();
    explicit FrameAcc(const Frame& _T);
    FrameAcc(const Frame& _T,const Twist& _t,const Twist& _dt);
    FrameAcc(const RotationAcc& _M,const VectorAcc& _p);
/*
     FrameAcc& operator = (const FrameAcc& arg);
     FrameAcc& operator = (const Frame& arg);
*/
     static FrameAcc Identity();
     FrameAcc Inverse() const;
     VectorAcc Inverse(const VectorAcc& arg) const;
/*
     VectorAcc operator*(const VectorAcc& arg) const;
     VectorAcc operator*(const Vector& arg) const;
*/
     VectorAcc Inverse(const Vector& arg) const;
     Frame GetFrame() const;
     Twist GetTwist() const;
     Twist GetAccTwist() const;
/*
     friend FrameAcc operator * (const FrameAcc& f1,const FrameAcc& f2);
     friend FrameAcc operator * (const Frame& f1,const FrameAcc& f2);
     friend FrameAcc operator * (const FrameAcc& f1,const Frame& f2);
*/
     friend bool Equal(const FrameAcc& r1,const FrameAcc& r2,double eps=epsilon);
     friend bool Equal(const Frame& r1,const FrameAcc& r2,double eps=epsilon);
     friend bool Equal(const FrameAcc& r1,const Frame& r2,double eps=epsilon);

     TwistAcc  Inverse(const TwistAcc& arg) const;
     TwistAcc  Inverse(const Twist& arg) const;
/*
     TwistAcc operator * (const TwistAcc& arg) const;
     TwistAcc operator * (const Twist& arg) const;
*/
};

//very similar to Wrench class.
class TwistAcc
{
public:
    VectorAcc vel;
    VectorAcc rot;
public:

     TwistAcc();
     TwistAcc(const VectorAcc& _vel,const VectorAcc& _rot);
/*
      TwistAcc& operator-=(const TwistAcc& arg);
      TwistAcc& operator+=(const TwistAcc& arg);

      friend TwistAcc operator*(const TwistAcc& lhs,double rhs);
      friend TwistAcc operator*(double lhs,const TwistAcc& rhs);
      friend TwistAcc operator/(const TwistAcc& lhs,double rhs);

      friend TwistAcc operator*(const TwistAcc& lhs,const doubleAcc& rhs);
      friend TwistAcc operator*(const doubleAcc& lhs,const TwistAcc& rhs);
      friend TwistAcc operator/(const TwistAcc& lhs,const doubleAcc& rhs);

      friend TwistAcc operator+(const TwistAcc& lhs,const TwistAcc& rhs);
      friend TwistAcc operator-(const TwistAcc& lhs,const TwistAcc& rhs);
      friend TwistAcc operator-(const TwistAcc& arg);
*/
      friend void SetToZero(TwistAcc& v);

     static  TwistAcc Zero();

      void ReverseSign();

      TwistAcc RefPoint(const VectorAcc& v_base_AB);


      friend bool Equal(const TwistAcc& a,const TwistAcc& b,double eps=epsilon);
      friend bool Equal(const Twist& a,const TwistAcc& b,double eps=epsilon);
      friend bool Equal(const TwistAcc& a,const Twist& b,double eps=epsilon);


      Twist GetTwist() const;
      Twist GetTwistDot() const;

    friend class RotationAcc;
    friend class FrameAcc;

};

///////////////////////////////////////////////////////////////////////////////
// kinematic solvers

// forward kinematic
%feature("director") ChainFkSolverPos;
class ChainFkSolverPos
{
public:
    virtual int JntToCart(const JntArray& q_in, Frame& p_out,int segmentNr=-1)=0;
    virtual ~ChainFkSolverPos();
};

%feature("director") ChainFkSolverPos_recursive;
class ChainFkSolverPos_recursive : public ChainFkSolverPos
{
public:
    ChainFkSolverPos_recursive(const Chain& chain);
    ~ChainFkSolverPos_recursive();

    virtual int JntToCart(const JntArray& q_in, Frame& p_out, int segmentNr=-1);

private:
    const Chain chain;
};

%feature("director") ChainFkSolverVel;
class ChainFkSolverVel
{
public:
    virtual int JntToCart(const JntArrayVel& q_in, FrameVel& out,int segmentNr=-1)=0;

    virtual ~ChainFkSolverVel();
};


class ChainFkSolverAcc {
public:
virtual int JntToCart(const JntArrayAcc& q_in, FrameAcc& out,int segmentNr=-1)=0;

    virtual ~ChainFkSolverAcc()=0;
};


// inverse kinematic

%feature("director") ChainIkSolverPos;
class ChainIkSolverPos
{
public:
    virtual int CartToJnt(const JntArray& q_init, const Frame& p_in, JntArray& q_out)=0;
    virtual ~ChainIkSolverPos();};


%feature("director") ChainIkSolverVel;
class ChainIkSolverVel
{
public:
    virtual int CartToJnt(const JntArray& q_in, const Twist& v_in, JntArray& qdot_out)=0;
    virtual int CartToJnt(const JntArray& q_init, const FrameVel& v_in, JntArrayVel& q_out)=0;

    virtual ~ChainIkSolverVel(){};
};

%feature("director") ChainIkSolverVel_pinv;
class ChainIkSolverVel_pinv : public ChainIkSolverVel
{
public:
    ChainIkSolverVel_pinv(const Chain& chain,double eps=0.00001,int maxiter=150);
    ~ChainIkSolverVel_pinv();

    virtual int CartToJnt(const JntArray& q_in, const Twist& v_in, JntArray& qdot_out);
    virtual int CartToJnt(const JntArray& q_init, const FrameVel& v_in, JntArrayVel& q_out);
};


%feature("director") ChainIkSolverVel_wdls;
class ChainIkSolverVel_wdls : public ChainIkSolverVel
{
public:
  ChainIkSolverVel_wdls(const Chain& chain,double eps=0.00001,int maxiter=150);
  //=ublas::identity_matrix<double>
  ~ChainIkSolverVel_wdls();
 
  virtual int CartToJnt(const JntArray& q_in, const Twist& v_in, JntArray& qdot_out);
  virtual int CartToJnt(const JntArray& q_init, const FrameVel& v_in, JntArrayVel& q_out);
 
  void setWeightJS(const Eigen::MatrixXd& Mq);
 
  void setWeightTS(const Eigen::MatrixXd& Mx);
  void setLambda(const double& lambda); 
};

//%feature("director") ChainIkSolverAcc;
class ChainIkSolverAcc
{
public:
    virtual int CartToJnt(const JntArray& q_in, const JntArray& qdot_in, const Twist a_in,
                     JntArray& qdotdot_out)=0;
    virtual int CartTojnt(const JntArray& q_init, const FrameAcc& a_in,
                     JntArrayAcc& q_out)=0;

    virtual int CartToJnt(const JntArray& q_in, const Twist& v_in, const Twist& a_in,
                     JntArray& qdot_out, JntArray& qdotdot_out)=0;
    virtual int CartTojnt(const JntArray& q_init, const Frame& p_in, const JntArray& qdot_in, const Twist& a_in,
                     JntArray& q_out, JntArray& qdotdot_out)=0;
    virtual ~ChainIkSolverAcc(){};
};

%feature("director") ChainIkSolverPos_NR;
class ChainIkSolverPos_NR : public ChainIkSolverPos
{
public:
    ChainIkSolverPos_NR(const Chain& chain,ChainFkSolverPos& fksolver,ChainIkSolverVel& iksolver,
                        unsigned int maxiter=100,double eps=1e-6);
    ~ChainIkSolverPos_NR();

    virtual int CartToJnt(const JntArray& q_init, const Frame& p_in, JntArray& q_out);
};


%feature("director") ChainIkSolverPos_NR_JL;
class ChainIkSolverPos_NR_JL : public ChainIkSolverPos
{
public:
    ChainIkSolverPos_NR_JL(const Chain& chain,const JntArray& q_min, const JntArray& q_max, ChainFkSolverPos& fksolver,ChainIkSolverVel& iksolver,unsigned int maxiter=100,double eps=1e-6);
    ~ChainIkSolverPos_NR_JL();

    virtual int CartToJnt(const JntArray& q_init, const Frame& p_in, JntArray& q_out);
};


%feature("director") ChainIkSolverPos_LMA;
class ChainIkSolverPos_LMA : public ChainIkSolverPos
{
public:

    ChainIkSolverPos_LMA(
    		const KDL::Chain& _chain,
    		const Eigen::Matrix<double,6,1>& _L,
    		double _eps=1E-5,
    		int _maxiter=500,
    		double _eps_joints=1E-15
    );

    ChainIkSolverPos_LMA(
    		const KDL::Chain& _chain,
    		double _eps=1E-5,
    		int _maxiter=500,
    		double _eps_joints=1E-15
    );


    virtual int CartToJnt(const KDL::JntArray& q_init, const KDL::Frame& T_base_goal, KDL::JntArray& q_out);
    virtual ~ChainIkSolverPos_LMA();

/*	only for internal use
    void compute_fwdpos(const VectorXq& q);
    void compute_jacobian(const VectorXq& q);
    void display_jac(const KDL::JntArray& jval);
*/

public:

    int lastNrOfIter;
    double lastDifference;
    double lastTransDiff;
    double lastRotDiff;

    KDL::Frame T_base_head;
    bool display_information;
/*
    VectorXq lastSV;
    MatrixXq jac;
    VectorXq grad;};
*/
};

%feature("director") ChainIkSolverVel_pinv_givens;
class ChainIkSolverVel_pinv_givens : public ChainIkSolverVel
{
public:

    explicit ChainIkSolverVel_pinv_givens(const Chain& chain);
    ~ChainIkSolverVel_pinv_givens();

    virtual int CartToJnt(const JntArray& q_in, const Twist& v_in, JntArray& qdot_out);
    virtual int CartToJnt(const JntArray& q_init, const FrameVel& v_in, JntArrayVel& q_out);

};

///////////////////////////////////////////////////////////////////////////////
// Tree

//Forward declaration
class TreeElement;
typedef std::map<std::string,TreeElement> SegmentMap;

class TreeElement
{
public:
    Segment segment;
    unsigned int q_nr;
    SegmentMap::const_iterator  parent;
    std::vector<SegmentMap::const_iterator > children;

    TreeElement(const Segment& segment_in,const SegmentMap::const_iterator& parent_in,unsigned int q_nr_in);
    static TreeElement Root(const std::string& root_name);
};

class Tree
{
public:
    explicit Tree(const std::string& root_name="root");
    Tree(const Tree& in);
    Tree& operator= (const Tree& arg);

    bool addSegment(const Segment& segment, const std::string& hook_name);
    bool addChain(const Chain& chain, const std::string& hook_name);
    bool addTree(const Tree& tree, const std::string& hook_name);

    unsigned int getNrOfJoints()const;
    unsigned int getNrOfSegments()const;

    SegmentMap::const_iterator getSegment(const std::string& segment_name)const;
    SegmentMap::const_iterator getRootSegment()const;

    bool getChain(const std::string& chain_root, const std::string& chain_tip, Chain& chain)const;

    const SegmentMap& getSegments()const;

    virtual ~Tree();
};

// Forward definition
class TreeFkSolverPos
{
public:

    virtual int JntToCart(const JntArray& q_in, Frame& p_out, std::string segmentName)=0;
    virtual ~TreeFkSolverPos(){};
};

%feature("director") TreeFkSolverPos_recursive;
class TreeFkSolverPos_recursive : public TreeFkSolverPos
{
public:
    TreeFkSolverPos_recursive(const Tree& tree);
    ~TreeFkSolverPos_recursive();

    virtual int JntToCart(const JntArray& q_in, Frame& p_out, std::string segmentName);
};

// inverser kinematic

typedef std::map<std::string, Twist>    Twists;
typedef std::map<std::string, Jacobian> Jacobians;
typedef std::map<std::string, Frame>    Frames;

class TreeIkSolverPos
{
public:
    virtual double CartToJnt(const JntArray& q_init, const Frames& p_in,JntArray& q_out)=0;
    virtual ~TreeIkSolverPos() ;
};

class TreeIkSolverVel
{
public:
    virtual double CartToJnt(const JntArray& q_in, const Twists& v_in, JntArray& qdot_out)=0;
    virtual ~TreeIkSolverVel();
};

%feature("director") TreeIkSolverPos_NR_JL;
class TreeIkSolverPos_NR_JL: public TreeIkSolverPos
{
public:
    TreeIkSolverPos_NR_JL(const Tree& tree, const std::vector<std::string>& endpoints, const JntArray& q_min, const JntArray& q_max, TreeFkSolverPos& fksolver,TreeIkSolverVel& iksolver,unsigned int maxiter=100,double eps=1e-6);
    ~TreeIkSolverPos_NR_JL();

    virtual double CartToJnt(const JntArray& q_init, const Frames& p_in, JntArray& q_out);
};

%feature("director") TreeIkSolverPos_Online;
class TreeIkSolverPos_Online: public TreeIkSolverPos
{
public:
    TreeIkSolverPos_Online(const double& nr_of_jnts,
                           const std::vector<std::string>& endpoints,
                           const JntArray& q_min,
                           const JntArray& q_max,
                           const JntArray& q_dot_max,
                           const double x_dot_trans_max,
                           const double x_dot_rot_max,
                           TreeFkSolverPos& fksolver,
                           TreeIkSolverVel& iksolver);
    ~TreeIkSolverPos_Online();

    virtual double CartToJnt(const JntArray& q_in, const Frames& p_in, JntArray& q_out);
};

%feature("director") TreeIkSolverVel_wdls;
class TreeIkSolverVel_wdls: public TreeIkSolverVel
{
public:
    TreeIkSolverVel_wdls(const Tree& tree, const std::vector<std::string>& endpoints);
    virtual ~TreeIkSolverVel_wdls();

    virtual double CartToJnt(const JntArray& q_in, const Twists& v_in, JntArray& qdot_out);

/*
    void setWeightJS(const MatrixXd& Mq);
    const MatrixXd& getWeightJS() const;

    void setWeightTS(const MatrixXd& Mx);
    const MatrixXd& getWeightTS() const;
*/

    void setLambda(const double& lambda);
    double getLambda () const {return lambda;}
};

};
