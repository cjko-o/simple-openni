/* ----------------------------------------------------------------------------
 * SimpleKDL
 * ----------------------------------------------------------------------------
 * Copyright (C) 2011 Max Rheiner / Interaction Design Zhdk
 *
 * This file is part of SimpleKDL.
 *
 * SimpleOpenNI is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 2 of the License, or
 * (at your option) any later version (subject to the "Classpath" exception
 * as provided in the LICENSE.txt file that accompanied this code).
 *
 * SimpleOpenNI is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with SimpleKDL.  If not, see <http://www.gnu.org/licenses/>.
 * ----------------------------------------------------------------------------
 */

#ifndef _RAYINTERSECTION_H_
#define _RAYINTERSECTION_H_

#include <vector>
#include <iostream>

// boost
#include <boost/thread.hpp>
#include <boost/thread/mutex.hpp>
#include <boost/thread/locks.hpp>
#include <boost/shared_ptr.hpp>
#include <boost/cstdint.hpp>

// eigen
#include <Eigen/Geometry>


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



#endif // _RAYINTERSECTION_H_
