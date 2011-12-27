/* ----------------------------------------------------------------------------
 * SimpleOpenNI
 * ----------------------------------------------------------------------------
 * Copyright (C) 2011 Max Rheiner / Interaction Design Zhdk
 *
 * This file is part of SimpleOpenNI.
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
 * along with SimpleOpenNI.  If not, see <http://www.gnu.org/licenses/>.
 * ----------------------------------------------------------------------------
 */

/*
The original source can be found at:
http://groups.google.com/group/openni-dev/browse_frm/thread/4ff09e556fddf228/81cd236ab0ac5c32?lnk=gst&q=motor#
*/

// OpenNI includes
#include <XnUSB.h>

// Standard includes
#include <cstdio>
#include <time.h>

class KinectMotors
{
public:
    enum { MaxDevs = 16 };

public:
    KinectMotors();
    virtual ~KinectMotors();

    bool open();
    void close();
    bool move(int angle,int devIndex = -1);

private:
    XN_USB_DEV_HANDLE   _devs[MaxDevs];
    XnUInt32            _num;
    bool                _open;
};
