#!/usr/bin/env bash
OUT="KS_REAL_PLATFORM_AUDIT.txt"
echo "KINGDOMSHIFT.LIVE REAL PLATFORM AUDIT" > "$OUT"
echo "Date: $(date)" >> "$OUT"

echo -e "\n===== ANALYZE =====" >> "$OUT"
flutter analyze >> "$OUT" 2>&1 || true

echo -e "\n===== COMMENTS + GIPHY =====" >> "$OUT"
grep -RIn "comment\|Comment\|giphy\|Giphy\|gif\|GIF\|sendComment\|addComment\|commentText\|CommentSheet" lib/screen lib/common lib/model >> "$OUT" 2>&1 || true

echo -e "\n===== PROFILE TABS / BUTTONS / STORIES =====" >> "$OUT"
grep -RIn "ProfileScreen\|profile\|story\|Story\|stories\|tab\|TabBar\|onTap:\|onPressed:\|Edit Profile\|Creator Hub\|followers\|following" lib/screen/profile_screen lib/screen/story_view_screen lib/screen/create_story_screen 2>/dev/null >> "$OUT" || true

echo -e "\n===== AVATAR / PROFILE IMAGE / K PLACEHOLDER =====" >> "$OUT"
grep -RIn "CircleAvatar\|profilePhoto\|profile_photo\|fullname\|username\|initial\|placeholder\|icUserPlaceholder\|AssetRes.icUserPlaceholder\|Text('K'\|Text(\"K\"" lib/screen lib/common lib/model >> "$OUT" 2>&1 || true

echo -e "\n===== MESSAGES TABS =====" >> "$OUT"
grep -RIn "Primary\|Groups\|Requests\|MessageScreen\|message\|chat\|tab\|onTap:\|onPressed:" lib/screen/message_screen lib/screen/chat_screen >> "$OUT" 2>&1 || true

echo -e "\n===== HOME NAV / GROUPS / AUTHORITYSHOP =====" >> "$OUT"
grep -RIn "Creator Network\|Following\|Live\|Groups\|Marketplace\|Shop\|AuthorityShop\|selectedPageIndex\|onChanged\|onTap:" lib/screen/home_screen lib/screen/dashboard_screen lib/screen/shop_screen lib/screen/ministries_screen >> "$OUT" 2>&1 || true

echo -e "\n===== ALL BUTTONS / TOGGLES =====" >> "$OUT"
grep -RIn "onTap:\|onPressed:\|Switch\|Checkbox\|GestureDetector\|InkWell\|IconButton\|ElevatedButton\|TextButton" lib/screen >> "$OUT" 2>&1 || true

echo -e "\n===== LIVE STREAMING =====" >> "$OUT"
grep -RIn "Zego\|zego\|livestream\|LiveStream\|startLive\|createLiveStream\|loginRoom\|startPublishingStream\|startPreview\|logoutRoom\|gift\|battle" lib/screen/live_stream lib/screen/audio_live_stream_screen lib/common lib/model >> "$OUT" 2>&1 || true

echo -e "\n===== DEMO / MOCK / PLACEHOLDER =====" >> "$OUT"
grep -RIn "demo\|mock\|sample\|placeholder\|Dummy\|fake\|Coming Soon\|TODO\|FIXME" lib/screen lib/common lib/model >> "$OUT" 2>&1 || true

echo -e "\n===== BACKEND CONNECTIONS =====" >> "$OUT"
grep -RIn "Supabase\|supabase\|FirebaseFirestore\|FirebaseAuth\|http.get\|http.post\|dio\|ks-live-backend\|railway\|cotcogrkmtgibbpwhxrg" lib >> "$OUT" 2>&1 || true

echo "DONE: $OUT"
