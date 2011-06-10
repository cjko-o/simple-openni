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


#include <iostream>

#include "NITE_Helpers.h"

///////////////////////////////////////////////////////////////////////////////
// callback macros
//#define		NITE_DEBUG_CALLBACK

#define		NITE_VIRTUAL_CALLBACK_FUNC(Class,FuncName) On_##Class##_##FuncName##CB

#define		NITE_JNI_CALLBACK_DECL(Class,FuncName) \
JNIEXPORT void JNICALL Java_SimpleOpenNI_##Class##_Register##FuncName##Sub(JNIEnv *env, jobject  obj, jobject objCb, jlong ptr);

#define		NITE_JNI_CALLBACK(Class,FuncName) \
JNIEXPORT void JNICALL Java_SimpleOpenNI_##Class##_Register##FuncName##Sub(JNIEnv *env, jobject  obj, jobject objCb, jlong ptr) \
{ \
	Class * p = static_cast< Class *>((void*)ptr); \
	if(p == NULL) \
		return; \
	JavaCbContainer* cbContainer = new JavaCbContainer(env, \
													   objCb, \
													   (void*)ptr); \
	_cbContainerList.push_back(cbContainer); \
	p->Register##FuncName(cbContainer, NITE_VIRTUAL_CALLBACK_FUNC(Class,FuncName) ); \
} \



///////////////////////////////////////////////////////////////////////////////
// session callbacks

void XN_CALLBACK_TYPE NITE_VIRTUAL_CALLBACK_FUNC(XnVSessionListener,SessionStart)	(const XnPoint3D& ptPosition, void* UserCxt)
{
	XnVSessionListener* p = static_cast<XnVSessionListener*>(UserCxt);
	if(p == NULL)
		return;
	p->OnSessionStart(ptPosition);
}

void XN_CALLBACK_TYPE NITE_VIRTUAL_CALLBACK_FUNC(XnVSessionListener,SessionEnd)	(void* UserCxt)
{
	XnVSessionListener* p = static_cast<XnVSessionListener*>(UserCxt);
	if(p == NULL)
		return;
	p->OnSessionEnd();
}

void XN_CALLBACK_TYPE NITE_VIRTUAL_CALLBACK_FUNC(XnVSessionListener,FocusStartDetected)	(const XnChar* strFocus, const XnPoint3D& ptPosition, XnFloat fProgress, void* UserCxt)
{
	XnVSessionListener* p = static_cast<XnVSessionListener*>(UserCxt);
	if(p == NULL)
		return;
	p->OnFocusStartDetected(strFocus,ptPosition,fProgress);
}

///////////////////////////////////////////////////////////////////////////////
// XnVPointControl

void XN_CALLBACK_TYPE NITE_VIRTUAL_CALLBACK_FUNC(XnVPointControl,PointCreate)	(const XnVHandPointContext* pContext, void* UserCxt)
{
	JavaCbContainer* p = static_cast<JavaCbContainer*>(UserCxt);
	if(p == NULL)
		return;

	JNIEnv* env = p->env();
	if (! p->gJvm()->AttachCurrentThread((void**)&env, NULL)) 
	{
		jclass		localClass = env->GetObjectClass(p->obj());
		jmethodID	mid = NULL;

		mid = env->GetMethodID(localClass,
							   "onPointCreate",
							   "(LSimpleOpenNI/XnVHandPointContext;)V");

		if(mid != 0)
		{
			// wrap the c++ class in a java class
			jclass		pointContextJClass = env->FindClass( "SimpleOpenNI/XnVHandPointContext" );  
			jmethodID	pointContextMethod = env->GetMethodID( pointContextJClass, "<init>","(JZ)V");
			
			// init the class, pass the ptr	
			jobject	pointContext = env->NewObject(pointContextJClass,pointContextMethod,
					 							 (jlong)pContext,(jboolean)false);

			// call the java method
			env->CallVoidMethod(p->obj(), 
								mid,
								pointContext);
				
			env->DeleteLocalRef(pointContext);
			env->DeleteLocalRef(pointContextJClass);
		}
	}
}

void XN_CALLBACK_TYPE NITE_VIRTUAL_CALLBACK_FUNC(XnVPointControl,PointDestroy)	(XnUInt32 nID, void* UserCxt)
{
	JavaCbContainer* p = static_cast<JavaCbContainer*>(UserCxt);
	if(p == NULL)
		return;

	JNIEnv* env = p->env();
	if (! p->gJvm()->AttachCurrentThread((void**)&env, NULL)) 
	{
		jclass		localClass = env->GetObjectClass(p->obj());
		jmethodID	mid = NULL;

		mid = env->GetMethodID(localClass,
							   "onPointDestroy",
							   "(I)V");
							  // float,integer

		if(mid != 0)
		{
			// call the java method
			env->CallVoidMethod(p->obj(), 
								mid,
								(jint)nID);
		}
		
	}
}

void XN_CALLBACK_TYPE NITE_VIRTUAL_CALLBACK_FUNC(XnVPointControl,PointUpdate)	(const XnVHandPointContext* pContext, void* UserCxt)
{
	JavaCbContainer* p = static_cast<JavaCbContainer*>(UserCxt);
	if(p == NULL)
		return;

	JNIEnv* env = p->env();
	if (! p->gJvm()->AttachCurrentThread((void**)&env, NULL)) 
	{
		jclass		localClass = env->GetObjectClass(p->obj());
		jmethodID	mid = NULL;

		mid = env->GetMethodID(localClass,
							   "onPointUpdate",
							   "(LSimpleOpenNI/XnVHandPointContext;)V");

		if(mid != 0)
		{
			// wrap the c++ class in a java class
			jclass		pointContextJClass = env->FindClass( "SimpleOpenNI/XnVHandPointContext" );  
			jmethodID	pointContextMethod = env->GetMethodID( pointContextJClass, "<init>","(JZ)V");
			
			// init the class, pass the ptr	
			jobject	pointContext = env->NewObject(pointContextJClass,pointContextMethod,
					 							 (jlong)pContext,(jboolean)false);

			// call the java method
			env->CallVoidMethod(p->obj(), 
								mid,
								pointContext);
				
			env->DeleteLocalRef(pointContext);
			env->DeleteLocalRef(pointContextJClass);
		}
	}
}

void XN_CALLBACK_TYPE NITE_VIRTUAL_CALLBACK_FUNC(XnVPointControl,PrimaryPointCreate)	(const XnVHandPointContext* pContext,const XnPoint3D& ptFocus, void* UserCxt)
{
	JavaCbContainer* p = static_cast<JavaCbContainer*>(UserCxt);
	if(p == NULL)
		return;

	JNIEnv* env = p->env();
	if (! p->gJvm()->AttachCurrentThread((void**)&env, NULL)) 
	{
		jclass		localClass = env->GetObjectClass(p->obj());
		jmethodID	mid = NULL;

		mid = env->GetMethodID(localClass,
							   "onPrimaryPointCreate",
							   "(LSimpleOpenNI/XnVHandPointContext;LSimpleOpenNI/XnPoint3D;)V");
							   //"(LSimpleOpenNI/XnVHandPointContext;LSimpleOpenNI/XnVector3D;)V");

		if(mid != 0)
		{
			// wrap the c++ class in a java class
			jclass		pointContextJClass = env->FindClass( "SimpleOpenNI/XnVHandPointContext" );  
			jmethodID	pointContextMethod = env->GetMethodID( pointContextJClass, "<init>","(JZ)V");
			
			jobject	pointContext = env->NewObject(pointContextJClass,pointContextMethod,
					 							 (jlong)pContext,(jboolean)false);


			//jclass		pointFocusJClass = env->FindClass( "SimpleOpenNI/XnPoint3D" );  
			jclass		pointFocusJClass = env->FindClass( "SimpleOpenNI/XnPoint3D" );  
			jmethodID	pointFocusMethod = env->GetMethodID( pointFocusJClass, "<init>","(JZ)V");
			
			jobject	pointFocus = env->NewObject(pointFocusJClass,pointFocusMethod,
					 						   (jlong)&ptFocus,(jboolean)false);

			// call the java method
			env->CallVoidMethod(p->obj(), 
								mid,
								pointContext,pointFocus);
				
			env->DeleteLocalRef(pointFocus);
			env->DeleteLocalRef(pointFocusJClass);

			env->DeleteLocalRef(pointContext);
			env->DeleteLocalRef(pointContextJClass);
		}
	}
}

void XN_CALLBACK_TYPE NITE_VIRTUAL_CALLBACK_FUNC(XnVPointControl,PrimaryPointDestroy)	(XnUInt32 nID, void* UserCxt)
{
	JavaCbContainer* p = static_cast<JavaCbContainer*>(UserCxt);
	if(p == NULL)
		return;

	JNIEnv* env = p->env();
	if (! p->gJvm()->AttachCurrentThread((void**)&env, NULL)) 
	{
		jclass		localClass = env->GetObjectClass(p->obj());
		jmethodID	mid = NULL;

		mid = env->GetMethodID(localClass,
							   "onPrimaryPointDestroy",
							   "(I)V");
							  // float,integer

		if(mid != 0)
		{
			// call the java method
			env->CallVoidMethod(p->obj(), 
								mid,
								(jint)nID);
		}
		
	}
}


///////////////////////////////////////////////////////////////////////////////
// XnVPushDetector

void XN_CALLBACK_TYPE NITE_VIRTUAL_CALLBACK_FUNC(XnVPushDetector,Push)	(XnFloat fVelocity, XnFloat fAngle, void* pUserCxt)
{
    JavaCbContainer* p = static_cast<JavaCbContainer*>(pUserCxt);
    if(p == NULL)
        return;

    JNIEnv* env = p->env();
    if (! p->gJvm()->AttachCurrentThread((void**)&env, NULL))
    {
        jclass      localClass = env->GetObjectClass(p->obj());
        jmethodID   mid = NULL;

        mid = env->GetMethodID(localClass,
                               "onPush",
                               "(FF)V");
                              // float,float

        if(mid != 0)
        {
            // call the java method
            env->CallVoidMethod(p->obj(),
                                mid,
                                (jfloat)fVelocity,(jfloat)fAngle);
        }
    }
}
void XN_CALLBACK_TYPE NITE_VIRTUAL_CALLBACK_FUNC(XnVPushDetector,Stabilized)	(XnFloat fVelocity, void* pUserCxt)
{
    JavaCbContainer* p = static_cast<JavaCbContainer*>(pUserCxt);
    if(p == NULL)
        return;

    JNIEnv* env = p->env();
    if (! p->gJvm()->AttachCurrentThread((void**)&env, NULL))
    {
        jclass      localClass = env->GetObjectClass(p->obj());
        jmethodID   mid = NULL;

        mid = env->GetMethodID(localClass,
                               "onPush",
                               "(F)V");
                              // float,float

        if(mid != 0)
        {
            // call the java method
            env->CallVoidMethod(p->obj(),
                                mid,
                                (jfloat)fVelocity);
        }
    }
}

///////////////////////////////////////////////////////////////////////////////
// XnVSwipeDetector

void doTheSwipe(XnFloat fVelocity, XnFloat fAngle, void* pUserCxt, const char* direction)
{
    JavaCbContainer* p = static_cast<JavaCbContainer*>(pUserCxt);
    if(p == NULL)
        return;

    JNIEnv* env = p->env();
    if (! p->gJvm()->AttachCurrentThread((void**)&env, NULL))
    {
        jclass      localClass = env->GetObjectClass(p->obj());
        jmethodID   mid = NULL;

        mid = env->GetMethodID(localClass,
                               direction,
                               "(FF)V");
                              // float,float

        if(mid != 0)
        {
            // call the java method
            env->CallVoidMethod(p->obj(),
                                mid,
                                (jfloat)fVelocity,(jfloat)fAngle);
        }
    }

}

void XN_CALLBACK_TYPE NITE_VIRTUAL_CALLBACK_FUNC(XnVSwipeDetector,SwipeUp)	(XnFloat fVelocity, XnFloat fAngle, void* pUserCxt)
{
    doTheSwipe(fVelocity, fAngle, pUserCxt, "onSwipeUp");
}
void XN_CALLBACK_TYPE NITE_VIRTUAL_CALLBACK_FUNC(XnVSwipeDetector,SwipeDown)	(XnFloat fVelocity, XnFloat fAngle, void* pUserCxt)
{
    doTheSwipe(fVelocity, fAngle, pUserCxt, "onSwipeDown");
}
void XN_CALLBACK_TYPE NITE_VIRTUAL_CALLBACK_FUNC(XnVSwipeDetector,SwipeLeft)	(XnFloat fVelocity, XnFloat fAngle, void* pUserCxt)
{
    doTheSwipe(fVelocity, fAngle, pUserCxt, "onSwipeLeft");
}
void XN_CALLBACK_TYPE NITE_VIRTUAL_CALLBACK_FUNC(XnVSwipeDetector,SwipeRight)	(XnFloat fVelocity, XnFloat fAngle, void* pUserCxt)
{
    doTheSwipe(fVelocity, fAngle, pUserCxt, "onSwipeRight");
}

void  XN_CALLBACK_TYPE NITE_VIRTUAL_CALLBACK_FUNC(XnVSwipeDetector,Swipe)	(XnVDirection eDir, XnFloat fVelocity, XnFloat fAngle, void* pUserCxt)
{
    JavaCbContainer* p = static_cast<JavaCbContainer*>(pUserCxt);
    if(p == NULL)
        return;

    JNIEnv* env = p->env();
    if (! p->gJvm()->AttachCurrentThread((void**)&env, NULL))
    {
        jclass      localClass = env->GetObjectClass(p->obj());
        jmethodID   mid = NULL;

        mid = env->GetMethodID(localClass,
                               "onSwipe",
                               "(IFF)V");
                              // int-XnVDirection,float,float

        if(mid != 0)
        {
            // call the java method
            env->CallVoidMethod(p->obj(),
                                mid,
                                (jint)eDir,(jfloat)fVelocity,(jfloat)fAngle);
        }
    }

}


///////////////////////////////////////////////////////////////////////////////
// XnVCircleDetector

void XN_CALLBACK_TYPE NITE_VIRTUAL_CALLBACK_FUNC(XnVCircleDetector,Circle)	(XnFloat fTimes, XnBool bConfident, const XnVCircle* pCircle, void* UserCxt)
{
	JavaCbContainer* p = static_cast<JavaCbContainer*>(UserCxt);
	if(p == NULL)
		return;

	JNIEnv* env = p->env();
	if (! p->gJvm()->AttachCurrentThread((void**)&env, NULL)) 
	{
		jclass		localClass = env->GetObjectClass(p->obj());
		jmethodID	mid = NULL;

		mid = env->GetMethodID(localClass,
							   "onCircle",
							   "(FZLSimpleOpenNI/XnVCircle;)V");
							  // float,boolean,XnVCircle

		if(mid != 0)
		{
			// wrap the c++ class in a java class
			jclass		circleJClass = env->FindClass( "SimpleOpenNI/XnVCircle" );  
			jmethodID	circleMethod = env->GetMethodID( circleJClass, "<init>","(JZ)V");
			
			// init the class, pass the ptr	
			jobject	circle = env->NewObject(circleJClass,circleMethod,
					 					    (jlong)pCircle,(jboolean)false);

			// call the java method
			env->CallVoidMethod(p->obj(), 
								mid,
								(jfloat)fTimes,(jboolean)bConfident,
								circle);
				
			env->DeleteLocalRef(circle);
			env->DeleteLocalRef(circleJClass);
		}
	}
}

void XN_CALLBACK_TYPE NITE_VIRTUAL_CALLBACK_FUNC(XnVCircleDetector,NoCircle)	(XnFloat fLastValue, XnVCircleDetector::XnVNoCircleReason eReason, void *UserCxt)
{
	JavaCbContainer* p = static_cast<JavaCbContainer*>(UserCxt);
	if(p == NULL)
		return;

	JNIEnv* env = p->env();
	if (! p->gJvm()->AttachCurrentThread((void**)&env, NULL)) 
	{
		jclass		localClass = env->GetObjectClass(p->obj());
		jmethodID	mid = NULL;

		mid = env->GetMethodID(localClass,
							   "onNoCircle",
							   "(FI)V");
							  // float,integer

		if(mid != 0)
		{
			// call the java method
			env->CallVoidMethod(p->obj(), 
								mid,
								(jfloat)fLastValue,
								(jint)eReason);
		}
		
	}
}

///////////////////////////////////////////////////////////////////////////////
// XnVSelectableSlider1D Java method export

void XN_CALLBACK_TYPE NITE_VIRTUAL_CALLBACK_FUNC(XnVSelectableSlider1D,ItemHover)	(XnInt32 nItemIndex, void* pUserCxt)
{
	JavaCbContainer* p = static_cast<JavaCbContainer*>(pUserCxt);
	if(p == NULL)
		return;

	JNIEnv* env = p->env();
	if (! p->gJvm()->AttachCurrentThread((void**)&env, NULL)) 
	{
		jclass		localClass = env->GetObjectClass(p->obj());
		jmethodID	mid = NULL;

		mid = env->GetMethodID(localClass,
							   "onItemHover",
							   "(I)V");
							  // integer,integer/void

		if(mid != 0)
		{
			// call the java method
			env->CallVoidMethod(p->obj(), 
								mid,
								(jint)nItemIndex);
		}
		
	}
}

void XN_CALLBACK_TYPE NITE_VIRTUAL_CALLBACK_FUNC(XnVSelectableSlider1D,ItemSelect)	(XnInt32 nItemIndex, XnVDirection eDir, void* pUserCxt)
{
	JavaCbContainer* p = static_cast<JavaCbContainer*>(pUserCxt);
	if(p == NULL)
		return;

	JNIEnv* env = p->env();
	if (! p->gJvm()->AttachCurrentThread((void**)&env, NULL)) 
	{
		jclass		localClass = env->GetObjectClass(p->obj());
		jmethodID	mid = NULL;

		mid = env->GetMethodID(localClass,
							   "onItemSelect",
							   "(II)V");
							  // int,int,int-XnVDirection

		if(mid != 0)
		{
			// call the java method
			env->CallVoidMethod(p->obj(), 
								mid,
								(jint)nItemIndex,(jint)eDir);
		}
	}
}

void XN_CALLBACK_TYPE NITE_VIRTUAL_CALLBACK_FUNC(XnVSelectableSlider1D,OffAxisMovement)	(XnVDirection eDir, void* pUserCxt)
{
	JavaCbContainer* p = static_cast<JavaCbContainer*>(pUserCxt);
	if(p == NULL)
		return;

	JNIEnv* env = p->env();
	if (! p->gJvm()->AttachCurrentThread((void**)&env, NULL)) 
	{
		jclass		localClass = env->GetObjectClass(p->obj());
		jmethodID	mid = NULL;

		mid = env->GetMethodID(localClass,
							   "onOffAxisMovement",
							   "(I)V");
							  // int-XnVDirection

		if(mid != 0)
		{
			// call the java method
			env->CallVoidMethod(p->obj(), 
								mid,
								(jint)eDir);
		}
	}
}

void XN_CALLBACK_TYPE NITE_VIRTUAL_CALLBACK_FUNC(XnVSelectableSlider1D,ValueChange)	(XnFloat fValue, void* pUserCxt)
{
	JavaCbContainer* p = static_cast<JavaCbContainer*>(pUserCxt);
	if(p == NULL)
		return;

	JNIEnv* env = p->env();
	if (! p->gJvm()->AttachCurrentThread((void**)&env, NULL)) 
	{
		jclass		localClass = env->GetObjectClass(p->obj());
		jmethodID	mid = NULL;

		mid = env->GetMethodID(localClass,
							   "onValueChange",
							   "(F)V");
							  // float,float

		if(mid != 0)
		{
			// call the java method
			env->CallVoidMethod(p->obj(), 
								mid,
								(jfloat)fValue);
		}
	}
}

void XN_CALLBACK_TYPE NITE_VIRTUAL_CALLBACK_FUNC(XnVSelectableSlider1D,Scroll)	(XnFloat fScrollValue, void* pUserCxt)
{
	JavaCbContainer* p = static_cast<JavaCbContainer*>(pUserCxt);
	if(p == NULL)
		return;

	JNIEnv* env = p->env();
	if (! p->gJvm()->AttachCurrentThread((void**)&env, NULL)) 
	{
		jclass		localClass = env->GetObjectClass(p->obj());
		jmethodID	mid = NULL;

		mid = env->GetMethodID(localClass,
							   "onScroll",
							   "(F)V");
							  // float,float

		if(mid != 0)
		{
			// call the java method
			env->CallVoidMethod(p->obj(), 
								mid,
								(jfloat)fScrollValue);
		}
	}
}



///////////////////////////////////////////////////////////////////////////////
// XnVSelectableSlider2D Java method export

void XN_CALLBACK_TYPE NITE_VIRTUAL_CALLBACK_FUNC(XnVSelectableSlider2D,ItemHover)	(XnInt32 nXIndex, XnInt32 nYIndex, void* pUserCxt)
{
	JavaCbContainer* p = static_cast<JavaCbContainer*>(pUserCxt);
	if(p == NULL)
		return;

	JNIEnv* env = p->env();
	if (! p->gJvm()->AttachCurrentThread((void**)&env, NULL)) 
	{
		jclass		localClass = env->GetObjectClass(p->obj());
		jmethodID	mid = NULL;

		mid = env->GetMethodID(localClass,
							   "onItemHover",
							   "(II)V");
							  // integer,integer/void

		if(mid != 0)
		{
			// call the java method
			env->CallVoidMethod(p->obj(), 
								mid,
								(jint)nXIndex,
								(jint)nYIndex);
		}
		
	}
}

void XN_CALLBACK_TYPE NITE_VIRTUAL_CALLBACK_FUNC(XnVSelectableSlider2D,ItemSelect)	(XnInt32 nXIndex, XnInt32 nYIndex, XnVDirection eDir, void* pUserCxt)
{
	JavaCbContainer* p = static_cast<JavaCbContainer*>(pUserCxt);
	if(p == NULL)
		return;

	JNIEnv* env = p->env();
	if (! p->gJvm()->AttachCurrentThread((void**)&env, NULL)) 
	{
		jclass		localClass = env->GetObjectClass(p->obj());
		jmethodID	mid = NULL;

		mid = env->GetMethodID(localClass,
							   "onItemSelect",
							   "(III)V");
							  // int,int,int-XnVDirection

		if(mid != 0)
		{
			// call the java method
			env->CallVoidMethod(p->obj(), 
								mid,
								(jint)nXIndex,(jint)nYIndex,(jint)eDir);
		}
	}
}

void XN_CALLBACK_TYPE NITE_VIRTUAL_CALLBACK_FUNC(XnVSelectableSlider2D,OffAxisMovement)		(XnVDirection eDir, void* pUserCxt)
{
	JavaCbContainer* p = static_cast<JavaCbContainer*>(pUserCxt);
	if(p == NULL)
		return;

	JNIEnv* env = p->env();
	if (! p->gJvm()->AttachCurrentThread((void**)&env, NULL)) 
	{
		jclass		localClass = env->GetObjectClass(p->obj());
		jmethodID	mid = NULL;

		mid = env->GetMethodID(localClass,
							   "onOffAxisMovement",
							   "(I)V");
							  // int-XnVDirection

		if(mid != 0)
		{
			// call the java method
			env->CallVoidMethod(p->obj(), 
								mid,
								(jint)eDir);
		}
	}
}

void XN_CALLBACK_TYPE NITE_VIRTUAL_CALLBACK_FUNC(XnVSelectableSlider2D,ValueChange)	(XnFloat fXValue, XnFloat fYValue, void* pUserCxt)
{
	JavaCbContainer* p = static_cast<JavaCbContainer*>(pUserCxt);
	if(p == NULL)
		return;

	JNIEnv* env = p->env();
	if (! p->gJvm()->AttachCurrentThread((void**)&env, NULL)) 
	{
		jclass		localClass = env->GetObjectClass(p->obj());
		jmethodID	mid = NULL;

		mid = env->GetMethodID(localClass,
							   "onValueChange",
							   "(FF)V");
							  // float,float

		if(mid != 0)
		{
			// call the java method
			env->CallVoidMethod(p->obj(), 
								mid,
								(jfloat)fXValue,(jfloat)fYValue);
		}
	}
}

void XN_CALLBACK_TYPE NITE_VIRTUAL_CALLBACK_FUNC(XnVSelectableSlider2D,Scroll)	(XnFloat fXValue, XnFloat fYValue, void* pUserCxt)
{
	JavaCbContainer* p = static_cast<JavaCbContainer*>(pUserCxt);
	if(p == NULL)
		return;

	JNIEnv* env = p->env();
	if (! p->gJvm()->AttachCurrentThread((void**)&env, NULL)) 
	{
		jclass		localClass = env->GetObjectClass(p->obj());
		jmethodID	mid = NULL;

		mid = env->GetMethodID(localClass,
							   "onScroll",
							   "(FF)V");
							  // float,float

		if(mid != 0)
		{
			// call the java method
			env->CallVoidMethod(p->obj(), 
								mid,
								(jfloat)fXValue,(jfloat)fYValue);
		}
	}
}


///////////////////////////////////////////////////////////////////////////////
// Java method export for the callback

JavaCbContainerList _cbContainerList;


#ifdef __cplusplus
extern "C" {
#endif


///////////////////////////////////////////////////////////////////////////////
// XnVPointControl Java method export 

NITE_JNI_CALLBACK(XnVPointControl,PointCreate)	
NITE_JNI_CALLBACK(XnVPointControl,PointDestroy)	
NITE_JNI_CALLBACK(XnVPointControl,PointUpdate)	


NITE_JNI_CALLBACK(XnVPointControl,PrimaryPointCreate)	
NITE_JNI_CALLBACK(XnVPointControl,PrimaryPointDestroy)	

///////////////////////////////////////////////////////////////////////////////
// XnVPushDetector Java method export

NITE_JNI_CALLBACK(XnVPushDetector,Push)
NITE_JNI_CALLBACK(XnVPushDetector,Stabilized)

///////////////////////////////////////////////////////////////////////////////
// XnVSwipeDetector Java method export

NITE_JNI_CALLBACK(XnVSwipeDetector,SwipeUp)
NITE_JNI_CALLBACK(XnVSwipeDetector,SwipeDown)
NITE_JNI_CALLBACK(XnVSwipeDetector,SwipeLeft)
NITE_JNI_CALLBACK(XnVSwipeDetector,SwipeRight)
NITE_JNI_CALLBACK(XnVSwipeDetector,Swipe)


///////////////////////////////////////////////////////////////////////////////
// XnVCircleDetector Java method export

NITE_JNI_CALLBACK(XnVCircleDetector,Circle)	
NITE_JNI_CALLBACK(XnVCircleDetector,NoCircle)	


///////////////////////////////////////////////////////////////////////////////
// XnVSelectableSlider1D Java method export

NITE_JNI_CALLBACK(XnVSelectableSlider1D,ItemHover)	
NITE_JNI_CALLBACK(XnVSelectableSlider1D,Scroll)	
NITE_JNI_CALLBACK(XnVSelectableSlider1D,ValueChange)	
NITE_JNI_CALLBACK(XnVSelectableSlider1D,ItemSelect)	
NITE_JNI_CALLBACK(XnVSelectableSlider1D,OffAxisMovement)

///////////////////////////////////////////////////////////////////////////////
// XnVSelectableSlider2D Java method export

NITE_JNI_CALLBACK(XnVSelectableSlider2D,ItemHover)	
NITE_JNI_CALLBACK(XnVSelectableSlider2D,Scroll)	
NITE_JNI_CALLBACK(XnVSelectableSlider2D,ValueChange)	
NITE_JNI_CALLBACK(XnVSelectableSlider2D,ItemSelect)	
NITE_JNI_CALLBACK(XnVSelectableSlider2D,OffAxisMovement)

#ifdef __cplusplus
}
#endif
