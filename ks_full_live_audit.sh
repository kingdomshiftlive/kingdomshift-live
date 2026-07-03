#!/usr/bin/env bash
OUT="KS_FULL_LIVE_AUDIT.txt"
echo "KINGDOMSHIFT FULL + LIVE STREAM AUDIT" > "$OUT"
echo "Date: $(date)" >> "$OUT"

echo -e "\n===== ANALYZE =====" >> "$OUT"
flutter analyze >> "$OUT" 2>&1 || true

echo -e "\n===== DASHBOARD ROUTES =====" >> "$OUT"
grep -RIn "IndexedStackChild\|selectedPageIndex\|_navItem\|_buildSecondaryNav\|Get.to\|Navigator" lib/screen/dashboard_screen lib/screen/home_screen >> "$OUT" 2>&1 || true

echo -e "\n===== HOME TOGGLES / BUTTONS =====" >> "$OUT"
grep -RIn "Following\|Live\|Groups\|Marketplace\|Creator\|onTap:\|onPressed:" lib/screen/home_screen lib/screen/feed_screen lib/screen/dashboard_screen >> "$OUT" 2>&1 || true

echo -e "\n===== BROKEN GETX / OBX RISK =====" >> "$OUT"
grep -RIn "Obx\|GetX\|GetBuilder\|Rx\|Get.put\|Get.find" lib/screen/notification_screen lib/screen/profile_screen lib/screen/explore_screen >> "$OUT" 2>&1 || true

echo -e "\n===== PLACEHOLDER / DEMO =====" >> "$OUT"
grep -RIn "demo\|mock\|sample\|placeholder\|Dummy\|fake\|Coming Soon\|TODO\|FIXME" lib/screen lib/common lib/model >> "$OUT" 2>&1 || true

echo -e "\n===== LIVE STREAM FILES =====" >> "$OUT"
find lib/screen -iname "*live*" -o -iname "*stream*" | sort >> "$OUT" 2>&1 || true

echo -e "\n===== LIVE STREAM CODE AUDIT =====" >> "$OUT"
grep -RIn "Zego\|zego\|livestream\|LiveStream\|liveDummyShow\|DummyLive\|isDummyLive\|createLiveStream\|join\|host\|battle\|gift\|logoutRoom\|startLive\|endLive" lib/screen lib/common lib/model >> "$OUT" 2>&1 || true

echo -e "\n===== LIVE STREAM CRASH RISK =====" >> "$OUT"
grep -RIn "late \|!\.|!\]|!\)|Get.find\|throw Exception\|MissingPluginException\|PlatformException" lib/screen/live_stream lib/screen/audio_live_stream_screen lib/common >> "$OUT" 2>&1 || true

echo -e "\n===== BACKEND CONNECTIONS =====" >> "$OUT"
grep -RIn "Supabase\|supabase\|FirebaseFirestore\|FirebaseAuth\|http.get\|http.post\|dio\|ks-live-backend\|railway\|cotcogrkmtgibbpwhxrg" lib >> "$OUT" 2>&1 || true

echo -e "\n===== ICONS / LOGOS =====" >> "$OUT"
grep -RIn "Icons\.\|Image.asset\|AssetRes.logo\|ks_logo\|crown\|0xFF7B2FF7\|0xFF08141F\|0xFF005574\|0xFFD4AF37" lib/screen >> "$OUT" 2>&1 || true

echo -e "\n===== MAIN SCREENS EXIST =====" >> "$OUT"
ls lib/screen/*_screen 2>/dev/null >> "$OUT" || true
find lib/screen -maxdepth 2 -type f -name "*screen.dart" | sort >> "$OUT"

echo "DONE: $OUT"
