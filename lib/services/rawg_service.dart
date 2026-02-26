import 'dart:convert';
import 'package:http/http.dart' as http;

class RawgGameResult {
  final int id;
  final String name;
  final String? backgroundImage;

  RawgGameResult({
    required this.id,
    required this.name,
    required this.backgroundImage,
  });

  factory RawgGameResult.fromJson(Map<String, dynamic> json) {
    return RawgGameResult(
      id: json['id'] as int,
      name: (json['name'] ?? '') as String,
      backgroundImage: json['background_image'] as String?,
    );
  }
}

class RawgService {
  static const String _baseUrl = 'https://api.rawg.io/api';
  final String apiKey;

  RawgService({required this.apiKey});

  Future<List<RawgGameResult>> searchGames({
    required String query,
    int pageSize = 10,
  }) async {
    final q = query.trim();
    if (q.isEmpty) return [];

    final uri = Uri.parse('$_baseUrl/games').replace(queryParameters: {
      'key': apiKey,
      'search': q,
      'page_size': pageSize.toString(),
    });

    final res = await http.get(uri);
    if (res.statusCode != 200) {
      throw Exception('RAWG error ${res.statusCode}: ${res.body}');
    }

    final data = jsonDecode(res.body) as Map<String, dynamic>;
    final results = (data['results'] as List).cast<Map<String, dynamic>>();
    return results.map(RawgGameResult.fromJson).toList();
  }
}