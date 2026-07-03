# Shortzz 2.0

# Date: 30 June 2025

## Summary

- Fixed comment count not updating after posting.
- Improved navigation from post/reel detail back to the correct tab.
- Resolved crashes caused by missing languages or onboarding data from admin panel.
- Handled Zego engine configuration errors on dashboard screen.
- Fixed empty Reels screen crash.
- Improved chat notification behavior when app is killed.
- Fixed message tab language not updating properly.
- Resolved text field overlap issues on certain Android devices.
- Improved Live stream stability:
    - Live no longer disappears unexpectedly from the list.
    - Audience visibility and co-host features are now more reliable.
- Fixed Hosts can no longer forcefully turn on the co-host’s camera or microphone during a live
  broadcast. User privacy is now strictly protected.
- Fixed When a user shares a video from the feed, the recipient can now independently like the
  video, even if it was previously liked by the sender.

#### Updated Files

- [app_res.dart](lib/utilities/app_res.dart)
- [asset_res.dart](lib/utilities/asset_res.dart)
- [audio_details_screen.dart](lib/screen/audio_details_screen/audio_details_screen.dart)
- [base_controller.dart](lib/common/controller/base_controller.dart)
- [chat_bottom_action_view.dart](lib/screen/chat_screen/widget/chat_bottom_action_view.dart)
- [chat_conversation_user_card.dart](lib/screen/message_screen/widget/chat_conversation_user_card.dart)
- [chat_screen_controller.dart](lib/screen/chat_screen/chat_screen_controller.dart)
- [chat_top_profile_view.dart](lib/screen/chat_screen/widget/chat_top_profile_view.dart)
- [comment_sheet_controller.dart](lib/screen/comment_sheet/comment_sheet_controller.dart)
- [const_res.dart](lib/utilities/const_res.dart)
- [custom_tab_switcher.dart](lib/common/widget/custom_tab_switcher.dart)
- [dashboard_screen_controller.dart](lib/screen/dashboard_screen/dashboard_screen_controller.dart)
- [explore_screen_controller.dart](lib/screen/explore_screen/explore_screen_controller.dart)
- [firebase_notification_manager.dart](lib/common/manager/firebase_notification_manager.dart)
- [hashtag_screen.dart](lib/screen/hashtag_screen/hashtag_screen.dart)
- [hashtag_screen_controller.dart](lib/screen/hashtag_screen/hashtag_screen_controller.dart)
- [home_screen.dart](lib/screen/home_screen/home_screen.dart)
- [Info.plist](ios/Runner/Info.plist)
- [live_stream_bottom_view.dart](lib/screen/live_stream/livestream_screen/view/live_stream_bottom_view.dart)
- [live_stream_search_screen_controller.dart](lib/screen/live_stream/live_stream_search_screen/live_stream_search_screen_controller.dart)
- [livestream_screen_controller.dart](lib/screen/live_stream/livestream_screen/livestream_screen_controller.dart)
- [location_service.dart](lib/common/service/location/location_service.dart)
- [location_sheet.dart](lib/screen/create_feed_screen/widget/location_sheet.dart)
- [main.dart](lib/main.dart)
- [notification_screen.dart](lib/screen/notification_screen/notification_screen.dart)
- [notification_service.dart](lib/common/service/api/notification_service.dart)
- [post_card.dart](lib/screen/post_screen/post_card.dart)
- [post_view_center.dart](lib/screen/post_screen/widget/post_view_center.dart)
- [profile_user_header.dart](lib/screen/profile_screen/widget/profile_user_header.dart)
- [pubspec.yaml](pubspec.yaml)
- [README.md](README.md)
- [reel_list.dart](lib/common/widget/reel_list.dart)
- [reels_screen_controller.dart](lib/screen/reels_screen/reels_screen_controller.dart)
- [search_screen.dart](lib/screen/search_screen/search_screen.dart)
- [search_screen_controller.dart](lib/screen/search_screen/search_screen_controller.dart)
- [select_language_screen.dart](lib/screen/select_language_screen/select_language_screen.dart)
- [select_language_screen_controller.dart](lib/screen/select_language_screen/select_language_screen_controller.dart)
- [send_gift_sheet.dart](lib/screen/gift_sheet/send_gift_sheet.dart)
- [session_expired_screen.dart](lib/screen/session_expired_screen/session_expired_screen.dart)
- [settings_screen_controller.dart](lib/screen/settings_screen/settings_screen_controller.dart)
- [single_post_screen.dart](lib/screen/post_screen/single_post_screen.dart)
- [splash_screen_controller.dart](lib/screen/splash_screen/splash_screen_controller.dart)
- [string_extension.dart](lib/common/extensions/string_extension.dart)
- [system_notification_page.dart](lib/screen/notification_screen/widget/system_notification_page.dart)
- [url_card.dart](lib/screen/post_screen/widget/url_card.dart)
- [user_information.dart](lib/screen/reels_screen/reel/widget/user_information.dart)
- [user_link_sheet.dart](lib/screen/profile_screen/widget/user_link_sheet.dart)
- [Podfile.lock](ios/Podfile.lock)
- [pubspec.lock](pubspec.lock)
- [chat_post_message.dart](lib/screen/chat_screen/message_type_widget/chat_post_message.dart)
- [firebase_const.dart](lib/utilities/firebase_const.dart)
- [live_stream_user_info_sheet.dart](lib/screen/live_stream/livestream_screen/audience/widget/live_stream_user_info_sheet.dart)
- [livestream_user_state.dart](lib/model/livestream/livestream_user_state.dart)
- [livestream_view.dart](lib/screen/live_stream/livestream_screen/view/livestream_view.dart)
- [members_sheet.dart](lib/screen/live_stream/livestream_screen/widget/members_sheet.dart)
- [post_model.dart](lib/model/post_story)
- [reels_screen.dart](lib/screen/reels_screen/reels_screen.dart)
- [share_sheet_widget_controller.dart](lib/screen/share_sheet_widget/share_sheet_widget_controller.dart)
- [user_extension.dart](lib/common/extensions/user_extension.dart)
- [reel_page.dart](lib/screen/reels_screen/reel/reel_page.dart)
- [reel_page_controller.dart](lib/screen/reels_screen/reel/reel_page_controller.dart)

#### Added Files

- none

#### Deleted Files

- [ic_chat_gift.png](assets/icons/ic_chat_gift.png)

----------------------------------------------------------------------------------------------------

# Date: 17 June 2025

## Summary

- fixed horizontal reel issue
- Fixed "App last used at" not updating for users
- Added Branch key in const_res.dart
- Fixed "Access Denied" error for some images (wrong URL)
- fixed Reel issue
- link preview UI change
- Added loader to music sheet & Follow button & block button
- Fixed reply comment not sending
- Set `setLooping(true)` for livestream demo video player
- Fixed notification: tapping it should go to the post, and tapping a photo should go to the user
  profile
- Fixed removed stories older than 24 hours
- fixed the issue where notifications were not being sent in the localized language.

#### Updated Files

- [activity_notification_page.dart](lib/screen/notification_screen/widget/activity_notification_page.dart)
- [api_service.dart](lib/common/service/api/api_service.dart)
- [auth_screen_controller.dart](lib/screen/auth_screen/auth_screen_controller.dart)
- [block_user_controller.dart](lib/screen/blocked_user_screen/block_user_controller.dart)
- [blocked_user_screen.dart](lib/screen/blocked_user_screen/blocked_user_screen.dart)
- [camera_edit_screen_controller.dart](lib/screen/camera_edit_screen/camera_edit_screen_controller.dart)
- [camera_screen_controller.dart](lib/screen/camera_screen/camera_screen_controller.dart)
- [chat_screen_controller.dart](lib/screen/chat_screen/chat_screen_controller.dart)
- [chat_story_reply_message.dart](lib/screen/chat_screen/message_type_widget/chat_story_reply_message.dart)
- [chat_thread.dart](lib/model/chat/chat_thread.dart)
- [comment_card.dart](lib/screen/comment_sheet/widget/comment_card.dart)
- [comment_helper.dart](lib/screen/comment_sheet/helper/comment_helper.dart)
- [comment_sheet_controller.dart](lib/screen/comment_sheet/comment_sheet_controller.dart)
- [const_res.dart](lib/utilities/const_res.dart)
- [create_feed_screen_controller.dart](lib/screen/create_feed_screen/create_feed_screen_controller.dart)
- [dashboard_screen.dart](lib/screen/dashboard_screen/dashboard_screen.dart)
- [dashboard_screen_controller.dart](lib/screen/dashboard_screen/dashboard_screen_controller.dart)
- [firebase_firestore_controller.dart](lib/common/controller/firebase_firestore_controller.dart)
- [firebase_notification_manager.dart](lib/common/manager/firebase_notification_manager.dart)
- [follow_controller.dart](lib/common/controller/follow_controller.dart)
- [follow_following_screen.dart](lib/screen/follow_following_screen/follow_following_screen.dart)
- [follow_following_screen_controller.dart](lib/screen/follow_following_screen/follow_following_screen_controller.dart)
- [home_screen_controller.dart](lib/screen/home_screen/home_screen_controller.dart)
- [Info.plist](ios/Runner/Info.plist)
- [live_stream_search_screen_controller.dart](lib/screen/live_stream/live_stream_search_screen/live_stream_search_screen_controller.dart)
- [live_video_player.dart](lib/screen/live_stream/livestream_screen/view/live_video_player.dart)
- [livestream_comment_view.dart](lib/screen/live_stream/livestream_screen/view/livestream_comment_view.dart)
- [livestream_screen_controller.dart](lib/screen/live_stream/livestream_screen/livestream_screen_controller.dart)
- [main.dart](lib/main.dart)
- [members_sheet.dart](lib/screen/live_stream/livestream_screen/widget/members_sheet.dart)
- [message_screen.dart](lib/screen/message_screen/message_screen.dart)
- [music_sheet.dart](lib/screen/music_sheet/music_sheet.dart)
- [notification_screen.dart](lib/screen/notification_screen/notification_screen.dart)
- [notification_screen_controller.dart](lib/screen/notification_screen/notification_screen_controller.dart)
- [Podfile.lock](ios/Podfile.lock)
- [post_screen_controller.dart](lib/screen/post_screen/post_screen_controller.dart)
- [post_view_center.dart](lib/screen/post_screen/widget/post_view_center.dart)
- [profile_screen_controller.dart](lib/screen/profile_screen/profile_screen_controller.dart)
- [profile_user_header.dart](lib/screen/profile_screen/widget/profile_user_header.dart)
- [pubspec.yaml](pubspec.yaml)
- [qr_code_screen.dart](lib/screen/qr_code_screen/qr_code_screen.dart)
- [qr_code_screen_controller.dart](lib/screen/qr_code_screen/qr_code_screen_controller.dart)
- [reel_page.dart](lib/screen/reels_screen/reel/reel_page.dart)
- [reel_page_controller.dart](lib/screen/reels_screen/reel/reel_page_controller.dart)
- [reel_seek_bar.dart](lib/screen/reels_screen/reel/widget/reel_seek_bar.dart)
- [reels_screen.dart](lib/screen/reels_screen/reels_screen.dart)
- [reels_screen_controller.dart](lib/screen/reels_screen/reels_screen_controller.dart)
- [scan_qr_code_screen.dart](lib/screen/scan_qr_code_screen/scan_qr_code_screen.dart)
- [selected_music_sheet_controller.dart](lib/screen/selected_music_sheet/selected_music_sheet_controller.dart)
- [send_gift_sheet_controller.dart](lib/screen/gift_sheet/send_gift_sheet_controller.dart)
- [session_manager.dart](lib/common/manager/session_manager.dart)
- [settings_screen_controller.dart](lib/screen/settings_screen/settings_screen_controller.dart)
- [splash_screen_controller.dart](lib/screen/splash_screen/splash_screen_controller.dart)
- [text_button_custom.dart](lib/common/widget/text_button_custom.dart)
- [url_meta_data_card.dart](lib/screen/create_feed_screen/widget/url_meta_data_card.dart)
- [user_information.dart](lib/screen/reels_screen/reel/widget/user_information.dart)
- [user_service.dart](lib/common/service/api/user_service.dart)
- [web_service.dart](lib/common/service/utils/web_service.dart)
- README.md

#### Added Files

- network_helper.dart
- url_card.dart
- video_cache_helper.dart

----------------------------------------------------------------------------------------------------

# Date: 17 June 2025

## Summary

- 🐞 Bug fixes and performance improvements.

#### Updated Files

- [ads_controller.dart](lib/common/controller/ads_controller.dart)
- [asset_res.dart](lib/utilities/asset_res.dart)
- [comment_bottom_text_field_view.dart](lib/screen/comment_sheet/widget/comment_bottom_text_field_view.dart)
- [comment_card.dart](lib/screen/comment_sheet/widget/comment_card.dart)
- [custom_drop_down.dart](lib/common/widget/custom_drop_down.dart)
- [explore_screen.dart](lib/screen/explore_screen/explore_screen.dart)
- [firebase_notification_manager.dart](lib/common/manager/firebase_notification_manager.dart)
- [gif_sheet.dart](lib/screen/gif_sheet/gif_sheet.dart)
- [home_screen.dart](lib/screen/home_screen/home_screen.dart)
- [home_screen_controller.dart](lib/screen/home_screen/home_screen_controller.dart))
- [languages_keys.dart](lib/languages/languages_keys.dart)
- [live_stream_search_screen_controller.dart](lib/screen/live_stream/live_stream_search_screen/live_stream_search_screen_controller.dart)
- [livestream_comment.dart](lib/model/livestream/livestream_comment.dart)
- [livestream_screen_controller.dart](lib/screen/live_stream/livestream_screen/livestream_screen_controller.dart)
- [main.dart](lib/main.dart))
- [more_user_sheet.dart](lib/screen/share_sheet_widget/widget/more_user_sheet.dart)
- [post_view_center.dart](lib/screen/post_screen/widget/post_view_center.dart)
- [profile_screen.dart](lib/screen/profile_screen/profile_screen.dart)
- [qr_code_screen.dart](lib/screen/qr_code_screen/qr_code_screen.dart)
- [reels_screen_controller.dart](lib/screen/reels_screen/reels_screen_controller.dart)
- [report_sheet.dart](lib/screen/report_sheet/report_sheet.dart)
- [report_sheet_controller.dart](lib/screen/report_sheet/report_sheet_controller.dart)
- [request_withdrawal_screen.dart](lib/screen/request_withdrawal_screen/request_withdrawal_screen.dart)
- [settings_screen.dart](lib/screen/settings_screen/settings_screen.dart)
- [share_sheet_widget.dart](lib/screen/share_sheet_widget/share_sheet_widget.dart)
- [system_notification_page.dart](lib/screen/notification_screen/widget/system_notification_page.dart)
- [user_information.dart](lib/screen/reels_screen/reel/widget/user_information.dart)
- [video_player_screen.dart](lib/screen/video_player_screen/video_player_screen.dart)

#### Added Files

- none

#### Deleted Files

- none

----------------------------------------------------------------------------------------------------

# Date: 16 June 2025

## Summary

- New Project

#### Updated Files

- none

#### Added Files

- none

#### Deleted Files

- none


flutter clean
flutter pub get
cd ios
pod install
pod update --verbose



flutter clean
flutter pub get
flutter build appbundle --release
open build/app/outputs/bundle/release/
open build/app/outputs/bundle/release/
