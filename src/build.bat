IF EXIST FlexSdkPath.conf (
    for /f "delims=" %%x in (FlexSdkPath.conf) do (set "%%x")
) else (
    ECHO "!! Create a FlexSdkPath.conf file, with your FLEX sdk source path as the only line."
    EXIT
)

%FLEX_SDK%/bin/amxmlc.bat +configname=air -swf-version=19 -library-path+=../libs/gskinner_air.swc -library-path+=../libs/gskinner_as3.swc -library-path+=../libs/JSON.swc -output Zoe.swf Zoe.mxml && ^
%FLEX_SDK%/bin/adt.bat -package -storetype pkcs12 -keystore certificate.p12 -storepass %STORE_PASS% -target native Zoe.exe Zoe-app.xml Zoe.swf icons/16x16.png icons/32x32.png icons/48x48.png icons/128x128.png
