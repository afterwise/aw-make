#!/bin/sh

sdk=$1
type=$2
org=$3
name=$4

if [ "$type" == "app" ]; then
	pkgtype=APPL
elif [ "$type" == "bundle" ]; then
	pkgtype=BNDL
fi

tmpl=`xcrun --sdk $sdk --show-sdk-platform-path`/Info.plist

xbuildmachineosbuild=`sw_vers -buildVersion`
xdtcompiler=`/usr/libexec/PlistBuddy -c 'print DTCompiler' $tmpl`
xdtplatformbuild=`xcodebuild -version | grep 'Build version' | cut -d' ' -f3`
xdtplatformversion=`/usr/libexec/PlistBuddy -c 'print DTPlatformVersion' $tmpl`
xdtsdkbuild=`xcodebuild -sdk $sdk -version | grep ProductBuildVersion | cut -d' ' -f2`
xdtsdkname=`xcodebuild -sdk $sdk -version | head -n1 | sed -E 's/(^.*\()|(\)$$)//g'`
xdtxcode=`/usr/libexec/PlistBuddy -c 'print DTXcode' $tmpl`
xdtxcodebuild=`xcodebuild -version | grep 'Build version' | cut -d' ' -f3`

rm -f $name.$type/Contents/Info.plist

/usr/libexec/PlistBuddy $name.$type/Contents/Info.plist > /dev/null << EOF
add CFBundleDevelopmentRegion string English
add CFBundleInfoDictionaryVersion string 6.0
add CFBundlePackageType string $pkgtype
add CFBundleShortVersionString string 1.0
add CFBundleSignature string ????
add CFBundleVersion string 1
add CFBundleExecutable string $name
add CFBundleName string $name
add CFBundleIdentifier string $org.$name
add CFPlugInDynamicRegisterFunction string
add CFPlugInDynamicRegistration string NO
add CFPlugInUnloadFunction string
add BuildMachineOSBuild string $xbuildmachineosbuild
add DTCompiler string $xdtcompiler
add DTPlatformBuild string $xdtplatformbuild
add DTPlatformVersion string $xdtplatformversion
add DTSDKBuild string $xdtsdkbuild
add DTSDKName string $xdtsdkname
add DTXcode string $xdtxcode
add DTXcodeBuild string $xdtxcodebuild
save
EOF

