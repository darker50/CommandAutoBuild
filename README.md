CommandAutoBuild
================

Linux bash shell auto build Android Project.

#Step1#
#Generate Resource java code and packaged Resources#
with the follow command:

aapt package -f -m -J ${genpath} -A ${assetpath} -S ${respath} -I ${android.jar} -M ${AndroidManifestpath}

#Step2#
#Compile java source code#
with the follow command:

javac -encoding ${encoding} -target ${jdkversion} -bootclasspath ${android.jar} -d ${outputclassespath.R.java.src.java}

#Step3#
#Convert all .class files into dalvik format and create .dex file#
with the follow command:

dx --dex --output=${outputdexpath} ${classespath}

#Step4#
#Build package resources#
with the follow command:

aapt package -f -M ${AndroidManifest.xml} -S ${packageresourcepath} -A ${assetpath} -I ${android.jar} -F ${AndroidManifest.res.asset->byreadreader}

#Step5#
#Combine packaged resources and .dex file and save them into .apk file#
with the follow command:

apkbuilder ${output.apk.file} -u -z  ${packagedresource.file} -f  ${dex.file}  -rf  ${source.dir}  -rj  ${libraries.dir}

#Step6#
#Create the keystore#
with the follow command:

keytool -genkey -alias release -keyalg RSA -validity 20000 -keystore release.keystore

#Step7#
#Sign for apk#
with the follow Command:

jarsigner  -keystore ${keystore} -storepass  ${keystore.password} -keypass ${keypass} -signedjar ${signed.apkfile} ${unsigned.apkfile} ${keyalias}

#NOTE:#
#apkbuilder command is not found above android-11#
