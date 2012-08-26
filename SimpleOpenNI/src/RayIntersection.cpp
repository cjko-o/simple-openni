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

#include "RayIntersection.h"


///////////////////////////////////////////////////////////////////////////////
// helper function


Eigen::Vector3f getNormal(const Eigen::Vector3f& p1,
                          const Eigen::Vector3f& p2,
                          const Eigen::Vector3f& p3)
{
    Eigen::Vector3f u = p2 - p1;
    Eigen::Vector3f v = p3 - p1;

    return v.cross(u).normalized();
}

// this code is based on the paper from Tomas Möller and Ben Trumbore
// 'Fast, minimum storage ray-triangle intersection.'
// http://www.graphics.cornell.edu/pubs/1997/MT97.html

bool triangleIntersection(const Eigen::Vector3f& p,
                          const Eigen::Vector3f& d,
                          const Eigen::Vector3f& v0,
                          const Eigen::Vector3f& v1,
                          const Eigen::Vector3f& v2,
                          Eigen::Vector3f* hit)
{
    float a,f,u,v;
    Eigen::Vector3f e1 = v1 - v0;
    Eigen::Vector3f e2 = v2 - v0;

    Eigen::Vector3f h = d.cross(e2);
    a = e1.dot(h);

    if (a > -0.00001f && a < 0.00001f)
        return false;

    f = 1.0f / a;
    Eigen::Vector3f s = p - v0;
    u = f * s.dot(h);

    if (u < 0.0f || u > 1.0f)
        return false;

    Eigen::Vector3f q = s.cross(e1);
    v = f * d.dot(q);

    if (v < 0.0f || u + v > 1.0f)
        return false;

    float t = f * e2.dot(q);

    if (t > 0.00001f) // ray intersection
    {
        *hit = p + (d * t);
        return true;
    }
    else
        return false;

}

// http://www.openprocessing.org/sketch/45539

int sphereIntersection(const Eigen::Vector3f& rayP,
                       const Eigen::Vector3f& dir,
                       const Eigen::Vector3f& sphereCenter,float sphereRadius,
                       Eigen::Vector3f* hit1, Eigen::Vector3f* hit2,
                       Eigen::Vector3f* hit1Normal=NULL, Eigen::Vector3f* hit2Normal=NULL)
{
  Eigen::Vector3f e = dir.normalized();
  Eigen::Vector3f h = sphereCenter - rayP;
  float lf = e.dot(h);                      // lf=e.h
  float s = pow(sphereRadius,2) - h.dot(h) + pow(lf,2);   // s=r^2-h^2+lf^2
  if(s < 0.0)
      return 0;                    // no intersection points ?
  s = sqrt(s);                              // s=sqrt(r^2-h^2+lf^2)

  int result = 0;
  if(lf < s)                               // S1 behind A ?
  {
      if (lf+s >= 0)                          // S2 before A ?}
      {
        s = -s;                               // swap S1 <-> S2}
        result = 1;                           // one intersection point
      }
  }
  else
      result = 2;                          // 2 intersection points

  *hit1 = e * (lf-s) + rayP;
  *hit2 = e * (lf+s) + rayP;

  if(hit1Normal)
  {
    *hit1Normal = *hit1 - sphereCenter;
      (*hit1Normal).normalize();
  }

  if(hit2Normal)
  {
    *hit2Normal = *hit2 - sphereCenter;
      (*hit2Normal).normalize();
  }

  return result;
}

/*
// http://www.lighthouse3d.com/tutorials/maths/ray-sphere-intersection/
int raySphereIntersection(const Eigen::Vector3f& origin,
                          const Eigen::Vector3f& dir,
                          const Eigen::Vector3f& sphereCenter,
                          float sphereRadius,
                          Eigen::Vector3f* hit1,
                          Eigen::Vector3f* hit2,)
{
    Eigen::Vector3f vpc = sphereCenter - rayP;

    if ((vpc . dir) < 0) // when the sphere is behind the origin p
                        // note that this case may be dismissed if it is
                        // considered that p is outside the sphere
            if (fabs(vpc) > r)

                       // there is no intersection

        else if (|vpc| == r)

            intersection = p

        else // occurs when p is inside the sphere

            pc = projection of c on the line
                    // distance from pc to i1
            dist = sqrt(radius^2 - |pc - c|^2)
            di1 = dist - |pc - p|
            intersection = p + d * di1

    else // center of sphere projects on the ray

        pc = projection of c on the line
        if (| c - pc | > r)

            // there is no intersection

        else
                    // distance from pc to i1
            dist = sqrt(radius^2 - |pc - c|^2)

                if (|vpc| > r) // origin is outside sphere

                di1 = |pc - p| - dist

            else // origin is inside sphere

                di1 = |pc - p| + dist

            intersection = p + d * di1


    return false;
}
*/

bool triangleIntersection(float p[],
                          float dir[],
                          float vec0[],
                          float vec1[],
                          float vec2[],
                          float hit[])
{
    Eigen::Vector3f hitVec;

    if(triangleIntersection(Eigen::Vector3f(p),
                            Eigen::Vector3f(dir),
                            Eigen::Vector3f(vec0),
                            Eigen::Vector3f(vec1),
                            Eigen::Vector3f(vec2),
                            &hitVec))
    {
        hit[0] = hitVec.x();
        hit[1] = hitVec.y();
        hit[2] = hitVec.z();
        //memcpy(hit,hitVec.data(),sizeof(float) * 3);
        return true;
    }

    return false;
}


int sphereIntersection(float p[],
                       float dir[],
                       float sphereCenter[],
                       float sphereRadius,
                       float hit1[],float hit2[],
                       float hit1Normal[],float hit2Normal[])
{
    Eigen::Vector3f hitVec1;
    Eigen::Vector3f hitVec2;
    Eigen::Vector3f hitVec1Normal;
    Eigen::Vector3f hitVec2Normal;

    int ret = sphereIntersection(Eigen::Vector3f(p),
                                 Eigen::Vector3f(dir),
                                 Eigen::Vector3f(sphereCenter),sphereRadius,
                                 &hitVec1,&hitVec2,
                                 &hitVec1Normal,&hitVec2Normal);

    if(ret > 0)
    {
        hit1[0] = hitVec1.x();
        hit1[1] = hitVec1.y();
        hit1[2] = hitVec1.z();

        if(hit1Normal)
        {
            hit1Normal[0] = hitVec1Normal.x();
            hit1Normal[1] = hitVec1Normal.y();
            hit1Normal[2] = hitVec1Normal.z();
        }

        if(ret > 1)
        {
            hit2[0] = hitVec2.x();
            hit2[1] = hitVec2.y();
            hit2[2] = hitVec2.z();

            if(hit2Normal)
            {
                hit2Normal[0] = hitVec2Normal.x();
                hit2Normal[1] = hitVec2Normal.y();
                hit2Normal[2] = hitVec2Normal.z();
            }          }
    }

    return ret;
}

///////////////////////////////////////////////////////////////////////////////
// plane


bool planeIntersection(float rayP[],
                       float rayDir[],
                       float planePos[],
                       float planeDir[],
                       float hit[])
{
    Eigen::Vector3f planeP1(planePos);
    Eigen::Vector3f dir(planeDir);
    dir.normalize();

    Eigen::Vector3f difNorm;
    if(dir.x() == 1.0f)
        difNorm = Eigen::Vector3f(0,1,0);
    else if(dir.y() == 1.0f)
        difNorm = Eigen::Vector3f(1,0,0);
    else if(dir.z() == 1.0f)
        difNorm = Eigen::Vector3f(1,0,0);
    else
    {
        difNorm = Eigen::Vector3f(1,1,1);
        difNorm.normalize();
    }

    Eigen::Vector3f u = dir.cross(difNorm);
    u.normalize();
    Eigen::Vector3f v = dir.cross(u);
    v.normalize();
    Eigen::Vector3f planeP2 = planeP1 + u;
    Eigen::Vector3f planeP3 = planeP1 + v;

    return planeIntersection(rayP,
                             rayDir,
                             planeP1.data(),
                             planeP2.data(),
                             planeP3.data(),
                             hit);
}


bool planeIntersection(float p[],
                       float dir[],
                       float planeP1[],
                       float planeP2[],
                       float planeP3[],
                       float hit[])
{
    Eigen::Vector3f r1(p);
    Eigen::Vector3f r2 = r1 + Eigen::Vector3f(dir);

    Eigen::Vector3f p1(planeP1);
    Eigen::Vector3f p2(planeP2);
    Eigen::Vector3f p3(planeP3);

    Eigen::Vector3f v1 = Eigen::Vector3f(p2) - Eigen::Vector3f(p1);
    Eigen::Vector3f v2 = Eigen::Vector3f(p3) - Eigen::Vector3f(p1);
    Eigen::Vector3f v3 = v1.cross(v2);

    Eigen::Vector3f vRotRay1 = Eigen::Vector3f( v1.dot(r1 - p1 ), v2.dot( r1 - p1 ), v3.dot( r1 - p1 ) );
    Eigen::Vector3f vRotRay2 = Eigen::Vector3f( v1.dot(r2 - p1 ), v2.dot( r2 - p1 ), v3.dot( r2 - p1 ) );
    // Return now if ray will never intersect plane (they're parallel)
    if (vRotRay1.z() == vRotRay2.z())
      return false;

    // Find 2D plane coordinates (fX, fY) that the ray interesects with
    float fPercent = vRotRay1.z() / (vRotRay2.z() - vRotRay1.z());
    /* 2d
    Eigen::Vector3f vIntersect2d = vRotRay1 + ( (vRotRay1 - vRotRay2) * fPercent);
    hitRes2d.x = vIntersect2d.x;
    hitRes2d.y = vIntersect2d.y;
    */

    Eigen::Vector3f hitP(r1 + (r1 - r2) * fPercent);
    hit[0] = hitP.x();
    hit[1] = hitP.y();
    hit[2] = hitP.z();

    return true;
}

bool quadIntersection(const Eigen::Vector3f& p,
                      const Eigen::Vector3f& d,
                      const Eigen::Vector3f& p1,
                      const Eigen::Vector3f& p2,
                      const Eigen::Vector3f& p3,
                      const Eigen::Vector3f& p4,
                      Eigen::Vector3f* hit)
{

    if( triangleIntersection(p,d,
                             p1,p2,p3,
                             hit))
        return true;
    else if( triangleIntersection(p,d,
                                  p3,p4,p1,
                                  hit))
        return true;

    return false;
}


int boxIntersection(const Eigen::Vector3f& p,
                    const Eigen::Vector3f& dir,
                    const Eigen::Vector3f& boxCenter,
                    float boxWidth,
                    float boxHeigth,
                    float boxDepth,
                    Eigen::Vector3f* hit1,Eigen::Vector3f* hit2,
                    Eigen::Vector3f* hit1Normal,Eigen::Vector3f* hit2Normal)
{
    float x2 = boxWidth *.5f;
    float y2 = boxHeigth *.5f;
    float z2 = boxDepth *.5f;

    Eigen::Vector3f p1(-x2,y2,-z2);
    Eigen::Vector3f p2(x2,y2,-z2);
    Eigen::Vector3f p3(x2,y2,z2);
    Eigen::Vector3f p4(-x2,y2,z2);

    Eigen::Vector3f p5(-x2,-y2,-z2);
    Eigen::Vector3f p6(x2,-y2,-z2);
    Eigen::Vector3f p7(x2,-y2,z2);
    Eigen::Vector3f p8(-x2,-y2,z2);

    p1 += boxCenter;
    p2 += boxCenter;
    p3 += boxCenter;
    p4 += boxCenter;
    p5 += boxCenter;
    p6 += boxCenter;
    p7 += boxCenter;
    p8 += boxCenter;

    Eigen::Vector3f hit[2];
    Eigen::Vector3f hitNormal[2];
    int hitCount = 0;

    // check top
    if(quadIntersection(p,
                        dir,
                        p1,p2,p3,p4,
                        &hit[hitCount]))
    {
        hitNormal[hitCount] = getNormal(p1,p2,p3);
        hitCount++;
    }

    // check bottom
    if(quadIntersection(p,
                        dir,
                        p5,p8,p7,p6,
                        &hit[hitCount]))
    {
        hitNormal[hitCount] = getNormal(p5,p8,p7);
        hitCount++;
    }

    // check front
    if(hitCount < 2 && quadIntersection(p,
                                        dir,
                                        p4,p3,p7,p8,
                                        &hit[hitCount]))
    {
        hitNormal[hitCount] = getNormal(p4,p3,p7);
        hitCount++;
    }

    // check back
    if(hitCount < 2 && quadIntersection(p,
                                        dir,
                                        p1,p5,p6,p2,
                                        &hit[hitCount]))
    {
        hitNormal[hitCount] = getNormal(p1,p5,p6);
        hitCount++;
    }

    // check left
    if(hitCount < 2 && quadIntersection(p,
                                        dir,
                                        p1,p4,p8,p5,
                                        &hit[hitCount]))
    {
        hitNormal[hitCount] = getNormal(p1,p4,p8);
        hitCount++;
    }

    // check right
    if(hitCount < 2 && quadIntersection(p,
                                        dir,
                                        p2,p6,p7,p3,
                                        &hit[hitCount]))
    {
        hitNormal[hitCount] = getNormal(p2,p6,p7);
        hitCount++;
    }

    if(hitCount > 0)
    {
        if(hitCount > 1)
        {
            if((p - hit[0]).norm() < (p - hit[1]).norm())
            {
                *hit1 = hit[0];
                *hit2 = hit[1];

                *hit1Normal = hitNormal[0];
                *hit2Normal = hitNormal[1];
            }
            else
            {
                *hit1 = hit[1];
                *hit2 = hit[0];

                *hit1Normal = hitNormal[1];
                *hit2Normal = hitNormal[0];
            }

        }
        else
        {
            *hit1 = hit[0];
            *hit1Normal = hitNormal[0];
        }
    }

    return hitCount;
}


int boxIntersection(float p[],
                    float dir[],
                    float boxCenter[],
                    float boxWidth,
                    float boxHeigth,
                    float boxDepth,
                    float hit1[],float hit2[],
                    float hit1Normal[],float hit2Normal[])
{
    Eigen::Vector3f hitRet1,hitRet2;
    Eigen::Vector3f hitRet1Normal,hitRet2Normal;
    int ret = boxIntersection(Eigen::Vector3f(p),Eigen::Vector3f(dir),
                              Eigen::Vector3f(boxCenter),
                              boxWidth,boxHeigth,boxDepth,
                              &hitRet1,&hitRet2,
                              &hitRet1Normal,&hitRet2Normal);
    if(ret > 0)
    {
        hit1[0] = hitRet1.x();
        hit1[1] = hitRet1.y();
        hit1[2] = hitRet1.z();

        hit1Normal[0] = hitRet1Normal.x();
        hit1Normal[1] = hitRet1Normal.y();
        hit1Normal[2] = hitRet1Normal.z();

        if(ret > 1)
        {
            hit2[0] = hitRet2.x();
            hit2[1] = hitRet2.y();
            hit2[2] = hitRet2.z();

            hit2Normal[0] = hitRet2Normal.x();
            hit2Normal[1] = hitRet2Normal.y();
            hit2Normal[2] = hitRet2Normal.z();
        }
    }

    return ret;
}

void getXFormMat(float origCenter[],
                 float origX[],
                 float origY[],
                 float origZ[],
                 float newCenter[],
                 float newX[],
                 float newY[],
                 float newZ[],
                 float xformMat[])
{
    // calculate the transformation matrix
    Eigen::Matrix<float,3,4> start,end;

    start.col(0) = Eigen::Vector3f(origCenter);
    start.col(1) = Eigen::Vector3f(origX);
    start.col(2) = Eigen::Vector3f(origY);
    start.col(3) = Eigen::Vector3f(origZ);

    end.col(0) = Eigen::Vector3f(newCenter);
    end.col(1) = Eigen::Vector3f(newX);
    end.col(2) = Eigen::Vector3f(newY);
    end.col(3) = Eigen::Vector3f(newZ);

    Eigen::Transform<float,3,Eigen::Affine> xform;

    xform = Eigen::umeyama(start,end,true);

    memcpy(xformMat,xform.data(),sizeof(float)*16);
}
