import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:responsi_mobile/models/anime_model.dart';

class ApiService {
  static const String baseUrl = 'https://kitsu.io/api/edge/anime';

  static Future<List<AnimeModel>> fetchAnimeList() async {
    final url = Uri.parse('$baseUrl?page[limit]=20&page[offset]=0');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        final List<dynamic> dataList = jsonResponse['data'] ?? [];

        return dataList.map((item) => AnimeModel.fromJson(item)).toList();
      } else {
        throw Exception('Gagal memuat anime. Status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Gagal menghubungi server API: $e');
    }
  }

  static Future<AnimeModel> fetchAnimeDetail(String animeId) async {
    final url = Uri.parse('$baseUrl/$animeId');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        final dynamic data = jsonResponse['data'];

        return AnimeModel.fromJson(data);
      } else {
        throw Exception('Gagal memuat detail anime. Status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Gagal mengambil data detail: $e');
    }
  }
}
