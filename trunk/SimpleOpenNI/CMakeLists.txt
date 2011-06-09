# -----------------------------------------------------------------------------
# SimpleOpenNI 
# -----------------------------------------------------------------------------
# Processing Wrapper for the OpenNI/Kinect library
# prog:  Max Rheiner / Interaction Design / zhdk / http://iad.zhdk.ch/
# -----------------------------------------------------------------------------
#
#	this envVar should be set:
#		OPEN_NI_INCLUDE < set this on osx: export OPEN_NI_INCLUDE=...path
#		OPEN_NI_LIB 
#		JAVA_HOME
#
# -----------------------------------------------------------------------------
	
CMAKE_MINIMUM_REQUIRED(VERSION 2.8)

INCLUDE(CheckIncludeFiles)

PROJECT(SimpleOpenNI)

# -----------------------------------------------------------------------------
# check swig
FIND_PACKAGE(SWIG REQUIRED)
INCLUDE(${SWIG_USE_FILE})

# -----------------------------------------------------------------------------
# check java/jni
FIND_PACKAGE(Java REQUIRED)
FIND_PACKAGE(JNI REQUIRED)
INCLUDE_DIRECTORIES(${JAVA_INCLUDE_PATH})
INCLUDE_DIRECTORIES(${JAVA_INCLUDE_PATH2})
 
INCLUDE_DIRECTORIES(${CMAKE_CURRENT_SOURCE_DIR})
 
# -----------------------------------------------------------------------------
# java tools
IF(WIN32)
	SET(JAVA_RUNTIME2  $ENV{JAVA_HOME}/bin/java)
	SET(JAVA_ARCHIVE2  $ENV{JAVA_HOME}/bin/jar)
	SET(JAVA_COMPILE2  $ENV{JAVA_HOME}/bin/javac)
	SET(JAVA_DOC	   $ENV{JAVA_HOME}/bin/javadoc)
ELSE()
	# unix
	SET(JAVA_RUNTIME2  java)
	SET(JAVA_ARCHIVE2  jar)
	SET(JAVA_COMPILE2  javac)
	SET(JAVA_DOC	   javadoc)
ENDIF()

# -----------------------------------------------------------------------------
# boost
FIND_PACKAGE(Boost REQUIRED)
IF(Boost_INCLUDE_DIRS MATCHES "Boost_INCLUDE_DIR-NOTFOUND")
	MESSAGE("Boost should be set, for example:")
	MESSAGE("> cmake -DBOOST_ROOT=/usr/??? ..")	
ELSE()
	INCLUDE_DIRECTORIES ( ${Boost_INCLUDE_DIRS} )
	LINK_DIRECTORIES ( ${Boost_LIBRARY_DIRS} )
	message(${Boost_INCLUDE_DIRS})
	message(${Boost_LIBRARY_DIRS})
  
	IF(APPLE)
		# osx
		set(Boost_LIBRARIES  "boost_thread.a")
		set(Boost_LIBRARIES  "boost_filesystem.a")
	ELSE()
		# unix/linux,shared libs of boost should be installed
		set(Boost_LIBRARIES  "boost_thread")

	ENDIF()
ENDIF()
# -----------------------------------------------------------------------------
# swig 
SET(CMAKE_SWIG_FLAGS -package SimpleOpenNI)

INCLUDE_DIRECTORIES(${CMAKE_CURRENT_SOURCE_DIR}/include)

# -----------------------------------------------------------------------------
# openNI 
CHECK_INCLUDE_FILES("XnOS.h" HAVE_XNOS_H)
IF(NOT HAVE_XNOS_H)
	IF(NOT DEFINED OPEN_NI_INCLUDE)
		# env is not set
		SET(OPEN_NI_INCLUDE $ENV{OPEN_NI_INCLUDE})
		IF(NOT DEFINED OPEN_NI_INCLUDE)
			MESSAGE("OPEN_NI_INCLUDE should be set, for example:")
			MESSAGE("> cmake -DOPEN_NI_INCLUDE=/usr/??? ..")	
		ENDIF()
	ENDIF()
	INCLUDE_DIRECTORIES(${OPEN_NI_INCLUDE})
ENDIF()

	
# openNI lib	
FIND_LIBRARY(OPEN_NI_LIBRARY NAMES OpenNI PATHS ${OPEN_NI_LIB})

IF(NOT OPEN_NI_LIBRARY)
	#IF(NOT OPEN_NI_LIB)
		SET(OPEN_NI_LIB $ENV{OPEN_NI_LIB})
		IF(NOT DEFINED OPEN_NI_LIB)
			# env is not set
			MESSAGE("OPEN_NI_LIB should be set, for example:")
			MESSAGE("> cmake -DOPEN_NI_LIB=/usr/lib/??? ..")	
		ELSE()
			FIND_LIBRARY(OPEN_NI_LIBRARY NAMES OpenNI PATHS ${OPEN_NI_LIB})
		ENDIF()
	#ENDIF()
ENDIF()
	
SET(LIBS ${LIBS} ${OPEN_NI_LIBRARY})


# IF(DEFINED OPEN_NI_INCLUDE)
	# INCLUDE_DIRECTORIES(${OPEN_NI_INCLUDE})
# ELSE()
	# # check if the envvar is set
	# SET(OPEN_NI_INCLUDE $ENV{OPEN_NI_INCLUDE})
	# IF(DEFINED OPEN_NI_INCLUDE)
		# INCLUDE_DIRECTORIES(${OPEN_NI_INCLUDE})
	# ELSE()
		# MESSAGE("OPEN_NI_INCLUDE and OPEN_NI_LIB should be set, for example:")
		# MESSAGE("> cmake -DOPEN_NI_INCLUDE=/usr/???/ -DOPEN_NI_LIB=/usr/???/ .")	
	# ENDIF()
# ENDIF()

# #INCLUDE_DIRECTORIES($ENV{OPEN_NI_INCLUDE})
# FIND_LIBRARY(OPEN_NI_LIBRARY NAMES OpenNI PATHS $ENV{OPEN_NI_LIB})
# SET(LIBS ${LIBS} ${OPEN_NI_LIBRARY})

# -----------------------------------------------------------------------------
# NITE
CHECK_INCLUDE_FILES("XnVSessionManager.h" HAVE_NITE_H)
IF(NOT HAVE_NITE_H)
	# check for the nite file
	IF(NOT (DEFINED XN_NITE_INCLUDE AND DEFINED XN_NITE_LIB))
		# 
		IF(DEFINED XN_NITE_INSTALL_PATH)
			SET(XN_NITE_INCLUDE ${XN_NITE_INSTALL_PATH}/Include)
			SET(XN_NITE_LIB ${XN_NITE_INSTALL_PATH}/Lib)
		ELSE()
			# check if the envvar is set
			SET(XN_NITE_PATH $ENV{XN_NITE_INSTALL_PATH})
			IF(DEFINED XN_NITE_PATH)
				SET(XN_NITE_INCLUDE ${XN_NITE_PATH}/Include)
				SET(XN_NITE_LIB ${XN_NITE_PATH}/Lib)
			ELSE()
				MESSAGE("XN_NITE_INCLUDE and XN_NITE_LIB should be set, for example:")
				MESSAGE("> cmake -DXN_NITE_INCLUDE=/usr/??? -DXN_NITE_LIB=/usr/lib/??? ..")	
			ENDIF()
		ENDIF()
	ENDIF()
ENDIF()

INCLUDE_DIRECTORIES(${XN_NITE_INCLUDE})
FIND_LIBRARY(NITE_LIBRARY NAMES XnVNite PATHS ${XN_NITE_LIB})
SET(LIBS ${LIBS} ${NITE_LIBRARY})

# -----------------------------------------------------------------------------
# processing wrappers
SET(P5_WRAPPER ${CMAKE_CURRENT_SOURCE_DIR}/src/p5_src/)
SET(P5_WRAPPER_FILE ${CMAKE_CURRENT_SOURCE_DIR}/src/p5_src/SimpleOpenNI.java)

# processing core lib
# shoud use find_program
IF(WIN32)
	SET(P5_JAR "C:/Program Files (x86)/processing-1.2.1/lib/core.jar")	
ELSEIF(APPLE)
	SET(P5_JAR "/Applications/Processing.app/Contents/Resources/Java/core.jar")
ELSE()
	# unix/linux
	# SET(P5_JAR "/?")
	IF(NOT DEFINED P5_JAR)
		MESSAGE("Set P5_JAR to the folder where Processing installed the core.jar file, for example:")
		MESSAGE(FATAL_ERROR "> cmake -DP5_JAR=/usr/???/core.jar ..")	
	ENDIF()
ENDIF()

# -----------------------------------------------------------------------------
# eigen 3d template lib
IF(DEFINED EIGEN3D_INCLUDE)
	INCLUDE_DIRECTORIES(${EIGEN3D_INCLUDE})
ELSE()
	# check if the envvar is set
	SET(EIGEN3D_INCLUDE $ENV{EIGEN3D_INCLUDE})
	IF(DEFINED EIGEN3D_INCLUDE)
		INCLUDE_DIRECTORIES(${EIGEN3D_INCLUDE})
	ELSE()
		MESSAGE("EIGEN3D_INCLUDE should be set, for example:")
		MESSAGE("> cmake -DEIGEN3D_INCLUDE=/usr/??? ..")	
	ENDIF()
ENDIF()	



SET(SWIG_SOURCES 
src/SimpleOpenNI.i
src/ContextWrapper.cpp
src/NITE_Helpers.cpp
)

SET_SOURCE_FILES_PROPERTIES(${SWIG_SOURCES} PROPERTIES CPLUSPLUS ON)
#SET_SOURCE_FILES_PROPERTIES(${SWIG_SOURCES} PROPERTIES CMAKE_SWIG_FLAGS "-includeall")

# set the folder where the swig files should land
SET(CMAKE_SWIG_OUTDIR ${CMAKE_CURRENT_BINARY_DIR}/swig_src)
MAKE_DIRECTORY(${CMAKE_CURRENT_BINARY_DIR}/src)


SWIG_ADD_MODULE(SimpleOpenNI Java ${SWIG_SOURCES})
SWIG_LINK_LIBRARIES(SimpleOpenNI ${JAVA_LIBRARIES} ${JNI_LIBRARIES} ${Boost_LIBRARIES} ${LIBS})


ADD_CUSTOM_COMMAND(TARGET SimpleOpenNI
				   POST_BUILD
				   COMMAND cmake -E echo "-----------------------------"
				   COMMAND cmake -E echo "Compiling Java files..."
				   COMMAND cmake -E make_directory ./SimpleOpenNI
				   COMMAND cmake -E make_directory ${CMAKE_SWIG_OUTDIR}
				   #COMMAND cmake -E copy_directory ${P5_WRAPPER} ${CMAKE_SWIG_OUTDIR}
				   # cmake copy doesn't support wildcards, otherwise it just copies the hidden folder of svn, etc.
				   # doesn't works on windows backslash
				   COMMAND cp "${P5_WRAPPER}*.java" "${CMAKE_SWIG_OUTDIR}"
				   #COMMAND cmake -E copy ${P5_WRAPPER_FILE} ${CMAKE_SWIG_OUTDIR}
				   COMMAND ${JAVA_COMPILE2} -classpath ${P5_JAR} ${CMAKE_SWIG_OUTDIR}/*.java -d ./
				   COMMAND cmake -E echo "-----------------------------"
				   COMMAND cmake -E echo "Creating jar file..."
				   COMMAND ${JAVA_ARCHIVE2} cvf SimpleOpenNI.jar SimpleOpenNI
				   COMMAND cmake -E echo "-----------------------------"
				   COMMAND cmake -E echo "Creating doc files..."
				   COMMAND cmake -E make_directory ./doc
				   #COMMAND ${JAVA_DOC} -quiet -author -public -nodeprecated -nohelp -d ./doc  -version ${P5_WRAPPER}/*.java -version ${CMAKE_SWIG_OUTDIR}/ContextWrapper.java)
				   COMMAND ${JAVA_DOC} -quiet -author -public -nodeprecated -nohelp -d ./doc  -version ${CMAKE_SWIG_OUTDIR}/*.java)
