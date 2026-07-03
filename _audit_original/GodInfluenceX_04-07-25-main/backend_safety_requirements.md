# Backend Implementation Requirements: Platform Safety & Compliance

This document outlines the modifications and new endpoints required on the backend to fully support the frontend Platform Safety & Compliance features. Please review and implement these to ensure compliance across both server and client.

## 1. Age Gate Implementation
**Objective:** Ensure we restrict usage to users above a critical age threshold (e.g., 18+) and accurately record age consent.
* **Database Schema Update:**
  * Add a `date_of_birth` (Date) field to the User schema.
  * Optionally add an `age_verified` (Boolean) field if external identity checks are performed.
* **Endpoint Modifications:**
  * **POST `/register` or `/signup` API:** Must accept the `date_of_birth` parameter.
  * **Validation:** Reject any signup request originating from a user whose DOB computes to an age lower than the selected threshold (e.g. < 18). Respond with an explicit error structure clearly indicating an age violation.

## 2. Moderation API & Content Auditing
**Objective:** Double-check client moderation via server-side auditing. While the client runs SightEngine checks before upload, backend validation is mandatory to prevent API circumvention.
* **Server-Side SightEngine Validation (or equivalent):**
  * When content (Images, Videos, text comments, bio changes) is uploaded, the backend should ideally trigger its own moderation scan.
  * If the scan flags severe violations (e.g. CSAM, explicit gore), block the submission entirely.
  * If the scan flags 'medium' concerns, accept the content but attach an `is_flagged = true` boolean and send it to an **Admin Moderation Queue** for human review.
* **Livestream Auditing:** Provide endpoint controls to aggressively kill/ban a livestream if multiple automated moderation alerts or user reports hit simultaneously.

## 3. Universal Report & Block Features
**Objective:** Ensure blocking completely isolates two users and reporting is universal.
* **Report Endpoints:**
  * Existing report endpoints may only handle Posts. Extract this into a universal polymorphic report system.
  * **POST `/report`**: Should accept `target_id` and `target_type` (ENUM: `POST`, `REEL`, `COMMENT`, `USER`, `LIVESTREAM`, `CHAT_MESSAGE`).
  * Ensure reported content goes to the Admin Panel logically.
* **Block System Architecture:**
  * Ensure the **GET `/feed`**, **GET `/explore`**, **GET `/comments`** and **Search APIs** completely omit content from users who the requesting user has blocked, AND users who have blocked the requesting user.
  * Hard-block Websocket layers (Chat, Livestream presence) so blocked users cannot interact in real-time.

## 4. Urgency-Based Notification Removal
**Objective:** Purge engagement bait push notifications to comply with anti-addiction guidelines.
* **CRON / Background Job Audit:**
  * Locate any worker tasks that scan for dormant users (e.g., "User hasn't logged in for 48 hours -> send Come Back prompt").
  * Disable or remove these tasks.
* **FCM / APNS Services:**
  * Reduce "High Priority" payload flags on non-critical notifications to "Normal", particularly for generic activity alerts, so they do not artificially interrupt the user's focus.

## 5. Feed "Transparency" Architecture (Why am I seeing this?)
**Objective:** Explain to the user why chronological and algorithmic content was served to them.
* **Feed & Reel Endpoints Modification:**
  * Each post object returned in the paginated stream should now bundle a metadata string or enum dictating its algorithmic origin.
  * **Addition to JSON Response model:** Add `recommendation_reason: String`.
  * **Values should map to:** `FOLLOWING_AUTHOR`, `TRENDING_IN_REGION`, `SUGGESTED_SIMILAR_INTERESTS`, or `PAID_SPONSOR`.
  * The frontend will parse this string to display the bottom sheet info on the "Why am I seeing this?" menu interact.

## 6. Meaningful Feed Boundaries (You're all caught up)
**Objective:** Ensure infinite scrolling has natural psychological breaking points.
* **Feed API Logic:**
  * Instead of endlessly regurgitating old random content when chronological feeds dry up, the `/feed` endpoint must gracefully return an empty array `[]` or a `has_more: false` boolean when it runs out of current relevant content.
  * Do not artificially pad the feed with loose/unrelated data just to maintain scrolling unless the user explicitly requested "Explore".

---
*Created per Frontend Compliance Requirements on: 2026-04-04*
