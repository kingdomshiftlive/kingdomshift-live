#!/bin/bash

OUT="LIVE_STREAM_FULL_AUDIT.txt"
echo "KINGDOMSHIFT LIVE STREAM AUDIT" > $OUT
echo "Generated: $(date)" >> $OUT
echo "" >> $OUT

echo "=== ZEGO ENGINE SETUP ===" >> $OUT
grep -R "createEngine\|ZegoEngineProfile\|ZegoScenario\|appId\|appSign" -n lib >> $OUT

echo "" >> $OUT
echo "=== LIVE START / PREVIEW / PUBLISH ===" >> $OUT
grep -R "createCanvasView\|startPreview\|startPublishingStream\|loginRoom\|logoutRoom\|stopPreview\|stopPublishingStream" -n lib/screen/live_stream >> $OUT

echo "" >> $OUT
echo "=== CO-HOST / MULTI-HOST ===" >> $OUT
grep -R "coHost\|co-host\|coHostId\|publishCoHost\|requestCoHost\|accept" -ni lib/screen/live_stream >> $OUT

echo "" >> $OUT
echo "=== GRID / MULTI USER LAYOUTS ===" >> $OUT
grep -R "EightUser\|SevenUser\|SixUser\|FiveUser\|FourUser\|ThreeUser\|DynamicUser\|StreamLayout\|grid" -n lib/screen/live_stream >> $OUT

echo "" >> $OUT
echo "=== COMMENTS ===" >> $OUT
grep -R "comment\|sendComment\|LivestreamComment" -ni lib/screen/live_stream >> $OUT

echo "" >> $OUT
echo "=== GIFTS / COINS ===" >> $OUT
grep -R "gift\|coin\|wallet\|sendGift" -ni lib/screen/live_stream lib/common/service >> $OUT

echo "" >> $OUT
echo "=== AUTO-END / TIMEOUTS ===" >> $OUT
grep -R "Timer\|timeout\|minViewer\|endStream\|hostEndStream\|streamEnded" -ni lib/screen/live_stream >> $OUT

echo "" >> $OUT
echo "=== RECORDING ===" >> $OUT
grep -R "record\|startRecording\|stopRecording" -ni lib/screen/live_stream lib/common/service >> $OUT

echo "" >> $OUT
echo "=== FIRESTORE LIVE DATA ===" >> $OUT
grep -R "livestreamRef\|liveStreamUsersRef\|liveStreamUserStatesRef\|watchingCount\|roomID" -n lib/screen/live_stream >> $OUT

echo "" >> $OUT
echo "=== ANDROID LIVE PERMISSIONS ===" >> $OUT
grep -n "CAMERA\|RECORD_AUDIO\|FOREGROUND_SERVICE\|WAKE_LOCK\|BLUETOOTH\|INTERNET" android/app/src/main/AndroidManifest.xml >> $OUT

echo ""
echo "DONE: $OUT created"
