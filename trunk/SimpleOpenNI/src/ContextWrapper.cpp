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

#ifdef WIN32
#define _CRT_SECURE_NO_WARNINGS

#define NOMINMAX	// eigen + windows.h will have conflict without this
#endif

#include <cmath>

// opengl extensions
#include <GL/glew.h>

// openni
#include <XnTypes.h>

// eigen
#include <Eigen/Geometry>


#include "ContextWrapper.h"

using namespace sOpenNI;
using namespace xn;

#define		SIMPLEOPENNI_VERSION	21		// 1234 = 12.24

xn::DepthGenerator tempDepth;

XnFloat Colors[][3] =
{
    {0,1,1},
    {0,0,1},
    {0,1,0},
    {1,1,0},
    {1,0,0},
    {1,.5,0},
    {.5,1,0},
    {0,.5,1},
    {.5,0,1},
    {1,1,.5},
    {1,1,1}
};
XnUInt32 nColors = 10;

///////////////////////////////////////////////////////////////////////////////
// eigen defs

typedef Eigen::Hyperplane<float,3> HyperPlane3d;

///////////////////////////////////////////////////////////////////////////////
// ContextWrapper

xn::Context ContextWrapper::_globalContext = NULL;
bool ContextWrapper::_globalContextFlag = false;
int ContextWrapper::_deviceCount=0;
std::vector<class ContextWrapper*> ContextWrapper::_classList;


ContextWrapper::ContextWrapper():
    _pDepthImage(NULL),
    _pIrImage(NULL),
    _pSceneImage(NULL),
    _depthMapRealWorld(NULL),
    _initFlag(false),
    _generatingFlag(false),
    _firstTimeUpdate(true),
    _nodes(Node_None),
    _userWidth(0),
    _userHeight(0),
    _userSceneBufSize(0),
    _depthImageColorMode(DepthImgMode_Default),
    _threadMode(RunMode_Default),
    _threadRun(false),
    _deviceIndex(0)
{
    std::cout << "SimpleOpenNI Version " << (SIMPLEOPENNI_VERSION / 100) << "." <<  (SIMPLEOPENNI_VERSION % 100) << std::endl;

    _depthImageColor[0] = 1.0f;
    _depthImageColor[1] = 1.0f;
    _depthImageColor[2] = 1.0f;

    _depthMapOutputMode.nXRes = XN_VGA_X_RES;
    _depthMapOutputMode.nYRes = XN_VGA_Y_RES;
    _depthMapOutputMode.nFPS = 30;

    _imageMapOutputMode.nXRes = XN_VGA_X_RES;
    _imageMapOutputMode.nYRes = XN_VGA_Y_RES;
    _imageMapOutputMode.nFPS = 30;

    _irMapOutputMode.nXRes = XN_VGA_X_RES;
    _irMapOutputMode.nYRes = XN_VGA_Y_RES;
    _irMapOutputMode.nFPS = 30;

    _sceneMapOutputMode.nXRes = XN_VGA_X_RES;
    _sceneMapOutputMode.nYRes = XN_VGA_Y_RES;
    _sceneMapOutputMode.nFPS = 30;

    // calc gamma map
    for(int i=0; i< (MAX_DEPTH /1); ++i)
    {
        float v = i/(float)(MAX_DEPTH/1);
        v = std::pow(v, 3)* 6;
        _pDepthGamma[i] = v*6*256;
    }

    _depthMapTimeStamp		= 0;
    _depthImageTimeStamp	= 0;
    _depthRealWorldTimeStamp	= 0;

    _imageTimeStamp		= 0;
    _irTimeStamp		= 0;
    _sceneTimeStamp		= 0;
    _userTimeStamp		= 0;
    _gestureTimeStamp           = 0;
    _handsTimeStamp		= 0;

    _updateTimeStamp		= 1;	// set to 1 for the first update
    _updateSubTimeStamp		= 1;
}

ContextWrapper::~ContextWrapper()
{
    close();
}

void ContextWrapper::close()
{
    if(!_initFlag)
        return;

    if(_threadMode == RunMode_MultiThreaded)
    {
        _threadRun = false;
        if(_thread.get() != NULL)
        {
            // wait till thread is done
            _thread->join();

            // delete the thread
            _thread.reset();
        }
    }

    // stop generators
    _globalContext.StopGeneratingAll();

    _initFlag = false;
    _generatingFlag = false;

    if(_pDepthImage)
        free(_pDepthImage);
    if(_pIrImage)
        free(_pIrImage);
    if(_pSceneImage)
        free(_pSceneImage);
    if(_depthMapRealWorld)
        free(_depthMapRealWorld),

    _pDepthImage= NULL;
    _pIrImage	= NULL;
    _pSceneImage= NULL;
    _depthMapRealWorld= NULL;

    _depthMapTimeStamp		= 0;
    _depthImageTimeStamp	= 0;
    _depthRealWorldTimeStamp	= 0;

    _imageTimeStamp		= 0;
    _irTimeStamp		= 0;
    _sceneTimeStamp		= 0;
    _userTimeStamp		= 0;
    _gestureTimeStamp		= 0;
    _handsTimeStamp		= 0;

    _updateTimeStamp		= 1;	// set to 1 for the first update
    _updateSubTimeStamp		= 1;

    // shutdown the context
    _globalContext.Shutdown();

}

int ContextWrapper::version() 
{ 
    return SIMPLEOPENNI_VERSION;
}

void ContextWrapper::logOut(int msgType,const char* msg,...)
{
    char strBuffer[STRING_BUFFER];

    switch(msgType)
    {
    case MsgNode_Error:
        std::cout << "SimpleOpenNI Error: ";
        break;
    case MsgNode_Info:
    default:
        std::cout << "SimpleOpenNI Info: ";
        break;
    };

    va_list args;
    va_start(args, msg);
    //vsprintf_s(_strBuffer,STRING_BUFFER,msg, args);
    vsnprintf(strBuffer,STRING_BUFFER,msg, args);
    va_end(args);
    /*
 va_list vl;
 va_start(vl,amount);
 for(i=0;i<amount;i++)
 {
  val=va_arg(vl,double);
  printf ("\t%.2f",val);
 }
 va_end(vl);
 */

    std::cout << strBuffer << std::endl;
}

bool ContextWrapper::checkLicenses()
{
    XnLicense* 	licenses;
    XnUInt32	count;

    _globalContext.EnumerateLicenses(licenses,count);
    if(count<=0)
    {	// write
        logOut(MsgNode_Error,"ContextWrapper::checkLicenses, there is no valid license, please check your installation !\n");
        return false;
    }

    return true;
}

bool ContextWrapper::init(const char* xmlInitFile,int runMode)
{
    _threadMode = runMode;

    // init the cam with the xml setup file
    xn::EnumerationErrors errors;
    _rc = _globalContext.InitFromXmlFile(xmlInitFile, &errors);
    if (_rc == XN_STATUS_NO_NODE_PRESENT)
        return false;
    else if (_rc != XN_STATUS_OK)
    {
        logOut(MsgNode_Error,"ContextWrapper::init: Can't init %s\n",xmlInitFile);
        return false;
    }

    checkLicenses();

    _initFlag = true;
    return true;
}

bool ContextWrapper::initContext()
{
    if(_globalContextFlag == false)
    {   // create context
        XnStatus rc = _globalContext.Init();
        if(rc == XN_STATUS_NO_NODE_PRESENT)
            // error;
            _globalContextFlag = false;
        else
        {
            _globalContextFlag = true;


            // check the list of all devices
            xn::NodeInfoList list;
            int i=0;

            _deviceCount = 0;

            rc = _globalContext.EnumerateProductionTrees(XN_NODE_TYPE_DEVICE, NULL,list);
            logOut(MsgNode_Info,"Device List:");
            for(xn::NodeInfoList::Iterator iter = list.Begin(); iter != list.End(); ++iter,i++)
            {
                xn::NodeInfo    deviceNodeInfo = *iter;

                logOut(MsgNode_Info,"index=%d\tGetCreationInfo(): %s\tGetInstanceName:%s\tname: %s\tvendor: %s",i,deviceNodeInfo.GetCreationInfo(),
                                                                                              deviceNodeInfo.GetInstanceName(),
                                                                                              deviceNodeInfo.GetDescription().strName,
                                                                                              deviceNodeInfo.GetDescription().strVendor);

                _deviceCount++;
            }




            i = 0;
            rc = _globalContext.EnumerateProductionTrees(XN_NODE_TYPE_DEPTH, NULL,list);
            logOut(MsgNode_Info,"Depth List:");
            for(xn::NodeInfoList::Iterator iter = list.Begin(); iter != list.End(); ++iter,i++)
            {
                xn::NodeInfo    depthInfo = *iter;

                logOut(MsgNode_Info,"index=%d\tGetCreationInfo(): %s\tGetInstanceName:%s\tname: %s\tvendor: %s",i,depthInfo.GetCreationInfo(),
                                                                                              depthInfo.GetInstanceName(),
                                                                                              depthInfo.GetDescription().strName,
                                                                                              depthInfo.GetDescription().strVendor);

            }
            i = 0;
            rc = _globalContext.EnumerateProductionTrees(XN_NODE_TYPE_IMAGE, NULL,list);
            logOut(MsgNode_Info,"Image List:");
            for(xn::NodeInfoList::Iterator iter = list.Begin(); iter != list.End(); ++iter,i++)
            {
                xn::NodeInfo    depthInfo = *iter;

                logOut(MsgNode_Info,"index=%d\tGetCreationInfo(): %s\tGetInstanceName:%s\tname: %s\tvendor: %s",i,depthInfo.GetCreationInfo(),
                                                                                              depthInfo.GetInstanceName(),
                                                                                              depthInfo.GetDescription().strName,
                                                                                              depthInfo.GetDescription().strVendor);

            }

            i = 0;
            rc = _globalContext.EnumerateProductionTrees(XN_NODE_TYPE_IR, NULL,list);
            logOut(MsgNode_Info,"IR List:");
            for(xn::NodeInfoList::Iterator iter = list.Begin(); iter != list.End(); ++iter,i++)
            {
                xn::NodeInfo    depthInfo = *iter;

                logOut(MsgNode_Info,"index=%d\tGetCreationInfo(): %s\tGetInstanceName:%s\tname: %s\tvendor: %s",i,depthInfo.GetCreationInfo(),
                                                                                              depthInfo.GetInstanceName(),
                                                                                              depthInfo.GetDescription().strName,
                                                                                              depthInfo.GetDescription().strVendor);

            }

            i = 0;
            rc = _globalContext.EnumerateProductionTrees(XN_NODE_TYPE_SCENE, NULL,list);
            logOut(MsgNode_Info,"Scene List:");
            for(xn::NodeInfoList::Iterator iter = list.Begin(); iter != list.End(); ++iter,i++)
            {
                xn::NodeInfo    depthInfo = *iter;

                logOut(MsgNode_Info,"index=%d\tGetCreationInfo(): %s\tGetInstanceName:%s\tname: %s\tvendor: %s",i,depthInfo.GetCreationInfo(),
                                                                                              depthInfo.GetInstanceName(),
                                                                                              depthInfo.GetDescription().strName,
                                                                                              depthInfo.GetDescription().strVendor);

            }
        }

        return _globalContextFlag;
    }
    else
        return _globalContextFlag;
}

bool ContextWrapper::getNodeInfo(int nodeType,int index,
                                 xn::NodeInfoList*   list,
                                 xn::NodeInfo* pNodeInfo,
                                 int offset)
{
    int                 i=0;
    XnStatus            rc;

    index *= offset;

    rc = _globalContext.EnumerateProductionTrees(nodeType, NULL,*list);
    logOut(MsgNode_Info,"Device List:");
    for(xn::NodeInfoList::Iterator iter = list->Begin(); iter != list->End(); ++iter)
    {
        xn::NodeInfo nodeInfo = *iter;

        if(strcmp(nodeInfo.GetInstanceName(),"") == 0)
        {   // prepared one
            if(i == index)
            {   // found, copy the InfoNode
                *pNodeInfo = nodeInfo;
                return true;
            }
            else
                i++;
        }
    }
    return false;
}

bool ContextWrapper::init(int runMode)
{
    _threadMode = runMode;

    // init the cam with the xml setup file
    xn::EnumerationErrors errors;
    _rc = _globalContext.Init();
    if (_rc == XN_STATUS_NO_NODE_PRESENT)
        return false;
    else if (_rc != XN_STATUS_OK)
    {
        logOut(MsgNode_Error,"ContextWrapper::init\n");
        return false;
    }

    checkLicenses();

    /*
    // check the list of all devices
    xn::NodeInfoList list;
    _rc = _globalContext.EnumerateProductionTrees(XN_NODE_TYPE_DEVICE, NULL,list);
    int i=0;
    _deviceCount = 0;
    for(xn::NodeInfoList::Iterator iter = list.Begin(); iter != list.End(); ++iter,i++)
    {
        xn::NodeInfo node = (*iter);

        // std::cout << "kinect cam:" << node.GetCreationInfo() << std::endl;
        std::cout << i << ": " << std::string(node.GetDescription().strName) << "/" << std::string(node.GetDescription().strVendor) << std::endl;

//                xn::Context* context = new xn::Context();
//                //_globalContext->Init();
//                //_genList.push_back(context);

//                _rc = _globalContext->CreateProductionTree(node);
//                CHECK_RC(_rc, "InitFromXml");
//                CHECK_ERRORS(_rc, errors, "InitFromXmlFile");
        _deviceCount++;
    }
    */

    _initFlag = true;
    return true;
}

bool ContextWrapper::initX(int deviceIndex)
{
    logOut(MsgNode_Error,"start index init");

    initContext();

    _threadMode = RunMode_SingleThreaded;

    //checkLicenses();


    // check the list of all devices
    xn::NodeInfoList list;
    _rc = _globalContext.EnumerateProductionTrees(XN_NODE_TYPE_DEVICE, NULL,list);

    int i=0;
    for(xn::NodeInfoList::Iterator iter = list.Begin(); iter != list.End(); ++iter,i++)
    {
        if(deviceIndex == i)
        {
            _deviceIndex = deviceIndex;

            xn::NodeInfo    deviceNodeInfo = *iter;

            deviceNodeInfo.GetInstance(_device);
            XnBool bExists = _device.IsValid();
            if(!bExists)
            {   // create node
                _rc = _globalContext.CreateProductionTree(deviceNodeInfo, _device);
                // save the creationInfo as well
                _deviceCreationInfo = deviceNodeInfo.GetCreationInfo();
                if(_rc != XN_STATUS_OK)
                    return false;
            }

            if (_device.IsValid())
            {
                _initFlag = true;

                // add to global list
                _classList.push_back(this);
                return true;
            }
            else
                return false;
        }

    }

    return false;
}


int ContextWrapper::nodes()
{
    return _nodes;
}

int ContextWrapper::deviceCount()
{
    return _deviceCount;
}

int ContextWrapper::deviceNames(std::vector<std::string>* nodeNames)
{
    if(!_globalContextFlag)
        return 0;

    nodeNames->clear();

    // check the list of all devices
    xn::NodeInfoList list;
    XnStatus rc = _globalContext.EnumerateProductionTrees(XN_NODE_TYPE_DEVICE, NULL,list);
    for(xn::NodeInfoList::Iterator iter = list.Begin(); iter != list.End(); ++iter)
    {
        xn::NodeInfo node = (*iter);

        nodeNames->push_back(std::string(node.GetDescription().strName) + "/" + std::string(node.GetDescription().strVendor));
    }

    return nodeNames->size();
}


void ContextWrapper::addLicense(const char* vendor,const char* license)
{
    XnLicense lic;
    strncpy(lic.strVendor,vendor,XN_MAX_NAME_LENGTH);
    strncpy(lic.strKey,license,XN_MAX_LICENSE_LENGTH);

    _rc = _globalContext.AddLicense(lic);
}

bool ContextWrapper::createDepth(bool force)
{
    if(!_initFlag)
        return false;

    /*
    _rc = _globalContext.FindExistingNode(XN_NODE_TYPE_DEPTH, _depth);
    if(_rc != XN_STATUS_OK)
    {	// could not find the depth, create it by default
        if(force == false)
            return false;

        _rc = _depth.Create(_globalContext);

        // set default data
        _rc = _depth.SetMapOutputMode(_depthMapOutputMode);
    }

    _depth.GetMetaData(_depthMD);

    _depthBufSize		= _depthMD.XRes() * _depthMD.YRes();
    _pDepthImage		= (XnRGB24Pixel*)malloc( _depthBufSize * sizeof(XnRGB24Pixel));
    _depthMapRealWorld	= (XnPoint3D*)malloc( _depthBufSize * sizeof(XnPoint3D));

    _nodes |= Node_Depth;
    return true;
    */


    xn::NodeInfoList    list;
    xn::NodeInfo        depthNodeInfo(NULL);

    if(getNodeInfo(XN_NODE_TYPE_DEPTH,_deviceIndex,
                   &list,&depthNodeInfo))
    {
        _rc = _globalContext.CreateProductionTree(depthNodeInfo,_depth);
        if(_rc == XN_STATUS_OK)
        {
            if(_depth.IsValid())
            {
                logOut(MsgNode_Error,"depth valid");

                _depth.SetMapOutputMode(_depthMapOutputMode);
                _depth.GetMetaData(_depthMD);

                _depthBufSize       = _depthMD.XRes() * _depthMD.YRes();
                _pDepthImage        = (XnRGB24Pixel*)malloc( _depthBufSize * sizeof(XnRGB24Pixel));
                _depthMapRealWorld  = (XnPoint3D*)malloc( _depthBufSize * sizeof(XnPoint3D));

                _nodes |= Node_Depth;
                return true;
            }
        }
    }

    _nodes |= Node_Depth;
    return false;
/*
    // funkt.

    xn::NodeInfoList    list;
    int                 i=0;
    int                 index=0;
    _rc = _globalContext.EnumerateProductionTrees(XN_NODE_TYPE_DEPTH, NULL,list);
    logOut(MsgNode_Info,"Create depth: %d",_deviceIndex);
    for(xn::NodeInfoList::Iterator iter = list.Begin(); iter != list.End(); ++iter,index++)
    {
        xn::NodeInfo nodeInfo = *iter;

        if(strcmp(nodeInfo.GetInstanceName(),"") == 0)
        {   // prepared one
            if(i == _deviceIndex)
            {   // found
                _rc = _globalContext.CreateProductionTree(nodeInfo,_depth);
                logOut(MsgNode_Info,"take empty depth: %d,%d",i,_rc);
                if(_rc == XN_STATUS_OK)
                {
                    if(_depth.IsValid())
                    {
                        logOut(MsgNode_Error,"depth valid, index: %d",i);

                        _depth.SetMapOutputMode(_depthMapOutputMode);
                        _depth.GetMetaData(_depthMD);

                        _depthBufSize       = _depthMD.XRes() * _depthMD.YRes();
                        _pDepthImage        = (XnRGB24Pixel*)malloc( _depthBufSize * sizeof(XnRGB24Pixel));
                        _depthMapRealWorld  = (XnPoint3D*)malloc( _depthBufSize * sizeof(XnPoint3D));

                        _nodes |= Node_Depth;
                        return true;
                    }
                }
                else
                    return false;
            }
            else
                logOut(MsgNode_Info,"not taken empty depth: %d",i);
            i++;
        }
        else
          logOut(MsgNode_Info,"not taken depth: %s",nodeInfo.GetInstanceName());
    }
    return false;
*/

}

bool ContextWrapper::enableDepth()
{
    if(!_initFlag)
    {
        printf("SimpleOpenNI not initialised\n");
        return false;
    }
    else if(_depth.IsValid())
        // already init.
        return true;

    return createDepth();
}

bool ContextWrapper::enableDepth(int width,int height,int fps)
{
    // set default data
    _depthMapOutputMode.nXRes = width;
    _depthMapOutputMode.nYRes = height;
    _depthMapOutputMode.nFPS = fps;

    return ContextWrapper::enableDepth();
}

bool ContextWrapper::createRgb(bool force)
{
    if(!_initFlag)
        return false;
/*
    _rc = _globalContext.FindExistingNode(XN_NODE_TYPE_IMAGE, _image);
    if(_rc != XN_STATUS_OK)
    {	// could not find the depth, create it by default
        if(force == false)
            return false;
        _rc = _image.Create(_globalContext);

        // set default data
        _rc = _image.SetMapOutputMode(_imageMapOutputMode);
    }
    _image.GetMetaData(_imageMD);

    _rgbBufSize = _imageMD.XRes() * _imageMD.YRes();

    _nodes |= Node_Image;

    return true;
*/

    xn::NodeInfoList    list;
    xn::NodeInfo        rgbNodeInfo(NULL);

    printf("image 0\n");
    if(getNodeInfo(XN_NODE_TYPE_IMAGE,_deviceIndex,
                   &list,&rgbNodeInfo))
    {
        _rc = _globalContext.CreateProductionTree(rgbNodeInfo,_image);
        printf("image 1\n");
        if(_rc == XN_STATUS_OK)
        {
            printf("image 2\n");
            if(_image.IsValid())
            {
                logOut(MsgNode_Error,"image valid");

                 _rc = _image.SetMapOutputMode(_imageMapOutputMode);
                 _image.GetMetaData(_imageMD);

                 _rgbBufSize = _imageMD.XRes() * _imageMD.YRes();

                _nodes |= Node_Image;
                return true;
            }
        }
    }
    return false;
}

bool ContextWrapper::enableRGB()
{
    if(!_initFlag)
    {
        printf("SimpleOpenNI not initialised\n");
        return false;
    }
    else if(_image.IsValid())
        // already init.
        return true;

    return createRgb();
}

bool ContextWrapper::enableRGB(int width,int height,int fps)
{
    // set default data
    _imageMapOutputMode.nXRes = width;
    _imageMapOutputMode.nYRes = height;
    _imageMapOutputMode.nFPS = fps;

    return ContextWrapper::enableRGB();
}

bool ContextWrapper::createIr(bool force)
{
    if(!_initFlag)
        return false;
/*
    _rc = _globalContext.FindExistingNode(XN_NODE_TYPE_IR, _ir);
    if(_rc != XN_STATUS_OK)
    {	// could not find the depth, create it by default
        if(force == false)
            return false;
        _rc = _ir.Create(_globalContext);

        // set default data
        _rc = _ir.SetMapOutputMode(_irMapOutputMode);
    }
    _ir.GetMetaData(_irMD);

    _irBufSize = _irMD.XRes() * _irMD.YRes();
    _pIrImage  = (XnRGB24Pixel*)malloc( _irBufSize * sizeof(XnRGB24Pixel));

    _nodes |= Node_Ir;
    return true;
*/
    xn::NodeInfoList    list;
    xn::NodeInfo        irNodeInfo(NULL);

    if(getNodeInfo(XN_NODE_TYPE_IR,_deviceIndex,
                   &list,&irNodeInfo))
    {
        _rc = _globalContext.CreateProductionTree(irNodeInfo,_ir);
        if(_rc == XN_STATUS_OK)
        {
            if(_ir.IsValid())
            {
                _rc = _ir.SetMapOutputMode(_irMapOutputMode);
                _ir.GetMetaData(_irMD);

                _irBufSize = _irMD.XRes() * _irMD.YRes();
                _pIrImage  = (XnRGB24Pixel*)malloc( _irBufSize * sizeof(XnRGB24Pixel));

                _nodes |= Node_Ir;
                return true;

            }
        }
    }
    return false;
}

bool ContextWrapper::enableIR()
{
    if(!_initFlag)
    {
        printf("SimpleOpenNI not initialised\n");
        return false;
    }
    else if(_ir.IsValid())
        // already init.
        return true;

    return createIr();
}

bool ContextWrapper::enableIR(int width,int height,int fps)
{
    // set default data
    _irMapOutputMode.nXRes = width;
    _irMapOutputMode.nYRes = height;
    _irMapOutputMode.nFPS = fps;

    return ContextWrapper::enableIR();
}

bool ContextWrapper::createScene(bool force)
{
    if(!_initFlag)
        return false;
/*
    _rc = _globalContext.FindExistingNode(XN_NODE_TYPE_SCENE, _sceneAnalyzer);
    if(_rc != XN_STATUS_OK)
    {	// could not find the depth, create it by default
        if(force == false)
            return false;

        // depth has to be created before the scene, create a default depth
        if(!_depth.IsValid())
        {
            _rc = _sceneDepth.Create(_globalContext);
            _rc = _sceneDepth.SetMapOutputMode(_depthMapOutputMode);
        }

        _rc = _sceneAnalyzer.Create(_globalContext);

        // set default data
        _rc = _sceneAnalyzer.SetMapOutputMode(_sceneMapOutputMode);
    }

    if(_sceneAnalyzer.IsValid())
    {
        _sceneAnalyzer.GetMetaData(_sceneMD);

        _sceneBufSize = _sceneMD.XRes() * _sceneMD.YRes();
        _pSceneImage  = (XnRGB24Pixel*)malloc( _sceneBufSize * sizeof(XnRGB24Pixel));

        _nodes |= Node_Scene;
        return true;
    }
    else
        return false;
*/

    xn::NodeInfoList    list;
    xn::NodeInfo        sceneNodeInfo(NULL);

    if(getNodeInfo(XN_NODE_TYPE_SCENE,_deviceIndex,
                   &list,&sceneNodeInfo,
                   1))
    {
        _rc = _globalContext.CreateProductionTree(sceneNodeInfo,_sceneAnalyzer);
        if(_rc == XN_STATUS_OK)
        {
            if(_sceneAnalyzer.IsValid())
            {
                std::cout << "sceneValdi:  " << _deviceIndex << std::endl;

                _rc = _sceneAnalyzer.SetMapOutputMode(_sceneMapOutputMode);
                _sceneAnalyzer.GetMetaData(_sceneMD);

                _sceneBufSize = _sceneMD.XRes() * _sceneMD.YRes();
                _pSceneImage  = (XnRGB24Pixel*)malloc( _sceneBufSize * sizeof(XnRGB24Pixel));

                _nodes |= Node_Scene;
                return true;
            }
        }
    }
    return false;

}

bool ContextWrapper::enableScene()
{
    if(!_initFlag)
    {
        printf("SimpleOpenNI not initialised\n");
        return false;
    }
    else if(_sceneAnalyzer.IsValid())
        // already init.
        return true;

    return createScene();
}


bool ContextWrapper::enableScene(int width,int height,int fps)
{
    // set default data
    _sceneMapOutputMode.nXRes = width;
    _sceneMapOutputMode.nYRes = height;
    _sceneMapOutputMode.nFPS = fps;

    return ContextWrapper::enableScene();
}

bool ContextWrapper::createUser(int flags,bool force)
{
    if(!_initFlag)
        return false;

    _rc = _globalContext.FindExistingNode(XN_NODE_TYPE_USER, _userGenerator);
    if(_rc != XN_STATUS_OK)
    {
        if(force == false)
            return false;
        _rc = _userGenerator.Create(_globalContext);
    }

    // set the skeleton type
    _userGenerator.GetSkeletonCap().SetSkeletonProfile((XnSkeletonProfile)flags);

    // set the callbacks
    _userGenerator.RegisterUserCallbacks(newUserCb, lostUserCb, this, _hUserCb);
    _userGenerator.GetSkeletonCap().RegisterCalibrationCallbacks(startCalibrationCb, endCalibrationCb, this, _hCalibrationCb);
    _userGenerator.GetPoseDetectionCap().RegisterToPoseCallbacks(startPoseCb, endPoseCb, this, _hPoseCb);

    // get the scenemap + read out the size
    SceneMetaData  sceneMD;
    _userGenerator.GetUserPixels(0,sceneMD);

    _userWidth	= sceneMD.XRes();
    _userHeight = sceneMD.YRes();
    _userSceneBufSize = _userWidth * _userHeight;


    _nodes |= Node_User;

    return true;

}

bool ContextWrapper::enableUser(int flags)
{
    if(!_initFlag)
    {
        printf("SimpleOpenNI not initialised\n");
        return false;
    }
    else if(_userGenerator.IsValid())
        // already init.
        return true;

    return createUser(flags);
}

bool ContextWrapper::createHands(bool force)
{
    if(!_initFlag)
        return false;

    _rc = _globalContext.FindExistingNode(XN_NODE_TYPE_HANDS, _handsGenerator);
    if(_rc != XN_STATUS_OK)
    {	// it's not in the xml, create it
        if(force == false)
            return false;
        _rc = _handsGenerator.Create(_globalContext);
    }

    // set the callbacks
    std::cout << "hands callback: " << _rc << std::endl;

    _handsGenerator.RegisterHandCallbacks(createHandsCb,
                                          updateHandsCb,
                                          destroyHandsCb,
                                          this,
                                          _hHandsCb);

    _nodes |= Node_Hands;
    return true;
}

// hands
bool ContextWrapper::enableHands()
{
    if(!_initFlag)
    {
        logOut(MsgNode_Error,"enableHands: context is not initialized!");
        return false;
    }
    else if(_handsGenerator.IsValid())
        // already init.
        return true;

    return createHands();
}

void ContextWrapper::startTrackingHands(const XnVector3D& pos)
{	
    if(!_handsGenerator.IsValid())
        return;

    _handsGenerator.StartTracking(pos);
}

void ContextWrapper::stopTrackingHands(int handId)
{	
    if(!_handsGenerator.IsValid())
        return;

    _handsGenerator.StopTracking(handId);
}

void ContextWrapper::stopTrackingAllHands()
{	
    if(!_handsGenerator.IsValid())
        return;

    _handsGenerator.StopTrackingAll();
}

void ContextWrapper::setSmoothingHands(float smoothingFactor)
{	
    if(!_handsGenerator.IsValid())
        return;

    _handsGenerator.SetSmoothing(smoothingFactor);
}

bool ContextWrapper::createGesture(bool force)
{
    if(!_initFlag)
        return false;
    _rc = _globalContext.FindExistingNode(XN_NODE_TYPE_GESTURE, _gestureGenerator);
    if(_rc != XN_STATUS_OK)
    {	// it's not in the xml, create it
        if(force == false)
            return false;
        _rc = _gestureGenerator.Create(_globalContext);
    }

    // set the callbacks
    _rc = _gestureGenerator.RegisterGestureCallbacks(recognizeGestureCb,
                                                     progressGestureCb,
                                                     this,
                                                     _hGestureCb);

    /*
 XnChar* strArray =(XnChar*) new XnChar[200][200];
 XnUInt16 count=200;
 _gestureGenerator.EnumerateGestures(strArray,count);
 for(int i=0;i<count;i++)
  logOut(MsgNode_Error,"gestures:%d %s",i,strArray[i]);
 */
    _nodes |= Node_Gesture;

    return true;
}

// gesture
bool ContextWrapper::enableGesture()
{
    if(!_initFlag)
    {
        logOut(MsgNode_Error,"enableGesture: context is not initialized!");
        return false;
    }
    else if(_gestureGenerator.IsValid())
        // already init.
        return true;

    return createGesture();
}

void ContextWrapper::addGesture(const char* gesture)
{
    if(!_gestureGenerator.IsValid())
        return;

    /*
 if(!_generatingFlag)
 {
  logOut(MsgNode_Info,"_generatingFlag");
  _globalContext.StartGeneratingAll();
  _generatingFlag = true;
 }
*/	

    // default, no bounding box
    /*
 XnBoundingBox3D box;
 box.LeftBottomNear.X = -5000;
 box.LeftBottomNear.Y = -5000;
 box.LeftBottomNear.Z = 0;

 box.RightTopFar.X =   +5000;
 box.RightTopFar.Y =   +5000;
 box.RightTopFar.Z =   10000;

 _rc = _gestureGenerator.AddGesture(gesture,&box);
 */

    _rc = _gestureGenerator.AddGesture(gesture,NULL);
    /*
 if(_rc == XN_STATUS_OK)
  logOut(MsgNode_Info,"addGesture: %s",gesture);
 */
}

void ContextWrapper::removeGesture(const char* gesture)
{
    if(!_gestureGenerator.IsValid())
        return;

    _gestureGenerator.RemoveGesture(gesture);
}

bool ContextWrapper::availableGesture(const char* gesture)
{
    if(!_gestureGenerator.IsValid())
        return false;

    return _gestureGenerator.IsGestureAvailable(gesture)>0;
}

///////////////////////////////////////////////////////////////////////////////
// recorder

bool ContextWrapper::enableRecorder(int recordMedium,const char* filePath)
{
    if(!_initFlag)
    {
        logOut(MsgNode_Error,"enableRecorder: context is not initialized!");
        return false;
    }
    else if(_recorder.IsValid())
        // already init.
        return true;

    _rc = _globalContext.FindExistingNode(XN_NODE_TYPE_RECORDER, _recorder);
    if(_rc != XN_STATUS_OK)
    {
        _rc = _recorder.Create(_globalContext);
    }

    // set the recording
    _rc = _recorder.SetDestination((XnRecordMedium)recordMedium,filePath);
    if(_rc != XN_STATUS_OK)
    {
        logOut(MsgNode_Error,"enableRecorder: %s",filePath);
        return false;
    }

    _nodes |= Node_Recorder;
    return true;
}

bool ContextWrapper::addNodeToRecording(int nodeType,int compression)
{
    if(!_initFlag)
    {
        logOut(MsgNode_Error,"enableRecorder: context is not initialized!");
        return false;
    }
    else if(!_recorder.IsValid())
    {
        logOut(MsgNode_Error,"removeNodeToRecording: recording is not enabled");
        return false;
    }

    xn::ProductionNode* recordNode = getNode(nodeType);
    if(recordNode != NULL)
    {
        _rc = _recorder.AddNodeToRecording(*recordNode, compression);
        return _rc == XN_STATUS_OK;
    }
    return false;
}

bool ContextWrapper::removeNodeFromRecording(int nodeType)
{
    if(!_initFlag)
    {
        logOut(MsgNode_Error,"enableRecorder: context is not initialized!");
        return false;
    }
    else if(!_recorder.IsValid())
    {
        logOut(MsgNode_Error,"removeNodeToRecording: recording is not enabled");
        return false;
    }


    xn::ProductionNode* recordNode = getNode(nodeType);
    if(recordNode != NULL)
    {
        _rc = _recorder.RemoveNodeFromRecording(*recordNode);
        return _rc == XN_STATUS_OK;
    }

    return false;
}

bool ContextWrapper::openFileRecording(const char* filePath)
{
    if(!_initFlag)
    {
        logOut(MsgNode_Error,"openFileRecording: context is not initialized!");
        return false;
    }

    _rc = _globalContext.OpenFileRecording(filePath);
    if(_rc != XN_STATUS_OK)
        return false;

    // add all the nodes to the player line
    createDepth(false);
    createRgb(false);
    createIr(false);
    createScene(false);
    createUser(XN_SKEL_PROFILE_ALL,false);
    createGesture(false);
    createHands(false);

    _nodes |= Node_Player;

    return true;
}

///////////////////////////////////////////////////////////////////////////////
// update

// depth
bool ContextWrapper::updateDepthData()
{
    if(_depthMapTimeStamp == _updateTimeStamp)
        return false;

    _depth.GetMetaData(_depthMD);
    _depthMapTimeStamp  = _updateTimeStamp;

    //boost::mutex::scoped_lock l(_mainMutex);
    return true;
}

bool ContextWrapper::updateDepthImageData()
{
    if(_depthImageTimeStamp == _updateTimeStamp)
        return false;

    // updtate the base data
    updateDepthData();

    calcHistogram();
    createDepthImage();
    _depthImageTimeStamp = _updateTimeStamp;

    //boost::mutex::scoped_lock l(_mainMutex);
    return true;
}

bool ContextWrapper::updateDepthRealWorldData()
{
    if(_depthRealWorldTimeStamp == _updateTimeStamp)
        return false;

    // updtate the base data
    updateDepthData();
    calcDepthImageRealWorld();

    _depthRealWorldTimeStamp = _updateTimeStamp;

    return true;
}

// image
void ContextWrapper::updateRgbData()
{
    if(_imageTimeStamp == _updateTimeStamp)
        return;

    // get the new data
    _image.GetMetaData(_imageMD);

    //boost::mutex::scoped_lock l(_mainMutex);
    _imageTimeStamp = _updateTimeStamp;
}

// ir
void ContextWrapper::updateIrData()
{	
    if(_irTimeStamp == _updateTimeStamp)
        return;

    // get the new data
    _ir.GetMetaData(_irMD);

    createIrImage();

    //boost::mutex::scoped_lock l(_mainMutex);
    _irTimeStamp = _updateTimeStamp;
}

// user
void ContextWrapper::updateSceneData()
{
    if(_sceneTimeStamp == _updateTimeStamp)
        return;

    // get the new data
    _sceneAnalyzer.GetMetaData(_sceneMD);

    //boost::mutex::scoped_lock l(_mainMutex);
    _sceneTimeStamp = _updateTimeStamp;
}

void ContextWrapper::updateSceneImageData()
{
    if(_sceneImageTimeStamp == _updateTimeStamp)
        return;

    updateSceneData();
    if(_depth.IsValid())
        updateDepthImageData();
    calcSceneData();

    //boost::mutex::scoped_lock l(_mainMutex);
    _sceneImageTimeStamp = _updateTimeStamp;
}

void ContextWrapper::updateUser()
{
    if(_userTimeStamp == _updateTimeStamp)
        return;

    //boost::mutex::scoped_lock l(_mainMutex);
    _userTimeStamp = _updateTimeStamp;
}

void ContextWrapper::updateHands()
{
    if(_handsTimeStamp == _updateTimeStamp)
        return;

    //boost::mutex::scoped_lock l(_mainMutex);
    _handsTimeStamp = _updateTimeStamp;
}

void ContextWrapper::updateGesture()
{
    if(_gestureTimeStamp == _updateTimeStamp)
        return;

    //boost::mutex::scoped_lock l(_mainMutex);
    _gestureTimeStamp = _updateTimeStamp;
}

///////////////////////////////////////////////////////////////////////////////
// time measure

//#define  WIN_PERF_DEBUG

#ifdef WIN_PERF_DEBUG

typedef struct {
    LARGE_INTEGER start;
    LARGE_INTEGER stop;
} stopWatch;


void startTimer( stopWatch *timer) {
    QueryPerformanceCounter(&timer->start);
}

void stopTimer( stopWatch *timer) {
    QueryPerformanceCounter(&timer->stop);
}

double LIToSecs( LARGE_INTEGER * L) {
    LARGE_INTEGER frequency;
    QueryPerformanceFrequency( &frequency );
    return ((double)L->QuadPart /(double)frequency.QuadPart);
}

double getElapsedTime( stopWatch *timer) {
    LARGE_INTEGER time;
    time.QuadPart = timer->stop.QuadPart - timer->start.QuadPart;
    return LIToSecs( &time) ;
}

stopWatch	timer;
stopWatch	timer1;
stopWatch	timer2;
double		dif;
double		dif1;
double		dif2;
double		total=0;
unsigned long count=0;

#endif // WIN_PERF_DEBUG

void ContextWrapper::updateAll()
{
    static bool start = false;
    if(!start)
    {
        _globalContext.StartGeneratingAll();
    }

    _globalContext.WaitAnyUpdateAll();

    std::vector<class ContextWrapper*>::iterator itr = _classList.begin();
    for(;itr != _classList.end();itr++)
    {
        // update timestamp
        (*itr)->_updateTimeStamp = (*itr)->_updateSubTimeStamp;
        (*itr)->_updateSubTimeStamp++;;
    }

    /*
    std::vector<class ContextWrapper*>::iterator itr = _classList.begin();
    for(;itr != _classList.end();itr++)
    {
        (*itr)->updateSub();
    }
    */
}


void ContextWrapper::update()
{
    if(!_initFlag)
        return;

    if(!_generatingFlag)
    {
        _globalContext.StartGeneratingAll();
        _generatingFlag = true;
    }

    // check if everything is all right for the first round
    if(_firstTimeUpdate)
    {
        _firstTimeUpdate = false;

        // check if we use multithreading
        if(_threadMode == RunMode_MultiThreaded)
        {
            // create + start the thread
            _thread = boost::shared_ptr<boost::thread>(new boost::thread(boost::bind(&ContextWrapper::run, this)));
        }
    }

    // update timestamp
    _updateTimeStamp = _updateSubTimeStamp;

    // update the data
    if(_threadMode < RunMode_MultiThreaded)
        updateSub();
}

void ContextWrapper::updateSub()
{
    boost::mutex::scoped_lock l(_mainMutex);

#ifdef WIN_PERF_DEBUG
    startTimer(&timer);
#endif // WIN_PERF_DEBUG

    // update openNI
    if(_gestureGenerator.IsValid() || _handsGenerator.IsValid() ||
       _userGenerator.IsValid())
    {	// i don't know why, but it only works if i add 'WaitAndUpdateAll'
        //_rc = _globalContext.WaitAnyUpdateAll();
        _rc = _globalContext.WaitAndUpdateAll();
    }
    else
        _rc = _globalContext.WaitAnyUpdateAll();

    // update timestamp
    _updateSubTimeStamp++;


#ifdef WIN_PERF_DEBUG
    stopTimer(&timer);
    startTimer(&timer1);
#endif // WIN_PERF_DEBUG
    /*

 // update NITE
 if(_threadMode == RunMode_MultiThreaded)
 {	// update all sessionManagers
  std::vector<XnVSessionManager*>::iterator itr = _sessionManagerList.begin();
  for(;itr != _sessionManagerList.end(); itr++)
  {
   (*itr)->Update(&_globalContext);
  }
 }
*/


#ifdef WIN_PERF_DEBUG
    stopTimer(&timer1);

    dif = getElapsedTime(&timer);
    total += dif;
    count++;

    dif1 = getElapsedTime(&timer1);

    if(count % 20 == 0)
    {
        std::cout << "_rc: "<< _rc << std::endl;

        std::cout << "fps:\t\t" << (1.0 / (total / count)) <<
                     "\topenNI time:\t" << (total / count * 1000) <<
                     std::endl;

        std::cout << "memcopy sub:\t" << (dif1 * 1000) <<
                     "\topenNI sub:\t" << (dif * 1000) <<
                     "\ttotal:\t" << (dif + dif1)* 1000 <<
                     std::endl;
        std::cout << "---------" << std::endl;

    }
#endif // WIN_PERF_DEBUG
}



void ContextWrapper::calcHistogram()
{
    const XnDepthPixel*	pDepth = _depthMD.Data();

    xnOSMemSet(_pDepthHist, 0, MAX_DEPTH * sizeof(float));

    unsigned int nNumberOfPoints = 0;
    for(XnUInt y = 0; y < _depthMD.YRes(); ++y)
    {
        for(XnUInt x = 0; x < _depthMD.XRes(); ++x, ++pDepth)
        {
            if(*pDepth != 0)
            {
                _pDepthHist[*pDepth]++;
                nNumberOfPoints++;
            }
        }
    }

    for(int nIndex=1; nIndex<MAX_DEPTH; nIndex++)
    {
        _pDepthHist[nIndex] += _pDepthHist[nIndex-1];
    }

    if(nNumberOfPoints)
    {
        for(int nIndex=1; nIndex<MAX_DEPTH; nIndex++)
            _pDepthHist[nIndex] = (float)(unsigned int)(256 * (1.0f - (_pDepthHist[nIndex] / nNumberOfPoints)));
    }

}

void ContextWrapper::calcDepthImageRealWorld()
{
    const XnDepthPixel*	pDepth	= _depthMD.Data();
    XnPoint3D*			map		= _depthMapRealWorld;
    for(int y = 0; y < _depthMD.YRes(); ++y)
    {
        for(int x = 0; x < _depthMD.XRes() ; ++x, ++pDepth,++map)
        {
            map->X = (float)x;
            map->Y = (float)y;
            map->Z = (float)*pDepth;
        }
    }

    // convert all point into realworld coord
    _depth.ConvertProjectiveToRealWorld(_depthBufSize,
                                        _depthMapRealWorld,
                                        _depthMapRealWorld);

}


void ContextWrapper::createDepthImage()
{
    xnOSMemSet(_pDepthImage, 0, _depthMD.XRes()*_depthMD.YRes()*sizeof(XnRGB24Pixel));

    for(XnUInt y = 0; y < _depthMD.YRes(); ++y)
    {
        const XnDepthPixel*	pDepth	= _depthMD.Data()	+ (y * _depthMD.XRes());
        XnRGB24Pixel*		pPixel	= _pDepthImage		+ (y * _depthMD.XRes());

        for(XnUInt x = 0; x < _depthMD.XRes(); ++x, ++pDepth, ++pPixel)
        {
            if(*pDepth != 0)
            {
                int nHistValue = (int)_pDepthHist[*pDepth];

                switch(_depthImageColorMode)
                {
                case DepthImgMode_RgbFade:
                {
                    int pval =_pDepthGamma[(int)((*pDepth) / 1)];
                    //int lb =  255 - (pval & 0xff);
                    int lb =  pval & 0xff;

                    switch (pval>>8)
                    {
                    case 0:
                        pPixel->nRed = 255;
                        pPixel->nGreen = 255-lb;
                        pPixel->nBlue = 255-lb;
                        break;
                    case 1:
                        pPixel->nRed = 255;
                        pPixel->nGreen = lb;
                        pPixel->nBlue = 0;
                        break;
                    case 2:
                        pPixel->nRed = 255-lb;
                        pPixel->nGreen = 255;
                        pPixel->nBlue = 0;
                        break;
                    case 3:
                        pPixel->nRed = 0;
                        pPixel->nGreen = 255;
                        pPixel->nBlue = lb;
                        break;
                    case 4:
                        pPixel->nRed = 0;
                        pPixel->nGreen = 255-lb;
                        pPixel->nBlue = 255;
                        break;
                    case 5:
                        pPixel->nRed = 0;
                        pPixel->nGreen = 0;
                        pPixel->nBlue = 255-lb;
                        break;
                    default:
                        pPixel->nRed = 0;
                        pPixel->nGreen = 0;
                        pPixel->nBlue = 0;
                        break;
                    }

                    /*
      unsigned int color = (float)*pDepth * (float)0xffffff / (float)MAX_DEPTH ;
      //color = 5000;
      pPixel->nRed	= (XnUInt8)(color & 0x0000ff );
      pPixel->nGreen	= (XnUInt8)(color & 0x00ff00 >> 8);
      pPixel->nBlue	= (XnUInt8)(color & 0xff0000 >> 16);
      */
                }
                    break;
                case DepthImgMode_Default:
                default:
                    pPixel->nRed	= (XnUInt8)(nHistValue * _depthImageColor[0]);
                    pPixel->nGreen	= (XnUInt8)(nHistValue * _depthImageColor[1]);
                    pPixel->nBlue	= (XnUInt8)(nHistValue * _depthImageColor[2]);
                    break;
                }
            }
        }
    }
}


///////////////////////////////////////////////////////////////////////////////
// depth methods

float ContextWrapper::hFieldOfView()
{
    XnFieldOfView fieldOfView;
    _depth.GetFieldOfView(fieldOfView);

    return (float)fieldOfView.fHFOV;
}

float ContextWrapper::vFieldOfView()
{
    XnFieldOfView fieldOfView;
    _depth.GetFieldOfView(fieldOfView);

    return (float)fieldOfView.fVFOV;
}


int ContextWrapper::depthWidth()
{
    return _depthMD.XRes();
}

int	ContextWrapper::depthHeight()
{
    return _depthMD.YRes();
}

int ContextWrapper::depthImage(int* map)
{
    if(_depth.IsValid() == false)
        return 0;
    else
        updateDepthImageData();

    for(int i=0;i < _depthBufSize;i++)
    {
        map[i] = (0xff	<< 24) |
                (_pDepthImage[i].nRed	<< 16) |
                (_pDepthImage[i].nGreen << 8) |
                (_pDepthImage[i].nBlue) ;
    }

    return _depthBufSize;
}

int ContextWrapper::depthMap(int* map)
{
    if(_depth.IsValid() == false)
        return 0;
    else
        updateDepthData();

    for(int i=0;i < _depthBufSize;i++)
        map[i] = (int)(_depthMD.Data())[i];

    return _depthBufSize;
} 

int ContextWrapper::depthMapRealWorld(XnPoint3D map[])
{
    if(_depth.IsValid() == false)
        return 0;
    else
        updateDepthRealWorldData();

    // speed up the copy
    memcpy((void*)map,(const void *)_depthMapRealWorld,_depthBufSize * sizeof(XnPoint3D));

    return _depthBufSize;
}  

XnPoint3D* ContextWrapper::depthMapRealWorldA()
{
    if(_depth.IsValid() == false)
        return _depthMapRealWorld;
    else
        updateDepthRealWorldData();

    return _depthMapRealWorld;
}

int ContextWrapper::depthMapRealWorldA(XnPoint3D* map,int count)
{
    return depthMapRealWorld(map);
}

int ContextWrapper::depthMapSize()
{
    return _depthBufSize;
}

int ContextWrapper::depthHistSize()
{
    return MAX_DEPTH;
}

int ContextWrapper::depthHistMap(float* histMap)
{
    if(_depth.IsValid() == false)
        return 0;
    else
        updateDepthImageData();

    memcpy((void*)histMap,(const void *)_pDepthHist,MAX_DEPTH * sizeof(float));
    /*
 for(int i=0;i < MAX_DEPTH;i++)
  histMap[i] = _pDepthHist[i];
*/
    return MAX_DEPTH;
}

void ContextWrapper::setDepthImageColor(int r,int g,int b)
{
    _depthImageColor[0] = r * 1.0f / 255.0f ;
    _depthImageColor[1] = g * 1.0f / 255.0f ;
    _depthImageColor[2] = b * 1.0f / 255.0f ;

}

void ContextWrapper::setDepthImageColorMode(int mode)
{
    _depthImageColorMode = mode;
}

int ContextWrapper::depthImageColorMode()
{
    return _depthImageColorMode;
}



///////////////////////////////////////////////////////////////////////////////
// rgb image methods

int ContextWrapper::rgbWidth()
{
    return _imageMD.XRes();
}

int	ContextWrapper::rgbHeight()
{
    return _imageMD.YRes();
}

int ContextWrapper::rgbImage(int* map)
{
    if(_image.IsValid() == false)
        return 0;
    else
        updateRgbData();

    const XnRGB24Pixel* rgbImage = _imageMD.RGB24Data();

    for(int i=0;i < _rgbBufSize;i++)
    {
        map[i] = 0xff	<< 24 |
                           rgbImage[i].nRed	<< 16|
                           rgbImage[i].nGreen << 8 |
                           rgbImage[i].nBlue ;
    }

    return _rgbBufSize;
}

///////////////////////////////////////////////////////////////////////////////
// ir methods
int ContextWrapper::irWidth()
{
    return _irMD.XRes();
}

int ContextWrapper::irHeight()
{
    return _irMD.YRes();
}

int ContextWrapper::irImage(int* map)
{
    if(_ir.IsValid() == false)
        return 0;
    else
        updateIrData();

    for(int i=0;i < _irBufSize;i++)
    {
        map[i] = 0xff	<< 24 |
                           _pIrImage[i].nRed	<< 16|
                           _pIrImage[i].nGreen << 8 |
                           _pIrImage[i].nBlue ;
    }

    return _irBufSize;
}

int ContextWrapper::irMap(int* map)
{
    if(_ir.IsValid() == false)
        return 0;
    else
        updateIrData();

    for(int i=0;i < _irBufSize;i++)
        map[i] = (int)(_irMD.Data())[i];
    return _irBufSize;
}


void ContextWrapper::createIrImage()
{
    XnUInt8 val;
    xnOSMemSet(_pIrImage, 0, _irMD.XRes()*_irMD.YRes()*sizeof(XnRGB24Pixel));

    for(XnUInt y = 0; y < _irMD.YRes(); ++y)
    {
        const XnIRPixel*	pIr		= _irMD.Data()	+ (y * _irMD.XRes());
        XnRGB24Pixel*		pPixel	= _pIrImage		+ (y * _irMD.XRes());

        for(XnUInt x = 0; x < _irMD.XRes(); ++x, ++pIr, ++pPixel)
        {
            val = (XnUInt8)((float)*pIr * .5f);
            pPixel->nRed	= val;
            pPixel->nGreen	= val;
            pPixel->nBlue	= val;
        }
    }

}

///////////////////////////////////////////////////////////////////////////////
// scene
int ContextWrapper::sceneWidth()
{
    return _sceneMD.XRes();
}

int	ContextWrapper::sceneHeight()
{
    return _sceneMD.YRes();
}


void ContextWrapper::getSceneFloor(XnVector3D* point,	
                                   XnVector3D* normal)
{
    if(!_sceneAnalyzer.IsValid())
        return;
    else
        updateSceneData();

    XnPlane3D plane;
    _sceneAnalyzer.GetFloor(plane);

    point->X = plane.ptPoint.X;
    point->Y = plane.ptPoint.Y;
    point->Z = plane.ptPoint.Z;

    normal->X = plane.vNormal.X;
    normal->Y = plane.vNormal.Y;
    normal->Z = plane.vNormal.Z;

    /*
 // floor orientation test
 Eigen::Vector3f	p(plane.ptPoint.X,plane.ptPoint.Y,plane.ptPoint.Z);
 Eigen::Vector3f	n(plane.vNormal.X,plane.vNormal.Y,plane.vNormal.Z);
 HyperPlane3d	plane3d(n,p);

 Eigen::Vector3f projNull;
 Eigen::Vector3f projNullNormal;
 projNull = plane3d.projection(Eigen::Vector3f(0.0f,0.0f,0.0f));
 projNullNormal = (Eigen::Vector3f(0.0f,0.0f,0.0f) - projNull).normalized();
 */

    // calc the orientation matrix for the floor
    // coordinate center is in the projection of the camera eye to the floor

    /*
 Quaternion		camRot;
 Quaternion		planeRot;
 */

}

void ContextWrapper::calcSceneData()
{
    xnOSMemSet(_pSceneImage, 0, _sceneMD.XRes()*_sceneMD.YRes()*sizeof(XnRGB24Pixel));

    if(_depth.IsValid())
    {	// calc with depth shades
        unsigned int		nValue = 0;
        unsigned int		nHistValue = 0;
        const XnDepthPixel*	pDepth = _depthMD.Data();
        const XnLabel*		pLabels= _sceneMD.Data();
        XnUInt32			nIndex = 0;
        XnRGB24Pixel*		pPixel = _pSceneImage;

        for(unsigned int y=0; y < _sceneMD.YRes(); y++)
        {
            for(unsigned int x=0; x < _sceneMD.XRes(); x++, nIndex++)
            {
                nValue = *pDepth;
                if(*pDepth != 0)
                {
                    XnLabel		label	 = *pLabels;
                    XnUInt32	nColorID = label % nColors;

                    nHistValue = (unsigned int)_pDepthHist[nValue];

                    if(label == 0)
                    {
                        pPixel->nRed	= (XnUInt8)(nHistValue * _depthImageColor[0]);
                        pPixel->nGreen	= (XnUInt8)(nHistValue * _depthImageColor[1]);
                        pPixel->nBlue	= (XnUInt8)(nHistValue * _depthImageColor[2]);
                    }
                    else
                    {
                        pPixel->nRed	= (XnUInt8)(nHistValue * Colors[nColorID][0]);
                        pPixel->nGreen	= (XnUInt8)(nHistValue * Colors[nColorID][1]);
                        pPixel->nBlue	= (XnUInt8)(nHistValue * Colors[nColorID][2]);
                    }
                }

                pDepth++;
                pLabels++;
                pPixel++;
            }
        }

    }
    else
    {	// calc with no background
        const XnLabel*		pLabels= _sceneMD.Data();
        XnRGB24Pixel*		pPixel = _pSceneImage;

        for(unsigned int y=0; y < _sceneMD.YRes(); y++)
        {
            for(unsigned int x=0; x < _sceneMD.XRes(); x++)
            {
                XnLabel		label	 = *pLabels;
                XnUInt32	nColorID = label % nColors;
                if(label != 0)
                {
                    pPixel->nRed	= (XnUInt8)(255 * Colors[nColorID][0]);
                    pPixel->nGreen	= (XnUInt8)(255 * Colors[nColorID][1]);
                    pPixel->nBlue	= (XnUInt8)(255 * Colors[nColorID][2]);
                }

                pLabels++;
                pPixel++;
            }
        }
    }
}

int ContextWrapper::sceneMap(int* map)
{
    if(!_sceneAnalyzer.IsValid())
        return 0;
    else
        updateSceneData();

    for(int i=0;i < _sceneBufSize;i++)
        map[i] = (int)(_sceneMD.Data())[i];
    return _sceneBufSize;
}

int ContextWrapper::sceneImage(int* map)
{
    if(!_sceneAnalyzer.IsValid())
        return 0;
    else
        updateSceneImageData();

    for(int i=0;i < _sceneBufSize;i++)
    {
        map[i] = 0xff	<< 24 |
                           _pSceneImage[i].nRed	<< 16|
                           _pSceneImage[i].nGreen << 8 |
                           _pSceneImage[i].nBlue ;
    }
    return _sceneBufSize;
}

///////////////////////////////////////////////////////////////////////////////
// user methods

bool ContextWrapper::getCoM(int user, XnPoint3D&  com)
{
    if(!_userGenerator.IsValid())
        return false;
    else
        updateUser();

    _rc = _userGenerator.GetCoM(user,com);
    return(_rc == XN_STATUS_OK);
}

int ContextWrapper::getNumberOfUsers()
{
    if(!_userGenerator.IsValid())
        return 0;
    else
        updateUser();

    return _userGenerator.GetNumberOfUsers();
}

int ContextWrapper::getUsers(std::vector<int>* userList)
{
    if(!_userGenerator.IsValid())
        return 0;
    else
        updateUser();

    XnUInt16	userCount = _userGenerator.GetNumberOfUsers();
    if(userCount > 0)
    {
        XnUserID usersArray[20];	// never more than 20 users
        _userGenerator.GetUsers(usersArray, userCount);

        userList->clear();
        for(int i=0;i<userCount;i++)
            userList->push_back((int)usersArray[i]);
    }
    return userCount;
}

int	ContextWrapper::userWidth()
{
    return _userWidth;
}

int	ContextWrapper::userHeight()
{
    return _userHeight;
}

int	ContextWrapper::getUserPixels(int user,int* userSceneData)
{
    if(!_userGenerator.IsValid())
        return 0;
    else
        updateUser();

    SceneMetaData  sceneMD;
    _userGenerator.GetUserPixels(user,sceneMD);

    // update the size / it seams like the user changes the camera size(QVGA/VGA)
    _userWidth	= sceneMD.XRes();
    _userHeight = sceneMD.YRes();

    int					index = 0;
    const XnLabel*		pLabels= sceneMD.Data();
    for(unsigned int y=0; y < sceneMD.YRes(); y++)
    {
        for(unsigned int x=0; x < sceneMD.XRes(); x++)
        {
            userSceneData[index] = *pLabels;;

            pLabels++;
            index++;
        }
    }
    return sceneMD.XRes() * sceneMD.YRes();
}

bool ContextWrapper::getUserPostition(int user, XnBoundingBox3D*  pPosition )
{
    if(!_depth.IsValid())
        return false;

    UserPositionCapability  userPosCap = _depth.GetUserPositionCap();
    userPosCap.GetUserPosition(user,*pPosition);

    return true;

}


bool ContextWrapper::isTrackingSkeleton(int user)
{
    if(!_userGenerator.IsValid())
        return false;
    else
        updateUser();

    return _userGenerator.GetSkeletonCap().IsTracking(user) > 0;
}

bool ContextWrapper::isCalibratedSkeleton(int user)
{
    if(!_userGenerator.IsValid())
        return false;
    else
        updateUser();

    return _userGenerator.GetSkeletonCap().IsCalibrated(user) > 0;
}

bool ContextWrapper::isCalibratingSkeleton(int user)
{
    if(!_userGenerator.IsValid())
        return false;
    else
        updateUser();

    return _userGenerator.GetSkeletonCap().IsCalibrating(user) > 0;
}

void ContextWrapper::requestCalibrationSkeleton(int user, bool force)
{
    if(!_userGenerator.IsValid())
        return;
    else
        updateUser();

    _userGenerator.GetSkeletonCap().RequestCalibration(user, force);
}

void ContextWrapper::abortCalibrationSkeleton(int user)
{
    if(!_userGenerator.IsValid())
        return;
    else
        updateUser();

    _userGenerator.GetSkeletonCap().AbortCalibration(user);

}

bool ContextWrapper::saveCalibrationDataSkeleton(int user,int slot)
{
    if(!_userGenerator.IsValid())
        return false;
    else
        updateUser();

    if(_userGenerator.GetSkeletonCap().IsCalibrated(user) == 0)
        return false;

    _rc = _userGenerator.GetSkeletonCap().SaveCalibrationData(user,slot);
    return(_rc == XN_STATUS_OK);
}

bool ContextWrapper::loadCalibrationDataSkeleton(int user,int slot)
{
    if(!_userGenerator.IsValid())
        return false;
    else
        updateUser();

    _rc = _userGenerator.GetSkeletonCap().LoadCalibrationData(user,slot);
    return(_rc == XN_STATUS_OK);
}

bool ContextWrapper::saveCalibrationDataSkeleton(int user,const char* calibrationFile)
{
    if(!_userGenerator.IsValid())
        return false;
    else
        updateUser();

    if(_userGenerator.GetSkeletonCap().IsCalibrated(user) == 0)
        return false;

    _rc = _userGenerator.GetSkeletonCap().SaveCalibrationDataToFile(user,calibrationFile);
    return(_rc == XN_STATUS_OK);
}

bool ContextWrapper::loadCalibrationDataSkeleton(int user,const char* calibrationFile)
{
    if(!_userGenerator.IsValid())
        return false;
    else
        updateUser();

    _rc = _userGenerator.GetSkeletonCap().LoadCalibrationDataFromFile(user,calibrationFile);
    return(_rc == XN_STATUS_OK);
}

void ContextWrapper::setSmoothingSkeleton(float factor)
{
    if(!_userGenerator.IsValid())
        return;

    _rc = _userGenerator.GetSkeletonCap().SetSmoothing(factor);
}

void ContextWrapper::clearCalibrationDataSkeleton(int slot)
{
    if(!_userGenerator.IsValid())
        return;

    _rc = _userGenerator.GetSkeletonCap().ClearCalibrationData(slot);
}

bool ContextWrapper::isCalibrationDataSkeleton(int slot)
{
    if(!_userGenerator.IsValid())
        return false;

    return _userGenerator.GetSkeletonCap().IsCalibrationData(slot) > 0;
}

void ContextWrapper::startTrackingSkeleton(int user)
{
    if(!_userGenerator.IsValid())
        return;

    _userGenerator.GetSkeletonCap().StartTracking(user);
}

void ContextWrapper::stopTrackingSkeleton(int user)
{
    if(!_userGenerator.IsValid())
        return;

    _userGenerator.GetSkeletonCap().StopTracking(user);
}

void ContextWrapper::startPoseDetection(const char* pose,int user)
{
    if(!_userGenerator.IsValid())
        return;

    _userGenerator.GetPoseDetectionCap().StartPoseDetection(pose, user);
}

void ContextWrapper::stopPoseDetection(int user)
{
    if(!_userGenerator.IsValid())
        return;

    _userGenerator.GetPoseDetectionCap().StopPoseDetection(user);
}



bool ContextWrapper::getJointPositionSkeleton(int user,int joint,XnSkeletonJointPosition* jointPos)
{
    if(!_userGenerator.IsValid())
        return false;
    else
        updateUser();

    _rc = _userGenerator.GetSkeletonCap().GetSkeletonJointPosition( user, (XnSkeletonJoint)joint, *jointPos);

    return(_rc == XN_STATUS_OK);
}

bool ContextWrapper::getJointOrientationSkeleton(int user,
                                                 int joint,
                                                 XnSkeletonJointOrientation* jointOrientation)
{
    if(!_userGenerator.IsValid())
        return false;
    else
        updateUser();

    _rc = _userGenerator.GetSkeletonCap().GetSkeletonJointOrientation ( user, (XnSkeletonJoint)joint, *jointOrientation);

    return(_rc == XN_STATUS_OK);
}


void ContextWrapper::convertRealWorldToProjective(XnVector3D* world,XnVector3D* proj)
{
    if(!_depth.IsValid())
        return;
    _depth.ConvertRealWorldToProjective(1, world, proj);
}

void ContextWrapper::convertRealWorldToProjective(std::vector<XnVector3D>* worldArray,std::vector<XnVector3D>* projArray)
{
    if(!_depth.IsValid())
        return;

    projArray->clear();

    XnVector3D vec;
    std::vector<XnVector3D>::iterator itr = worldArray->begin();
    for(;itr != worldArray->end();itr++)
    {
        _depth.ConvertRealWorldToProjective(1, &(*itr), &vec);
        projArray->push_back(vec);
    }
}

void ContextWrapper::convertProjectiveToRealWorld (XnVector3D* proj,XnVector3D* world)
{
    if(!_depth.IsValid())
        return;
    _depth.ConvertProjectiveToRealWorld  (1, proj, world);
}

void ContextWrapper::convertProjectiveToRealWorld(std::vector<XnVector3D>* projArray,std::vector<XnVector3D>* worldArray)
{
    if(!_depth.IsValid())
        return;

    worldArray->clear();

    XnVector3D vec;
    std::vector<XnVector3D>::iterator itr = projArray->begin();
    for(;itr != projArray->end();itr++)
    {
        _depth.ConvertProjectiveToRealWorld(1, &(*itr), &vec);
        worldArray->push_back(vec);
    }
}

bool ContextWrapper::alternativeViewPointDepthToImage()
{
    if(!_depth.IsValid() || !_image.IsValid())
        return false;

    _rc = _depth.GetAlternativeViewPointCap().SetViewPoint(_image);
    return (_rc == XN_STATUS_OK);
}


///////////////////////////////////////////////////////////////////////////////
// access methods
void ContextWrapper::setMirror(bool flag)
{
    if(!_initFlag)
        return;

    _globalContext.SetGlobalMirror(flag);
}

bool ContextWrapper::mirror()
{
    if(!_initFlag)
        return false;
    else
        return _globalContext.GetGlobalMirror() > 0;

}

///////////////////////////////////////////////////////////////////////////////
// callbacks

void XN_CALLBACK_TYPE ContextWrapper::newUserCb(xn::UserGenerator& generator, XnUserID user, void* cxt)
{
    ContextWrapper* context = static_cast<ContextWrapper*>(cxt);
    if(context == NULL)
        return;
    context->onNewUserCb(generator,user);
}

void XN_CALLBACK_TYPE ContextWrapper::lostUserCb(xn::UserGenerator& generator, XnUserID user, void* cxt)
{	
    ContextWrapper* context = static_cast<ContextWrapper*>(cxt);
    if(context == NULL)
        return;
    context->onLostUserCb(generator,user);
}

void XN_CALLBACK_TYPE ContextWrapper::startCalibrationCb(xn::SkeletonCapability& skeleton, XnUserID user, void* cxt)
{
    ContextWrapper* context = static_cast<ContextWrapper*>(cxt);
    if(context == NULL)
        return;
    context->onStartCalibrationCb(skeleton,user);
}

void XN_CALLBACK_TYPE ContextWrapper::endCalibrationCb(xn::SkeletonCapability& skeleton, XnUserID user, XnBool bSuccess, void* cxt)
{
    ContextWrapper* context = static_cast<ContextWrapper*>(cxt);
    if(context == NULL)
        return;
    context->onEndCalibrationCb(skeleton,user,bSuccess);
}

void XN_CALLBACK_TYPE ContextWrapper::startPoseCb(xn::PoseDetectionCapability& pose, const XnChar* strPose, XnUserID user, void* cxt)
{
    ContextWrapper* context = static_cast<ContextWrapper*>(cxt);
    if(context == NULL)
        return;
    context->onStartPoseCb(pose,strPose,user);
}

void XN_CALLBACK_TYPE ContextWrapper::endPoseCb(xn::PoseDetectionCapability& pose, const XnChar* strPose, XnUserID user, void* cxt)
{
    ContextWrapper* context = static_cast<ContextWrapper*>(cxt);
    if(context == NULL)
        return;
    context->onEndPoseCb(pose,strPose,user);
}

///////////////////////////////////////////////////////////////////////////////
// java virtual callbacks

void ContextWrapper::onNewUserCb(xn::UserGenerator& generator, XnUserID user)
{
    onNewUserCb(user);
}

void ContextWrapper::onLostUserCb(xn::UserGenerator& generator, XnUserID user)
{
    onLostUserCb(user);
}

void ContextWrapper::onStartCalibrationCb(xn::SkeletonCapability& skeleton, XnUserID user)
{
    onStartCalibrationCb(user);
}

void ContextWrapper::onEndCalibrationCb(xn::SkeletonCapability& skeleton, XnUserID user, XnBool bSuccess)
{
    onEndCalibrationCb(user,bSuccess > 0);
}

void ContextWrapper::onStartPoseCb(xn::PoseDetectionCapability& pose, const XnChar* strPose, XnUserID user)
{
    onStartPoseCb(strPose,user);
}

void ContextWrapper::onEndPoseCb(xn::PoseDetectionCapability& pose, const XnChar* strPose, XnUserID user)
{
    onEndPoseCb(strPose,user);
}

// virtual methods for the java class which inherits this class
void  ContextWrapper::onNewUserCb(unsigned int userId){;}
void  ContextWrapper::onLostUserCb(unsigned int userId){;}

void  ContextWrapper::onStartCalibrationCb(unsigned int userId){;}
void  ContextWrapper::onEndCalibrationCb(unsigned int userId,bool successFlag){;}

void  ContextWrapper::onStartPoseCb(const char* strPose, unsigned int user){;}
void  ContextWrapper::onEndPoseCb(const char* strPose, unsigned int user){;}

// callback hands
void XN_CALLBACK_TYPE ContextWrapper::createHandsCb(xn::HandsGenerator& generator, XnUserID nId, const XnPoint3D* pPosition, XnFloat fTime, void* cxt)
{
    ContextWrapper* context = static_cast<ContextWrapper*>(cxt);
    if(context == NULL)
        return;
    context->onCreateHandsCb(generator, nId, pPosition, fTime);
}

void XN_CALLBACK_TYPE ContextWrapper::updateHandsCb(xn::HandsGenerator& generator, XnUserID nId, const XnPoint3D* pPosition, XnFloat fTime, void* cxt)
{
    ContextWrapper* context = static_cast<ContextWrapper*>(cxt);
    if(context == NULL)
        return;
    context->onUpdateHandsCb(generator, nId, pPosition, fTime);
}

void XN_CALLBACK_TYPE ContextWrapper::destroyHandsCb(xn::HandsGenerator& generator, XnUserID nId,XnFloat fTime, void* cxt)
{
    ContextWrapper* context = static_cast<ContextWrapper*>(cxt);
    if(context == NULL)
        return;
    context->onDestroyHandsCb(generator, nId, fTime);
}


void ContextWrapper::onCreateHandsCb(xn::HandsGenerator& generator, XnUserID nId, const XnPoint3D* pPosition, XnFloat fTime)
{
    onCreateHandsCb(nId,pPosition,fTime);
}
void ContextWrapper::onCreateHandsCb(unsigned int nId, const XnPoint3D* pPosition, float fTime){;}

void ContextWrapper::onUpdateHandsCb(xn::HandsGenerator& generator, XnUserID nId, const XnPoint3D* pPosition, XnFloat fTime)
{
    onUpdateHandsCb(nId,pPosition,fTime);
}
void ContextWrapper::onUpdateHandsCb(unsigned int nId, const XnPoint3D* pPosition, float fTime){;}

void ContextWrapper::onDestroyHandsCb(xn::HandsGenerator& generator, XnUserID nId, XnFloat fTime)
{
    onDestroyHandsCb(nId,fTime);
}
void ContextWrapper::onDestroyHandsCb(unsigned int nId, float fTime){;}


// callback gesture
void XN_CALLBACK_TYPE ContextWrapper::recognizeGestureCb(xn::GestureGenerator& generator,const XnChar* strGesture, const XnPoint3D* pIdPosition,const XnPoint3D* pEndPosition, void* cxt)
{
    ContextWrapper* context = static_cast<ContextWrapper*>(cxt);
    if(context == NULL)
        return;

    context->onRecognizeGestureCb(generator,strGesture,pIdPosition,pEndPosition);
}

void XN_CALLBACK_TYPE ContextWrapper::progressGestureCb(xn::GestureGenerator& generator,const XnChar* strGesture, const XnPoint3D* pPosition,XnFloat fProgress, void* cxt)
{
    ContextWrapper* context = static_cast<ContextWrapper*>(cxt);
    if(context == NULL)
        return;
    context->onProgressGestureCb(generator,strGesture,pPosition,fProgress);
}


void ContextWrapper::onRecognizeGestureCb(xn::GestureGenerator& generator,const XnChar* strGesture, const XnPoint3D* pIdPosition,const XnPoint3D* pEndPosition)
{
    onRecognizeGestureCb(strGesture,pIdPosition,pEndPosition);
}
void ContextWrapper::onRecognizeGestureCb(const char* strGesture, const XnPoint3D* pIdPosition,const XnPoint3D* pEndPosition){;}

void ContextWrapper::onProgressGestureCb(xn::GestureGenerator& generator,const XnChar* strGesture, const XnPoint3D* pPosition,XnFloat fProgress)
{
    onProgressGestureCb(strGesture,pPosition,fProgress);
}
void ContextWrapper::onProgressGestureCb(const char* strGesture, const XnPoint3D* pPosition,float fProgress){;}


int ContextWrapper::getNodeType(int internalType)
{
    if(internalType & Node_Depth)
        return XN_NODE_TYPE_DEPTH;
    else if(internalType & Node_Image)
        return XN_NODE_TYPE_IMAGE;
    else if(internalType & Node_Ir)
        return XN_NODE_TYPE_IR;
    else if(internalType & Node_Scene)
        return XN_NODE_TYPE_SCENE;
    else if(internalType & Node_User)
        return XN_NODE_TYPE_USER;
    else if(internalType & Node_Hands)
        return XN_NODE_TYPE_HANDS;
    else if(internalType & Node_Gesture)
        return XN_NODE_TYPE_GESTURE;
    else if(internalType & Node_Recorder)
        return XN_NODE_TYPE_RECORDER;
    else if(internalType & Node_Player)
        return XN_NODE_TYPE_PLAYER;
    else
        return 0;
}

xn::ProductionNode* ContextWrapper::getNode(int internalType)
{
    if(internalType & Node_Depth)
        return &_depth;
    else if(internalType & Node_Image)
        return &_image;
    else if(internalType & Node_Ir)
        return &_ir;
    else if(internalType & Node_Scene)
        return &_sceneAnalyzer;
    else if(internalType & Node_User)
        return &_userGenerator;
    else if(internalType & Node_Hands)
        return &_handsGenerator;
    else if(internalType & Node_Gesture)
        return &_gestureGenerator;
    else if(internalType & Node_Recorder)
        return &_recorder;
    else if(internalType & Node_Player)
        return NULL;
    else
        return NULL;
}

///////////////////////////////////////////////////////////////////////////////
// XnVSessionManager helper methods

void XN_CALLBACK_TYPE ContextWrapper::onStartSessionCb(const XnPoint3D& ptPosition, void* cxt)
{
    ContextWrapper* context = static_cast<ContextWrapper*>(cxt);
    if(context == NULL)
        return;
    context->onStartSessionCb(ptPosition);
}

void XN_CALLBACK_TYPE ContextWrapper::onEndSessionCb(void* cxt)
{
    ContextWrapper* context = static_cast<ContextWrapper*>(cxt);
    if(context == NULL)
        return;
    context->onEndSessionCb();
}

void XN_CALLBACK_TYPE ContextWrapper::onFocusSessionCb(const XnChar* strFocus, const XnPoint3D& ptPosition, XnFloat fProgress, void* cxt)
{
    ContextWrapper* context = static_cast<ContextWrapper*>(cxt);
    if(context == NULL)
        return;
    context->onFocusSessionCb(strFocus,ptPosition,fProgress);
}

void ContextWrapper::onStartSessionCb(const XnPoint3D& ptPosition)
{}

void ContextWrapper::onEndSessionCb()
{}

void ContextWrapper::onFocusSessionCb(const XnChar* strFocus, const XnPoint3D& ptPosition, XnFloat fProgress)
{}


XnVSessionManager* ContextWrapper::createSessionManager(const XnChar* strUseAsFocus, const XnChar* strUseAsQuickRefocus,
                                                        xn::HandsGenerator*		pTracker,
                                                        xn::GestureGenerator*	pFocusGenerator,
                                                        xn::GestureGenerator*	pQuickRefocusGenerator)
{
    if(!_initFlag)
        return NULL;

    XnVSessionManager* ret = new XnVSessionManager();
    _rc = ret->Initialize(&_globalContext,
                          strUseAsFocus,strUseAsQuickRefocus,
                          pTracker,
                          pFocusGenerator,
                          pQuickRefocusGenerator);

    // set callbacks
    ret->RegisterSession(this, onStartSessionCb, onEndSessionCb, onFocusSessionCb);

    _sessionManagerList.push_back(ret);
    return ret;
}


void ContextWrapper::update(XnVSessionManager* sessionManager)
{
    if((!_initFlag && sessionManager == NULL) )/*||
    _threadMode == RunMode_MultiThreaded)*/
        // the session manager will be updated in the thread function
        return;

    sessionManager->Update(&_globalContext);
}

///////////////////////////////////////////////////////////////////////////
// threading

void ContextWrapper::run()
{
    _threadRun = true;

    while(_threadRun)
    {
        updateSub();

        boost::this_thread::sleep(boost::posix_time::millisec(1));
        //std::cout <<"." << std::flush;
    }

}
