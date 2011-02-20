# -----------------------------------------------------------------------------
# SimpleOpenNI 
# -----------------------------------------------------------------------------
# Processing Wrapper for the OpenNI/Kinect library
# prog:  Max Rheiner / Interaction Design / zhkd / http://iad.zhdk.ch/
# -----------------------------------------------------------------------------
#
#	this envVar should be set:
#		OPEN_NI_INCLUDE < set this on osx: export OPEN_NI_INCLUDE=...path
#		OPEN_NI_LIB 
#		JAVA_HOME
#		JAVA_HOME
#
# -----------------------------------------------------------------------------

CMAKE_MINIMUM_REQUIRED(VERSION 2.8)

PROJECT(SimpleOpenNI)

# check swig
FIND_PACKAGE(SWIG REQUIRED)
INCLUDE(${SWIG_USE_FILE})

# check java/jni
FIND_PACKAGE(Java REQUIRED)
FIND_PACKAGE(JNI REQUIRED)
INCLUDE_DIRECTORIES(${JAVA_INCLUDE_PATH})
INCLUDE_DIRECTORIES(${JAVA_INCLUDE_PATH2})
 
INCLUDE_DIRECTORIES(${CMAKE_CURRENT_SOURCE_DIR})
 
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

# swig 
SET(CMAKE_SWIG_FLAGS -package SimpleOpenNI)

INCLUDE_DIRECTORIES(${CMAKE_CURRENT_SOURCE_DIR}/include)

# openNI 
INCLUDE_DIRECTORIES($ENV{OPEN_NI_INCLUDE})
FIND_LIBRARY(OPEN_NI_LIBRARY NAMES openNI PATHS $ENV{OPEN_NI_LIB})
SET(LIBS ${LIBS} ${OPEN_NI_LIBRARY})

# processing wrappers
SET(P5_WRAPPER ${CMAKE_CURRENT_SOURCE_DIR}/src/p5_src/)
SET(P5_WRAPPER_FILE ${CMAKE_CURRENT_SOURCE_DIR}/src/p5_src/SimpleOpenNI.java)

# processing core lib
# shoudl use that: find_program
IF(WIN32)
	SET(P5_JAR "C:/Program Files (x86)/processing-1.2.1/lib/core.jar")
ELSEIF(APPLE)
	SET(P5_JAR "/Applications/Processing.app/Contents/Resources/Java/core.jar")
ELSE()
	# unix/linux
	EchoString("Error: Set the path to the Processing core.jar")
	# SET(P5_JAR "/?")
ENDIF()


SET(SWIG_SOURCES 
"src/SimpleOpenNI.i"
"src/ContextWrapper.cpp"
)

SET_SOURCE_FILES_PROPERTIES(${SWIG_SOURCES} PROPERTIES CPLUSPLUS ON)
#SET_SOURCE_FILES_PROPERTIES(${SWIG_SOURCES} PROPERTIES SWIG_FLAGS "-includeall")
# set the folder where the swig files should land
SET(CMAKE_SWIG_OUTDIR ${CMAKE_CURRENT_BINARY_DIR}/swig_src)

SWIG_ADD_MODULE(SimpleOpenNI Java ${SWIG_SOURCES})
SWIG_LINK_LIBRARIES(SimpleOpenNI ${JAVA_LIBRARIES} ${JNI_LIBRARIES} ${LIBS})


ADD_CUSTOM_COMMAND(TARGET SimpleOpenNI
                   POST_BUILD
                   COMMAND cmake -E echo "Compiling Java files..."
                   COMMAND cmake -E make_directory ./SimpleOpenNI
                   COMMAND cmake -E make_directory ${CMAKE_SWIG_OUTDIR}
				   #COMMAND cmake -E copy_directory ${P5_WRAPPER} ${CMAKE_SWIG_OUTDIR}
				   # cmake copy doesn't support wildcards, otherwise it just copies the hidden folder of svn, etc.
				   # doesn't works on windows backslash
				   COMMAND cp "${P5_WRAPPER}*.java" "${CMAKE_SWIG_OUTDIR}"
				   #COMMAND cmake -E copy ${P5_WRAPPER_FILE} ${CMAKE_SWIG_OUTDIR}
				   COMMAND ${JAVA_COMPILE2} -classpath ${P5_JAR} ${CMAKE_SWIG_OUTDIR}/*.java -d ./
                   COMMAND cmake -E echo "Creating jar file..."
                   COMMAND ${JAVA_ARCHIVE2} cvf SimpleOpenNI.jar SimpleOpenNI
				   COMMAND cmake -E echo "Creating doc files..."
				   COMMAND cmake -E make_directory ./doc
				   COMMAND ${JAVA_DOC} -author -public -nodeprecated -nohelp -d ./doc  -version ${P5_WRAPPER}/*.java -version ${CMAKE_SWIG_OUTDIR}/ContextWrapper.java)
