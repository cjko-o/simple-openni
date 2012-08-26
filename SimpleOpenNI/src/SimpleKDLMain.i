# -----------------------------------------------------------------------------
# SimpleKDLMain
# -----------------------------------------------------------------------------
# Processing Wrapper for the KDL - Kinematic Dynamics Library
# prog:  Max Rheiner / Interaction Design / zhdk / http://iad.zhdk.ch/
# -----------------------------------------------------------------------------

%module(directors="1") SimpleKDLMain

%{
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
# stl

%include "std_vector.i"
%include "std_string.i"
%include "std_map.i"

%{
#include <RayIntersection.h>
%}

# ----------------------------------------------------------------------------
# rayIntersection

bool triangleIntersection(float p[],
                          float dir[],
                          float vec0[],
                          float vec1[],
                          float vec2[],
                          float hit[]);

int sphereIntersection(float p[],
                       float dir[],
                       float sphereCenter[],
                       float sphereRadius,
                       float hit1[],float hit2[],
                       float hit1Normal[]=NULL,float hit2Normal[]=NULL);

bool planeIntersection(float p[],
                       float dir[],
                       float planePos[],
                       float planeDir[],
                       float hit[]);

bool planeIntersection(float p[],
                       float dir[],
                       float planeP1[],
                       float planeP2[],
                       float planeP3[],
                       float hit[]);

int boxIntersection(float p[],
                    float dir[],
                    float boxCenter[],
                    float boxWidth,
                    float boxHeigth,
                    float boxDepth,
                    float hit1[],float hit2[],
                    float hit1Normal[],float hit2Normal[]);

void getXFormMat(float origCenter[],
                 float origX[],
                 float origY[],
                 float origZ[],
                 float newCenter[],
                 float newX[],
                 float newY[],
                 float newrZ[],
                 float xformMat[]);

# ----------------------------------------------------------------------------
# KDL

%include "SimpleKDLBase.i"
