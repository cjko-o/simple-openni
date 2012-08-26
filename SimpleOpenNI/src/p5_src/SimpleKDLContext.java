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
  

public class SimpleKDLContext
{
	static 
        {   // load the nativ shared lib
            String sysStr = System.getProperty("os.name").toLowerCase();
            String libName = "SimpleKDL";
            String archStr = System.getProperty("os.arch").toLowerCase();

            // check which system + architecture
            if(sysStr.indexOf("win") >= 0)
            {   // windows
                if(archStr.indexOf("86") >= 0)
                    // 32bit
                    libName += "32";
                else if(archStr.indexOf("64") >= 0)
                    libName += "64";
             }
            else if(sysStr.indexOf("nix") >= 0 || sysStr.indexOf("linux") >=  0 )
            {   // unix
                if(archStr.indexOf("86") >= 0)
                    // 32bit
                    libName += "32";
                else if(archStr.indexOf("64") >= 0)
                {
                    System.out.println("----");
                    libName += "64";
                }
            }
            else if(sysStr.indexOf("mac") >= 0)
            {     // mac
            }

            try{
              //System.out.println("-- " + System.getProperty("user.dir"));
              System.loadLibrary(libName);
            }
            catch(UnsatisfiedLinkError e)
            {
              System.out.println("Can't load SimpleKDL library (" +  libName  + ") : " + e);
            }

	}

    public static void start()
	{

	}


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
  mat.transpose();

  return mat;
}

}
