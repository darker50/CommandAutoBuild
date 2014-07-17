#!/bin/bash
#Author:tanglong Email:tanglong0308@gmail.com
# build Android application package (.apk) from the command line using the SDK tools 

echo "\n =========check env=======\n"
export PATH=$PATH:$ANDROID_SDK/tools/:$ANDROID_SDK/platform-tools/:$ANDROID_SDK/build-tools/19.1.0
echo $PATH

echo "\n =========check aapt======\n"
aapt  

echo "\n =========check zipalign====\n"
zipalign

echo "\n =========check apkbuilder====\n"
apkbuilder

echo "\n =========check jarsigner=====\n"
jarsigner

echo "\n =========checkout source code=====\n"
BUILD_ROOT=`pwd`
BUILD_APK_NAME=unsign.apk
BUILD_RELEASE_APK_NAME=release.apk
BUILD_APK_PATH=release_apks
BUILD_SOURCE_PATH=$BUILD_ROOT/source

BUILD_API_LEVEL_JAR=$ANDROID_SDK/platforms/android-19/android.jar

MANIFEST_FILE=AndroidManifest.xml
PACKAGE_RESOURCE_FILE=assets
ANDROID_JAR_LIBRARY=libs
ANDROID_RESOURCE_DIRECTORY=res
ANDROID_GEN=gen
ANDROID_BIN=bin
ANDROID_SRC=src
ANDROID_BIN_CLASSES=classes
ANDROID_CLASSES_DEX=classes.dex

if [ ! -d $BUILD_ROOT/$BUILD_APK_PATH ]; then
   mkdir $BUILD_APK_PATH
fi

if [ ! -d $BUILD_SOURCE_PATH ]; then
   mkdir $BUILD_SOURCE_PATH
   cd $BUILD_SOURCE_PATH
   svn checkout https://github.com/clarck/AutoBuildProject/trunk . 
else 
   cd $BUILD_SOURCE_PATH
   svn update
fi

cd ../

if [ ! -d $BUILD_SOURCE_PATH/$ANDROID_GEN ]; then
   mkdir $BUILD_SOURCE_PATH/$ANDROID_GEN
else 
   rm -r $BUILD_SOURCE_PATH/$ANDROID_GEN/*
fi

if [ ! -d $BUILD_SOURCE_PATH/$ANDROID_BIN ]; then
   mkdir $BUILD_SOURCE_PATH/$ANDROID_BIN
fi

if [ ! -d $BUILD_SOURCE_PATH/$ANDROID_BIN/$ANDROID_BIN_CLASSES ]; then
   mkdir $BUILD_SOURCE_PATH/$ANDROID_BIN/$ANDROID_BIN_CLASSES
else
   rm -r $BUILD_SOURCE_PATH/$ANDROID_BIN/$ANDROID_BIN_CLASSES/*
fi

echo "\n ========build apk step1=======\n"
echo "\n Generate Resource java code and packaged Resources\n"
#echo "\n aapt package -f -m -J ${genpath} -A ${assetpath} -S ${respath} -I ${android.jar} -M ${AndroidManifestpath}\n"
echo "\n ==============================\n"
aapt package -f -m -J $BUILD_SOURCE_PATH/$ANDROID_GEN \
	 -A $BUILD_SOURCE_PATH/$PACKAGE_RESOURCE_FILE \
 	-S $BUILD_SOURCE_PATH/$ANDROID_RESOURCE_DIRECTORY \
 	-I $BUILD_API_LEVEL_JAR \
	 -M $BUILD_SOURCE_PATH/$MANIFEST_FILE 

echo "\n ========build apk step2======\n"
echo "\n Compile java source code\n"
#echo "\n javac -encoding ${encoding} -target ${jdkversion} -bootclasspath ${android.jar} -d ${outputclassespath.R.java.src.java}\n"
echo "\n ==============================\n"
javac -encoding UTF-8 \
	-target 1.7 \
	-bootclasspath $BUILD_API_LEVEL_JAR \
 	-d $BUILD_SOURCE_PATH/$ANDROID_BIN/$ANDROID_BIN_CLASSES \
	$BUILD_SOURCE_PATH/$ANDROID_GEN/com/clarck/httpclientnew/R.java \
	$BUILD_SOURCE_PATH/src/com/clarck/httpclientnew/*.java

echo "\n =======build apk step3======\n"
echo "\n Convert all .class files into dalvik format and create .dex file\n"
#echo "\n dx --dex --output=${outputdexpath} ${classespath}"
echo "\n =============================\n"
dx --dex --output=$BUILD_SOURCE_PATH/$ANDROID_BIN/$ANDROID_CLASSES_DEX \
	 $BUILD_SOURCE_PATH/$ANDROID_BIN/$ANDROID_BIN_CLASSES


echo "\n ======build apk step4======\n"
echo "\n Build package resources\n"
#echo "\n aapt package -f -M ${AndroidManifest.xml} -S ${packageresourcepath} -A ${assetpath} -I ${android.jar} -F ${AndroidManifest.res.asset->byreadreader}"
echo "\n ===========================\n"
aapt package -f -M $BUILD_SOURCE_PATH/$MANIFEST_FILE \
	-S $BUILD_SOURCE_PATH/$ANDROID_RESOURCE_DIRECTORY \
	-A $BUILD_SOURCE_PATH/$PACKAGE_RESOURCE_FILE \
	-I $BUILD_API_LEVEL_JAR \
	-F $BUILD_SOURCE_PATH/$ANDROID_BIN/byreadreader

echo "\n =====build apk step5=======\n"
echo "\n Combine packaged resources and .dex file and save them into .apk file\n"
#echo "\n apkbuilder ${output.apk.file} -u -z  ${packagedresource.file} -f  ${dex.file}  -rf  ${source.dir}  -rj  ${libraries.dir}\n"
echo "\n ===========================\n"
apkbuilder $BUILD_APK_PATH/$BUILD_APK_NAME \
	 -v -u -z $BUILD_SOURCE_PATH/$ANDROID_BIN/byreadreader \
	 -f $BUILD_SOURCE_PATH/$ANDROID_BIN/$ANDROID_CLASSES_DEX \
	 -rf $BUILD_SOURCE_PATH/$ANDROID_SRC

echo "\n ====build apk step6=======\n"
echo "\n Create keystore\n"
#echo "\n keytool -genkey -alias release -keyalg RSA -validity 20000 -keystore release.keystore\n"
echo "\n ==========================\n"
#keytool -genkey -alias release -keyalg RSA -validity 20000 -keystore release.keystore 

echo "\n ====build apk step7=======\n"
echo "\n sign for apk"
#echo "\n jarsigner  -keystore ${keystore} -storepass  ${keystore.password} -keypass ${keypass} -signedjar ${signed.apkfile} ${unsigned.apkfile} ${keyalias} "
echo "\n ==========================\n"
jarsigner -verbose -keystore release.keystore -storepass !@#$%^ -keypass !@#$%^ -signedjar $BUILD_APK_PATH/$BUILD_RELEASE_APK_NAME $BUILD_APK_PATH/$BUILD_APK_NAME release
