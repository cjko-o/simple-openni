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

#define		NITE_VIRTUAL_CALLBACK_FUNC(FuncName) On##FuncName##CB

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
	p->Register##FuncName(cbContainer, NITE_VIRTUAL_CALLBACK_FUNC(FuncName) ); \
} \



///////////////////////////////////////////////////////////////////////////////
// session callbacks

void XN_CALLBACK_TYPE NITE_VIRTUAL_CALLBACK_FUNC(SessionStart)(const XnPoint3D& ptPosition, void* UserCxt)
{
	XnVSessionListener* p = static_cast<XnVSessionListener*>(UserCxt);
	if(p == NULL)
		return;
	p->OnSessionStart(ptPosition);
}

void XN_CALLBACK_TYPE NITE_VIRTUAL_CALLBACK_FUNC(SessionEnd)(void* UserCxt)
{
	XnVSessionListener* p = static_cast<XnVSessionListener*>(UserCxt);
	if(p == NULL)
		return;
	p->OnSessionEnd();
}

void XN_CALLBACK_TYPE NITE_VIRTUAL_CALLBACK_FUNC(FocusStartDetected)(const XnChar* strFocus, const XnPoint3D& ptPosition, XnFloat fProgress, void* UserCxt)
{
	XnVSessionListener* p = static_cast<XnVSessionListener*>(UserCxt);
	if(p == NULL)
		return;
	p->OnFocusStartDetected(strFocus,ptPosition,fProgress);
}

///////////////////////////////////////////////////////////////////////////////
// XnVPointControl

void XN_CALLBACK_TYPE NITE_VIRTUAL_CALLBACK_FUNC(PointCreate)(const XnVHandPointContext* pContext, void* UserCxt)
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

void XN_CALLBACK_TYPE NITE_VIRTUAL_CALLBACK_FUNC(PointDestroy)(XnUInt32 nID, void* UserCxt)
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

void XN_CALLBACK_TYPE NITE_VIRTUAL_CALLBACK_FUNC(PointUpdate)(const XnVHandPointContext* pContext, void* UserCxt)
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

void XN_CALLBACK_TYPE NITE_VIRTUAL_CALLBACK_FUNC(PrimaryPointCreate)(const XnVHandPointContext* pContext,const XnPoint3D& ptFocus, void* UserCxt)
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

void XN_CALLBACK_TYPE NITE_VIRTUAL_CALLBACK_FUNC(PrimaryPointDestroy)(XnUInt32 nID, void* UserCxt)
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
// XnVCircleDetector

void XN_CALLBACK_TYPE NITE_VIRTUAL_CALLBACK_FUNC(Circle)(XnFloat fTimes, XnBool bConfident, const XnVCircle* pCircle, void* UserCxt)
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

void XN_CALLBACK_TYPE NITE_VIRTUAL_CALLBACK_FUNC(NoCircle)(XnFloat fLastValue, XnVCircleDetector::XnVNoCircleReason eReason, void *UserCxt)
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
// XnVCircleDetector Java method export

NITE_JNI_CALLBACK(XnVCircleDetector,Circle)	
NITE_JNI_CALLBACK(XnVCircleDetector,NoCircle)	

#ifdef __cplusplus
}
#endif
