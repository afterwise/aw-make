#!/bin/sh

dir=$1
sdk=$2
org=$3
name=$4
lib=$5

test -e AndroidManifest.xml || cat > $dir/AndroidManifest.xml << EOF
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
	package="$org.$name"
	android:versionCode="1"
	android:versionName="1.0"
	android:isGame="true"
	android:debuggable="true"
	>
	<uses-sdk
		android:minSdkVersion="11"
		android:targetSdkVersion="$sdk"
		/>
	<uses-feature
		android:glEsVersion="0x00020000"
		android:required="true"
		/>
	<application
		android:allowBackup="false"
		android:hasCode="false"
		android:label="$name"
		android:theme="@android:style/Theme.Holo.NoActionBar.Fullscreen"
		>
		<activity
			android:name="android.app.NativeActivity"
			android:configChanges="orientation|keyboardHidden"
			>
			<meta-data
				android:name="android.app.lib_name"
				android:value="$lib"
				/>
			<intent-filter>
				<action
					android:name="android.intent.action.MAIN"
					/>
				<category
					android:name="android.intent.category.LAUNCHER"
					/>
			</intent-filter>
		</activity>
	</application>
</manifest>
EOF

