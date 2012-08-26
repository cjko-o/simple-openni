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
  

public class Utils
{

    // convert the frame into a processing matrix
    public static PMatrix3D getMatrix(SimpleKDL.Frame F)
    {
      float[] tf=new float[16];
      int i;
      int j;
      for (i=0;i<3;i++)
      {
        for (j=0;j<3;j++)
          tf[i+j*4]= (float) F.getM().get(i, j);

        tf[i+3*4] = (float) F.getP().get(i);
      }
      for (j=0;j<3;j++)
        tf[3+j*4] = 0.0f;

      tf[15] = 1;

      PMatrix3D mat = new PMatrix3D();
      mat.set(tf);
      // left hand -> right hand
      // https://forum.processing.org/topic/understanding-pmatrix3d#25080000001370087
      mat.transpose();

      return mat;
    }

    public static PMatrix3D getXFormMat(PVector origCenter,
                                        PVector origX,
                                        PVector origY,
                                        PVector origZ,
                                        PVector newCenter,
                                        PVector newX,
                                        PVector newY,
                                        PVector newZ)
    {
        float[] tf=new float[16];

        SimpleKDLMain.getXFormMat(origCenter.array(),
                                  origX.array(),
                                  origY.array(),
                                  origZ.array(),
                                  newCenter.array(),
                                  newX.array(),
                                  newY.array(),
                                  newZ.array(),
                                  tf);

        PMatrix3D xform = new PMatrix3D();
        xform.set(tf);

        return xform;
    }


    public static Frame getFrame(PVector origCenter,
                                 PVector origX,
                                 PVector origY,
                                 PVector origZ,
                                 PVector newCenter,
                                 PVector newX,
                                 PVector newY,
                                 PVector newZ)
    {
        float[] tf=new float[16];

        SimpleKDLMain.getXFormMat(origCenter.array(),
                                  origX.array(),
                                  origY.array(),
                                  origZ.array(),
                                  newCenter.array(),
                                  newX.array(),
                                  newY.array(),
                                  newZ.array(),
                                  tf);

        Rotation rot = new Rotation(tf[0],tf[4],tf[8],
                                    tf[1],tf[5],tf[9],
                                    tf[2],tf[6],tf[10]);

        return new Frame(rot,
                         new Vector(tf[12],tf[13],tf[14]));
    }

}
