# Backend Integration Guide — Safety & Wellbeing Features

Base URL: `https://admin.godinfluencex.com/api/`  
Auth: All endpoints require `AUTHTOKEN` header.

---

## 1. Report Comment

**Endpoint:** `POST misc/reportComment`  
**Called from:** [report_sheet_controller.dart](lib/screen/report_sheet/report_sheet_controller.dart) → `_reportComment()`

| Parameter     | Type   | Required | Description                        |
|---------------|--------|----------|------------------------------------|
| `comment_id`  | int    | Yes      | ID of the reported comment         |
| `reason`      | string | Yes      | Selected reason from report list   |
| `description` | string | Yes      | User-provided description          |

**Response:**
```json
{ "status": true, "message": "Report submitted successfully" }
{ "status": false, "message": "Error message" }
```

**Backend actions:**
- Store report in `comment_reports` table with `comment_id`, `reporter_user_id`, `reason`, `description`, `created_at`
- If report threshold is reached, auto-flag comment for moderator review
- Prevent duplicate reports from same user on same comment

---

## 2. Report Story

**Endpoint:** `POST misc/reportStory`  
**Called from:** [report_sheet_controller.dart](lib/screen/report_sheet/report_sheet_controller.dart) → `_reportStory()`

| Parameter     | Type   | Required | Description                       |
|---------------|--------|----------|-----------------------------------|
| `story_id`    | int    | Yes      | ID of the reported story          |
| `reason`      | string | Yes      | Selected reason from report list  |
| `description` | string | Yes      | User-provided description         |

**Response:**
```json
{ "status": true, "message": "Report submitted successfully" }
{ "status": false, "message": "Error message" }
```

**Backend actions:**
- Store report in `story_reports` table with `story_id`, `reporter_user_id`, `reason`, `description`, `created_at`
- If report threshold reached, auto-flag story for moderator review
- Prevent duplicate reports from same user on same story

---

## 3. Report Post (existing — no change needed)

**Endpoint:** `POST misc/reportPost`  
**Called from:** [report_sheet_controller.dart](lib/screen/report_sheet/report_sheet_controller.dart) → `_reportPost()`

| Parameter     | Type   | Required |
|---------------|--------|----------|
| `post_id`     | int    | Yes      |
| `reason`      | string | Yes      |
| `description` | string | Yes      |

---

## 4. Report User (existing — no change needed)

**Endpoint:** `POST misc/reportUser`  
**Called from:** [report_sheet_controller.dart](lib/screen/report_sheet/report_sheet_controller.dart) → `_reportUser()`

| Parameter     | Type   | Required |
|---------------|--------|----------|
| `user_id`     | int    | Yes      |
| `reason`      | string | Yes      |
| `description` | string | Yes      |

---

## 5. Age Gate — Registration

**No new endpoint needed.**  
The age gate is enforced client-side during registration. The `logInUser` endpoint already exists.

**Recommended backend addition:**  
When `logInUser` creates a new user record, store `age_confirmed: true` (boolean) on the user row so you have an audit trail that the user agreed at registration time.

| Field           | Type    | Description                                    |
|-----------------|---------|------------------------------------------------|
| `age_confirmed` | boolean | Set to `true` when user checks the 18+ box    |

**Called from:** [auth_screen_controller.dart](lib/screen/auth_screen/auth_screen_controller.dart) → `onCreateAccount()` (already validates checkbox before calling API)

---

## 6. Moderation Admin Panel — Moderator Actions (existing)

These endpoints already exist. Listed here for completeness.

| Endpoint                              | Action                     |
|---------------------------------------|----------------------------|
| `POST moderator/moderator_deletePost` | Moderator deletes a post   |
| `POST moderator/moderator_deleteStory`| Moderator deletes a story  |
| `POST moderator/moderator_freezeUser` | Freeze/ban a user          |
| `POST moderator/moderator_unFreezeUser`| Unfreeze a user           |

---

## 7. Report Reasons — Settings API

**Endpoint:** `POST settings/fetchSettings` (existing)  
**Used in:** [report_sheet_controller.dart](lib/screen/report_sheet/report_sheet_controller.dart) — reads `SessionManager.instance.getSettings()?.reportReason`

The `reportReason` array returned in settings is used for **all** report types (post, user, comment, story). No change needed unless you want separate reason lists per content type.

**Current settings response shape (relevant section):**
```json
{
  "report_reason": [
    { "id": 1, "title": "Spam" },
    { "id": 2, "title": "Harassment" },
    { "id": 3, "title": "Inappropriate content" }
  ]
}
```

---

## 8. Break Reminder — No Backend Required

Break reminders are implemented fully client-side in [dashboard_screen_controller.dart](lib/screen/dashboard_screen/dashboard_screen_controller.dart).

- Timer fires every second, resets after 30 minutes of active use
- Pauses when app goes to background (`AppLifecycleState.paused`)
- Shows a dialog, resets counter on dismiss

**Optional backend enhancement:** If you want to track wellbeing analytics:

**Endpoint (new, optional):** `POST misc/logBreakReminder`

| Parameter       | Type   | Description                              |
|-----------------|--------|------------------------------------------|
| `session_secs`  | int    | Total seconds in session before reminder |
| `dismissed_at`  | string | ISO 8601 timestamp                       |

---

## Summary of New Endpoints to Build

| Priority | Endpoint                  | Status   |
|----------|---------------------------|----------|
| High     | `POST misc/reportComment` | **New**  |
| High     | `POST misc/reportStory`   | **New**  |
| Low      | Add `age_confirmed` field to user table | Schema change |
| Optional | `POST misc/logBreakReminder` | Optional analytics |

All other features (report post, report user, block user, moderation, content moderation via SightEngine, "Why am I seeing this?", feed stopping points) are **already integrated** with existing backend endpoints.
