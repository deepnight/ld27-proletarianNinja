@echo off

cd air

set client=Proletarian

del *.apk > nul
copy ..\swf\client.swf client.swf > nul

echo Compiling %client%.apk...
call adt -package -target apk -storetype pkcs12 -keystore certificate.p12 -storepass d %client%.apk manifest.xml client.swf

echo Uninstalling...
call adt -uninstallApp -platform android -appid com.deepnight.android.%client%

echo Installing...
call adt -installApp -platform android -package %client%.apk

echo Running...
call adt -launchApp -platform android -appid com.deepnight.android.%client%
