# Post Creation Cycles in GodInfluenceX

This document explains the complete lifecycle for the different post options found in `lib/screen/profile_screen/widget/post_options_sheet.dart`.

The platform offers 4 types of content creation:
1.  **Feed Post** (Image/Text/Video)
2.  **Story**
3.  **Reels** (Short Videos)
4.  **Go Live**

---

## 1. Feed Post Cycle
**EntryPoint:** `PostOptionsSheet` -> `PublishType.feed`

### Flow:
1.  **Navigation:** Navigates to `CreateFeedScreen` with `createType: CreateFeedType.feed`.
2.  **Controller:** Managed by `CreateFeedScreenController`.
3.  **User Input:**
    *   **Text:** Typed in `FeedTextFieldView`.
    *   **Media:** Selected via `controller.onMediaTap` (Image/Video).
    *   **Location:** Optional via `CreateFeedLocationBar`.
    *   **Mentions/Hashtags:** Parsed from text.
4.  **Upload Trigger:** User clicks "Upload Now" -> `controller.handleUpload`.
5.  **Moderation:**
    *   Calls `SightEngineService` to check text/image/video content.
6.  **Upload Process (`_uploadPostHandler`):**
    *   **Text:** Calls `AddPostStoryService.instance.addPostFeedText`.
    *   **Image:**
        *   Applies Filters (if any).
        *   Compresses Images.
        *   Uploads Images via `CommonService`.
        *   Calls `AddPostStoryService.instance.addPostFeedImage`.
    *   **Video:**
        *   Applies Filters.
        *   Extracts Thumbnail.
        *   Compresses Video.
        *   Uploads Video & Thumbnail.
        *   Calls `AddPostStoryService.instance.addPostFeedVideo`.
7.  **Completion:** Updates `ProfileScreenController` with the new post and notifies mentioned users.

8.  **Server Side & API Details:**
    *   **Endpoints:**
        *   Text Post: `post/addPost_Feed_Text`
        *   Image Post: `post/addPost_Feed_Image`
        *   Video Post: `post/addPost_Feed_Video`
    *   **Differentiation:** The server distinguishes these by the specific endpoint called.
    *   **Parameters Sent:**
        *   `description` (String): The caption text.
        *   `can_comment` (0 or 1): Toggle for comments.
        *   `hashtags` (String): Comma-separated list of hashtags.
        *   `mentioned_user_ids` (String): Comma-separated list of user IDs.
        *   `place_title`, `place_lat`, `place_lon`, `country`, `state` (String): Location data.
        *   `post_images` (Array[String]): List of uploaded image URLs (for Image Post).
        *   `video` (String): Uploaded video URL (for Video Post).
        *   `thumbnail` (String): Uploaded thumbnail URL (for Video Post).
        *   `metadata` (JSON String): Optional link metadata.

---

## 2. Story Cycle
**EntryPoint:** `PostOptionsSheet` -> `PublishType.story`

### Flow:
1.  **Navigation:** Navigates to `CameraScreen` with `cameraType: CameraScreenType.story`.
2.  **Capture/Select:**
    *   **Camera:** Handled by `CameraScreenController` (Photo/Video).
    *   **Gallery:** Handled by `MediaPickerHelper` (Image/Video).
    *   **Text:** Option to create text-only story.
3.  **Edit Phase:**
    *   Navigates to `CameraEditScreen` with `PostStoryContentType`.
    *   User can add Music, Filters, Text.
4.  **Upload Trigger:** User clicks "Post" -> `CameraEditScreenController.handleContentUpload` -> `handleStoryUpload`.
5.  **Processing:**
    *   **Image/Text:** Captures screenshot of the view -> Compresses -> Moderation -> Uploads.
    *   **Video:** Checks moderation -> Applies Filters/Music -> Merges Audio if needed.
6.  **API Call:**
    *   Calls `PostService.instance.createStory`.
7.  **Completion:** Updates Dashboard progress and Profile/Feed controllers.

8.  **Server Side & API Details:**
    *   **Endpoint:** `post/createStory`
    *   **Differentiation:** The `type` parameter differentiates between photo and video stories.
    *   **Parameters Sent:**
        *   `content` (File): The actual image or video file (Multipart).
        *   `thumbnail` (File): The thumbnail file (Multipart, for Video).
        *   `type` (Int): `0` for Image, `1` for Video.
        *   `duration` (Int): length of the story in seconds.
        *   `sound_id` (Int): ID of the music track used (optional).

---

## 3. Reels Cycle
**EntryPoint:** `PostOptionsSheet` -> `PublishType.reels`

### Flow:
1.  **Navigation:** Navigates to `CameraScreen` with `cameraType: CameraScreenType.post`.
2.  **Capture/Select:**
    *   User records video or selects from gallery.
    *   Handled by `CameraScreenController._handleReel`.
3.  **Edit Phase:**
    *   Navigates to `CameraEditScreen` (same as Story).
    *   User edits with Music, Filters, etc.
4.  **Transition to Feed Logic:**
    *   User clicks "Post" -> `CameraEditScreenController.handleReelUpload`.
    *   **Key Step:** Instead of calling an API directly, it calls `_goToCreateFeedScreen`.
    *   This extracts the thumbnail and navigates to `CreateFeedScreen` with `createType: CreateFeedType.reel`.
5.  **Finalize:**
    *   User enters Description/Hashtags in `CreateFeedScreen`.
    *   User clicks "Upload Now".
6.  **Upload Process:**
    *   `CreateFeedScreenController._handleReelUpload`.
    *   Extracts Audio (if needed).
    *   Compresses Video.
    *   Uploads Video & Thumbnail.
    *   Calls `AddPostStoryService.instance.addPostReel`.

7.  **Server Side & API Details:**
    *   **Endpoint:** `post/addPost_Reel`
    *   **Differentiation:** Specific endpoint for Reels.
    *   **Parameters Sent:**
        *   `description` (String): Caption.
        *   `can_comment` (0 or 1).
        *   `video` (String): URL of the uploaded video file.
        *   `thumbnail` (String): URL of the uploaded thumbnail.
        *   `sound_id` (Int): ID of the music track.
        *   `hashtags`, `mentioned_user_ids`, `location` data (same as Feed).

---

## 4. Go Live Cycle
**EntryPoint:** `PostOptionsSheet` -> `PublishType.goLive`

### Flow:
1.  **Navigation:** Navigates to `CreateLiveStreamScreen`.
2.  **Controller:** `CreateLiveStreamScreenController`.
3.  **Setup:**
    *   Checks Permissions (Camera/Mic).
    *   Initializes `ZegoExpressEngine` for streaming.
    *   Shows local camera preview.
4.  **Configuration:** User enters Title and sets "Restrict User Requests" option.
5.  **Start Trigger:** User clicks "Start Live" -> `controller.onStartLive`.
6.  **Validation:** Checks minimum follower count requirement.
7.  **Backend Registration (Firestore):**
    *   Creates/Updates documents in `LiveStreams`, `AppUsers`, and `State` collections.
    *   Sets status to "Host".
8.  **API Recording:** Calls `WebService.post.startRecording` to start server-side recording.
9.  **Navigation:** Navigates to `LivestreamHostScreen` to begin the actual broadcast.

10. **Server Side & API Details:**
    *   **Backend:** Firebase Firestore + Custom API.
    *   **Firestore Paths:**
        *   `LiveStreams/{userId}`: Stores room ID, host info, view ID.
        *   `AppUsers/{userId}`: User details.
        *   `LiveStreams/{userId}/State/{userId}`: Status (Host).
    *   **Recording API Endpoint:** `startRecording` (GET request).
        *   **Parameters:** `streamId` (Path parameter).
    *   **Differentiation:** This flow is completely separate from posts; it's a real-time state managed via Firestore and Zego Cloud, with an API call only to trigger server-side recording.

---

## 5. Type Codes Reference

### Post Types (`PostType`)
These integer values are used in the **Server Response** (`PostModel`) to identify the type of content.
*   **0 (None):** Unknown or undefined type.
*   **1 (Reel):** Short vertical video content.
*   **2 (Image):** Standard feed post containing one or more images.
*   **3 (Video):** Standard feed post containing a video.
*   **4 (Text):** Text-only feed post.

### Story Types
These integer values are sent in the **Create Story API** request (`post/createStory`) to specify the content format.
*   **0 (Image):** Static image story (or text converted to image).
*   **1 (Video):** Video story.

### Internal Feed Types (`FeedPostType`)
These are internal state enums used within `CreateFeedScreenController`, not sent directly to the server (the server infers type from the specific endpoint called).
*   **Image**: Triggers `post/addPost_Feed_Image`
*   **Text**: Triggers `post/addPost_Feed_Text`
*   **Video**: Triggers `post/addPost_Feed_Video`
