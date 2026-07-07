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

  static const String _giphyApiKey = 'tCX9tP23tZuDtZkBMtnW0drVwK4c5aus';
  int paginationLimit = 30;

  Future<List<GiphyData>> search({
    required String apiKey,
    required String keyWord,
    required int startCount,
    GiphyRating giphyRating = GiphyRating.g,
  }) async {
    final url =
        'https://api.giphy.com/v1/gifs/search?api_key=$_giphyApiKey&q=$keyWord&limit=$paginationLimit&offset=$startCount&rating=${giphyRating.title}';
    Loggers.info(url);
    final response = await http.get(Uri.parse(url));
    print('GIPHY SEARCH STATUS: ${response.statusCode}');
    print('GIPHY SEARCH BODY: ${response.body.substring(0, response.body.length > 300 ? 300 : response.body.length)}');
    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      final model = GiphyModel.fromJson(decoded);
      return model.data ?? [];
    }
    return [];
  }

  Future<List<GiphyData>> trending({
    required String apiKey,
    GiphyRating giphyRating = GiphyRating.g,
    required int startCount,
  }) async {
    final url =
        'https://api.giphy.com/v1/gifs/trending?api_key=$_giphyApiKey&limit=$paginationLimit&offset=$startCount&rating=${giphyRating.title}';
    Loggers.info(url);
    final response = await http.get(Uri.parse(url));
    print('GIPHY TRENDING STATUS: ${response.statusCode}');
    print('GIPHY TRENDING BODY: ${response.body.substring(0, response.body.length > 300 ? 300 : response.body.length)}');
    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      final model = GiphyModel.fromJson(decoded);
      return model.data ?? [];
    }
    return [];
  }
}
