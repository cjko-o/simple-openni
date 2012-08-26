/* ----------------------------------------------------------------------------
 * SimpleKDL
 * ----------------------------------------------------------------------------
 * Copyright (C) 2012 Max Rheiner / Interaction Design Zhdk
 *
 * This file is part of SimpleOpenNI.
 *
 * SimpleOpenNI is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 2 of the License, or
 * (at your option) any later version (subject to the "Classpath" exception
 * as provided in the LICENSE.txt file that accompanied this code).
 *
 * SimpleKDL is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with SimpleKDL.  If not, see <http://www.gnu.org/licenses/>.
 * ----------------------------------------------------------------------------
 */
 
package SimpleKDL;

import processing.core.*;
import java.lang.reflect.Method;
  

public class RayIntersection
{
    ///////////////////////////////////////////////////////////////////////////
    // intersection
    public static boolean triangle(PVector p, PVector dir,
                                   PVector vec0,PVector vec1, PVector vec2,
                                   PVector hit)
    {
      float[] hitRet= new float[3];
      if(SimpleKDLMain.triangleIntersection(p.array(), dir.array(), vec0.array(), vec1.array(), vec2.array(), hitRet))
      {
            hit.set(hitRet);
            return true;
      }
      else
            return false;
    }

    public static int sphere(PVector p, PVector dir,
                             PVector sphereCenter,float sphereRadius,
                             PVector hit1,PVector hit2)
    {
      float[] hit1Ret= new float[3];
      float[] hit2Ret= new float[3];

      int ret = SimpleKDLMain.sphereIntersection(p.array(), dir.array(),
                                      sphereCenter.array(), sphereRadius,
                                      hit1Ret, hit2Ret);

      if(ret > 0)
      {
            hit1.set(hit1Ret);

            if(ret > 1)
              hit2.set(hit2Ret);
      }
      return ret;
    }

    public static int sphere(PVector p, PVector dir,
                             PVector sphereCenter,float sphereRadius,
                             PVector hit1,PVector hit2,
                             PVector hit1Normal,PVector hit2Normal)
    {
        float[] hit1Ret= new float[3];
        float[] hit2Ret= new float[3];

        float[] hit1NormalRet= new float[3];
        float[] hit2NormalRet= new float[3];

        int ret = SimpleKDLMain.sphereIntersection(p.array(), dir.array(),
                                                  sphereCenter.array(), sphereRadius,
                                                  hit1Ret, hit2Ret,
                                                  hit1NormalRet, hit2NormalRet);

        if(ret > 0)
        {
            hit1.set(hit1Ret);
            hit1Normal.set(hit1NormalRet);

            if(ret > 1)
            {
              hit2.set(hit2Ret);
              hit2Normal.set(hit2NormalRet);
            }
        }
        return ret;
    }

    public static boolean plane(PVector p,
                                PVector dir,
                                PVector planePos,
                                PVector planeDir,
                                PVector hit)
    {
        float[] hitRet= new float[3];

        if(SimpleKDLMain.planeIntersection(p.array(), dir.array(),
                             planePos.array(), planeDir.array(),
                             hitRet))
        {
            hit.set(hitRet);
            return true;
        }
        else
            return false;
    }

    public static boolean plane(PVector p,
                                PVector dir,
                                PVector planeP1,
                                PVector planeP2,
                                PVector planeP3,
                                PVector hit)
    {
        float[] hitRet= new float[3];

        if(SimpleKDLMain.planeIntersection(p.array(), dir.array(),
                             planeP1.array(), planeP2.array(),planeP3.array(),
                             hitRet))
        {
            hit.set(hitRet);
            return true;
        }
        else
            return false;
    }

    public static int box(PVector p,
                          PVector dir,
                          PVector boxCenter,
                          float boxWidth,
                          float boxHeigth,
                          float boxDepth,
                          PVector hit1,PVector hit2,
                          PVector hit1Normal,PVector hit2Normal)
    {
        float[] hit1Ret= new float[3];
        float[] hit2Ret= new float[3];

        float[] hit1NormalRet= new float[3];
        float[] hit2NormalRet= new float[3];

        int ret = SimpleKDLMain.boxIntersection(p.array(), dir.array(),
                                                boxCenter.array(), boxWidth,boxHeigth,boxDepth,
                                                hit1Ret, hit2Ret,
                                                hit1NormalRet, hit2NormalRet);

        if(ret > 0)
        {
            hit1.set(hit1Ret);
            hit1Normal.set(hit1NormalRet);

            if(ret > 1)
            {
              hit2.set(hit2Ret);
              hit2Normal.set(hit2NormalRet);
            }
        }
        return ret;
    }


}
