from pathlib import Path
import re

root = Path("lib")
screens = Path("lib/screen")

checks = {
    "TODO/FIXME": r"TODO|FIXME|HACK|demo|placeholder|coming soon|not implemented",
    "Dead taps": r"onTap:\s*\(\)\s*\{\s*\}|onTap:\s*null",
    "Get navigation": r"Get\.to|Get\.off|Get\.back|selectedPageIndex",
    "Live refs": r"Zego|livestream|LiveStream|logoutRoom|deleteStreamOnFirebase",
    "Comments/GIF": r"comment|Comment|Giphy|Gif|GIF",
    "Profile/Story": r"profile|Profile|story|Story|avatar|image",
    "Shop/AuthShop": r"Shop|Marketplace|AuthorityShop|product|Product",
    "Podcast": r"Podcast|podcast|audio|rss|RSS",
    "Admin/Moderation": r"report|moderation|block|mute|ban|safety",
}

print("KINGDOMSHIFT.LIVE FULL PLATFORM AUDIT\n")

for name, pattern in checks.items():
    print(f"\n===== {name} =====")
    count = 0
    for p in root.rglob("*.dart"):
        try:
            txt = p.read_text(encoding="utf-8", errors="ignore")
        except:
            continue
        for i, line in enumerate(txt.splitlines(), 1):
            if re.search(pattern, line, re.I):
                print(f"{p}:{i}: {line.strip()[:180]}")
                count += 1
                if count >= 80:
                    print("... truncated ...")
                    break
        if count >= 80:
            break
    print(f"Total shown: {count}")

print("\n===== DASHBOARD IMPORTANT =====")
for p in [
    "lib/screen/dashboard_screen/dashboard_screen.dart",
    "lib/screen/dashboard_screen/dashboard_screen_controller.dart",
]:
    pp = Path(p)
    print(f"\n--- {p} exists={pp.exists()} ---")
    if pp.exists():
        txt = pp.read_text(encoding="utf-8", errors="ignore")
        for i, line in enumerate(txt.splitlines(), 1):
            if any(x.lower() in line.lower() for x in ["HomeScreen", "FeedScreen", "Live", "Explore", "Message", "Notification", "Profile", "Shop", "Podcast", "_createNavItem", "_showCreateHub"]):
                print(f"{i}: {line.strip()}")

print("\nAUDIT DONE")
