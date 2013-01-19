/* ----------------------------------------------------------------------------
 * NITE_Helpers
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

#ifndef _NITE_HELPERS_H_
#define _NITE_HELPERS_H_

#ifdef WIN32
	#pragma warning( disable : 4251 )	// disable warnings from NITE
	#pragma warning( disable : 4275 )
#endif

#include <map>
#include <vector>

// java
#include <jni.h>

#include <XnOpenNI.h>
#include <XnCppWrapper.h>
#include <XnVNite.h>

// callback helper for nite
void XN_CALLBACK_TYPE OnSessionStartCB(const XnPoint3D& ptPosition, void* UserCxt);
void XN_CALLBACK_TYPE OnSessionEndCB(void* UserCxt);
void XN_CALLBACK_TYPE OnFocusStartDetectedCB(const XnChar* strFocus, const XnPoint3D& ptPosition, XnFloat fProgress, void* UserCxt);

    
void XN_CALLBACK_TYPE OnCircleCB(XnFloat fTimes, XnBool bConfident, const XnVCircle* pCircle, void* pUserCxt);

void XN_CALLBACK_TYPE OnPushCB(XnFloat fVelocity, XnFloat fAngle, void* pUserCxt);
void XN_CALLBACK_TYPE OnStabilizedCB(XnFloat fVelocity, void* pUserCxt);

//direction will be one of NITE_DIRECTION_XX
void XN_CALLBACK_TYPE OnSwipeCB(XnVDirection eDir, XnFloat fVelocity, XnFloat fAngle, void* pUserCxt);
void XN_CALLBACK_TYPE OnSwipeUpCB( XnFloat fVelocity, XnFloat fAngle, void* pUserCxt);
void XN_CALLBACK_TYPE OnSwipeDownCB(XnFloat fVelocity, XnFloat fAngle, void* pUserCxt);
void XN_CALLBACK_TYPE OnSwipeLeftCB(XnFloat fVelocity, XnFloat fAngle, void* pUserCxt);
void XN_CALLBACK_TYPE OnSwipeRightCB(XnFloat fVelocity, XnFloat fAngle, void* pUserCxt);

///////////////////////////////////////////////////////////////////////////////
// JavaCbContainer

class JavaCbContainer
{
public:
	JavaCbContainer(JNIEnv *env, jobject  obj,void* cClass)
	{
		_env = env;
		_obj = _env->NewGlobalRef(obj);
		_cClass = cClass;

		_env->GetJavaVM(&_globalJvm);

	}
	
	~JavaCbContainer()
	{
		_env->DeleteGlobalRef(_obj);
	}

	JNIEnv*	env() { return _env; }
	jobject obj() { return _obj; }
	void*	ptr() { return _cClass; }

	JavaVM* gJvm() { return _globalJvm;}

protected:
	JavaVM *	_globalJvm;

	JNIEnv*		_env;
	jobject		_obj;
	void*		_cClass;

};

typedef std::vector<JavaCbContainer*>		JavaCbContainerList;
typedef std::map<void*,JavaCbContainer*>	JavaCbContainerMap;

#endif // _NITE_HELPERS_H_