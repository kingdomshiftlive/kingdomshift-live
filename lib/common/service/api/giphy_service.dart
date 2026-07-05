import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shortzz/common/manager/logger.dart';
import 'package:shortzz/model/giphy/giphy_model.dart';

// https://developers.giphy.com/docs/optional-settings/#rating
enum GiphyRating {
  g,
  pg,
  pg_13,
  r;

  String get title {
    switch (this) {
      case GiphyRating.g:
        return 'g';
      case GiphyRating.pg:
        return 'pg';
      case GiphyRating.pg_13:
        return 'pg-13';
      case GiphyRating.r:
        return 'r';
    }
  }
}

class GiphyService {
  GiphyService._();

  static final GiphyService instance = GiphyService._();

  int paginationLimit = 30;

  Future<List<GiphyData>> search({
    required String apiKey,
    required String keyWord,
    required int startCount,
    GiphyRating giphyRating = GiphyRating.g,
  }) async {
    String url =
        'https://tenor.googleapis.com/v2/search?key=LIVDSRZULELA&q=$keyWord&limit=$paginationLimit&pos=$startCount&media_filter=gif';
    http.Response response = await http.get(Uri.parse(url));
    Loggers.info(url);
    print('GIPHY SEARCH STATUS: ${response.statusCode}');
    print('GIPHY SEARCH BODY: ${response.body.substring(0, response.body.length > 300 ? 300 : response.body.length)}');
    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      final results = (decoded['results'] ?? []) as List;
      return results.map((item) {
        final gifUrl = item['media_formats']?['gif']?['url']?.toString() ??
            item['media_formats']?['tinygif']?['url']?.toString() ??
            '';
        return GiphyData(
          images: GiphyImages(
            fixedWidth: FixedWidth(url: gifUrl),
            original: Original(url: gifUrl),
          ),
        );
      }).where((item) => (item.images?.fixedWidth?.url ?? '').isNotEmpty).toList();
    }
    return [];
  }

  Future<List<GiphyData>> trending(
      {required String apiKey,
      GiphyRating giphyRating = GiphyRating.g,
      required int startCount}) async {
    String url =
        'https://tenor.googleapis.com/v2/featured?key=LIVDSRZULELA&limit=$paginationLimit&pos=$startCount&media_filter=gif';
    Loggers.info(url);
    http.Response response = await http.get(Uri.parse(url));
    print('GIPHY TRENDING STATUS: ${response.statusCode}');
    print('GIPHY TRENDING BODY: ${response.body.substring(0, response.body.length > 300 ? 300 : response.body.length)}');
    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      final results = (decoded['results'] ?? []) as List;
      return results.map((item) {
        final gifUrl = item['media_formats']?['gif']?['url']?.toString() ??
            item['media_formats']?['tinygif']?['url']?.toString() ??
            '';
        return GiphyData(
          images: GiphyImages(
            fixedWidth: FixedWidth(url: gifUrl),
            original: Original(url: gifUrl),
          ),
        );
      }).where((item) => (item.images?.fixedWidth?.url ?? '').isNotEmpty).toList();
    }
    return [];
  }
}
