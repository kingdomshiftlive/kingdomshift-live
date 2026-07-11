import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:shortzz/common/controller/base_controller.dart';
import 'package:shortzz/common/service/api/post_service.dart';
import 'package:shortzz/model/post_story/post_model.dart';
import 'package:shortzz/screen/create_feed_screen/create_feed_screen.dart';

class PodcastScreenController extends BaseController {
  RxList<Post> episodes = <Post>[].obs;
  RxDouble volume = 1.0.obs;
  RxList<String> categories = <String>['All'].obs;
  RxString selectedCategory = 'All'.obs;

  final AudioPlayer audioPlayer = AudioPlayer();
  Rx<Post?> currentlyPlaying = Rx<Post?>(null);
  RxBool isPlaying = false.obs;

  @override
  void onInit() {
    super.onInit();
    audioPlayer.playerStateStream.listen((state) {
      isPlaying.value = state.playing;
      if (state.processingState == ProcessingState.completed) {
        skipNext();
      }
    });
    fetchPodcasts();
  }

  @override
  void onClose() {
    audioPlayer.dispose();
    super.onClose();
  }

  Future<void> fetchPodcasts() async {
    isLoading.value = true;
    final category = selectedCategory.value == 'All' ? null : selectedCategory.value;
    final result = await PostService.instance.fetchPodcasts(category: category);
    episodes.value = result;

    // Derive category chips dynamically from real data (All + whatever categories exist)
    final uniqueCats = result
        .map((e) => e.metadata ?? '')
        .where((c) => c.isNotEmpty)
        .toSet()
        .toList()
      ..sort();
    categories.value = ['All', ...uniqueCats];

    isLoading.value = false;
  }

  Future<void> onCategoryChanged(String category) async {
    if (selectedCategory.value == category) return;
    selectedCategory.value = category;
    await fetchPodcasts();
  }

  Future<void> playEpisode(Post episode) async {
    final isSameEpisode = currentlyPlaying.value?.supabaseId == episode.supabaseId;

    if (isSameEpisode) {
      await togglePlayPause();
      return;
    }

    final url = episode.video ?? '';
    if (url.isEmpty) return;

    try {
      currentlyPlaying.value = episode;
      await audioPlayer.setUrl(url);
      await audioPlayer.play();
    } catch (e) {
      print('PODCAST PLAYBACK ERROR: $e');
    }
  }

  Future<void> togglePlayPause() async {
    if (currentlyPlaying.value == null) return;
    if (audioPlayer.playing) {
      await audioPlayer.pause();
    } else {
      await audioPlayer.play();
    }
  }

  Future<void> skipNext() async {
    final current = currentlyPlaying.value;
    if (current == null || episodes.isEmpty) return;
    final index = episodes.indexWhere((e) => e.supabaseId == current.supabaseId);
    if (index == -1 || index >= episodes.length - 1) return;
    await playEpisode(episodes[index + 1]);
  }

  Future<void> skipPrevious() async {
    final current = currentlyPlaying.value;
    if (current == null || episodes.isEmpty) return;
    final index = episodes.indexWhere((e) => e.supabaseId == current.supabaseId);
    if (index <= 0) return;
    await playEpisode(episodes[index - 1]);
  }

  Future<void> pauseForWatch() async {
    if (audioPlayer.playing) {
      await audioPlayer.pause();
    }
  }

  void setVolume(double value) {
    volume.value = value;
    audioPlayer.setVolume(value);
  }

  Future<void> deleteEpisode(Post episode) async {
    final id = episode.supabaseId;
    if (id == null) return;

    if (currentlyPlaying.value?.supabaseId == id) {
      await audioPlayer.stop();
      currentlyPlaying.value = null;
    }

    final success = await PostService.instance.deleteSupabaseVideo(supabaseId: id);
    if (success) {
      episodes.removeWhere((e) => e.supabaseId == id);
    }
  }

  void onCreateTap() {
    Get.to(() => const CreateFeedScreen(createType: CreateFeedType.podcast));
  }

  String formatDuration(int? seconds) {
    if (seconds == null || seconds <= 0) return '';
    final minutes = (seconds / 60).round();
    return '$minutes min';
  }
}
