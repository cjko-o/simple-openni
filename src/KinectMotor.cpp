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

#include <iostream>

#include "KinectMotor.h"

KinectMotors::KinectMotors():
    _open(false)
{}

KinectMotors::~KinectMotors()
{
    close();
}

bool KinectMotors::open()
{
    if(_open)
        return true;

    const XnUSBConnectionString *paths;
    XnUInt32 count;
    XnStatus res;

//    std::cout << "xnUSBInit"  << std::endl;

    // Init OpenNI USB
    res = xnUSBInit();
    if(res != XN_STATUS_OK)
    {
//        xnPrintError(res, "xnUSBInit failed");
        return false;
    }

//    std::cout << "xnUSBEnumerateDevices"  << std::endl;

    // Open all "Kinect motor" USB devices
    res = xnUSBEnumerateDevices(0x045E /* VendorID */, 0x02B0 /*ProductID*/, &paths, &count);
    if(res != XN_STATUS_OK)
    {
 //       xnPrintError(res, "xnUSBEnumerateDevices failed");
        return false;
    }

    // Open devices
    for(XnUInt32 index = 0; index < count; index++)
    {
        res = xnUSBOpenDeviceByPath(paths[index], &_devs[index]);
        std::cout << "count = " << index << " : "<< paths[index]  << std::endl;
        if (res != XN_STATUS_OK)
        {
//            xnPrintError(res, "xnUSBOpenDeviceByPath failed");
            return false;
        }
    }

    _num = count;
    XnUChar buf[1]; // output buffer

    // Init motors
    for (XnUInt32 index = 0; index < _num; ++index)
    {
        res = xnUSBSendControl(_devs[index], (XnUSBControlType) 0xc0, 0x10, 0x00, 0x00, buf, sizeof(buf), 0);
        if (res != XN_STATUS_OK)
        {
  //          xnPrintError(res, "xnUSBSendControl failed");
            close();
            return false;
        }

        res = xnUSBSendControl(_devs[index], XN_USB_CONTROL_TYPE_VENDOR, 0x06, 0x01, 0x00, NULL, 0, 0);
        if (res != XN_STATUS_OK)
        {
//            xnPrintError(res, "xnUSBSendControl failed");
            close();
            return false;
        }
    }
    _open = true;

    return true;
}

void KinectMotors::close()
{
    if(!_open)
        return;

    for(XnUInt32 index = 0; index < _num; ++index)
        xnUSBCloseDevice(_devs[index]);
    _open = false;
}


bool KinectMotors::move(int angle,int devIndex)
{
    XnStatus res;

    // Send move control requests
    if(devIndex < 0)
    {
        for(XnUInt32 index = 0; index < _num; ++index)
        {
            res = xnUSBSendControl(_devs[index], XN_USB_CONTROL_TYPE_VENDOR, 0x31, angle, 0x00, NULL, 0, 0);
            if (res != XN_STATUS_OK)
            {
                xnPrintError(res, "xnUSBSendControl failed");
                return false;
            }
        }
    }
    else
    {
        if(devIndex < MaxDevs)
        {
            res = xnUSBSendControl(_devs[devIndex], XN_USB_CONTROL_TYPE_VENDOR, 0x31, angle, 0x00, NULL, 0, 0);
            if (res != XN_STATUS_OK)
            {
                xnPrintError(res, "xnUSBSendControl failed");
                return false;
            }
        }
        else
            return false;
    }
    return true;
}
