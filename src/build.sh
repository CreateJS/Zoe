#!/bin/sh

if [[ -e FlexSdkPath.conf ]]; then source FlexSdkPath.conf
	else echo "!! Create a FlexSdkPath.conf file."; exit;
fi

${FLEX_SDK}/bin/mxmlc +configname=air -swf-version=19 -library-path+=../libs/gskinner_air.swc -library-path+=../libs/gskinner_as3.swc -library-path+=../libs/JSON.swc -output Zoe.swf Zoe.mxml
${FLEX_SDK}/bin/adt -package -storetype pkcs12 -keystore certificate.p12 -storepass ${STORE_PASS} -target native Zoe.dmg Zoe-app.xml Zoe.swf icons/16x16.png icons/32x32.png icons/48x48.png icons/128x128.png
