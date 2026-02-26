import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:game_vault/models/game.dart';

class GameService {
  final _supabase = Supabase.instance.client;

  //  Obtener juegos del usuario
  Future<List<Game>> getUserGames() async {
    final user = _supabase.auth.currentUser;

    if (user == null) {
      throw Exception('Usuario no autenticado');
    }

    final response = await _supabase
        .from('games')
        .select()
        .eq('user_id', user.id)
        .order('created_at', ascending: false);

    return (response as List)
        .map((json) => Game.fromJson(json))
        .toList();
  }

  //  Insertar juego
  Future<void> insertGame({
    required String title,
    required String status,
    String? platform,
    int? rating,
    String? notes,
    String? coverUrl,
    int? apiGameId,
  }) async {
    final user = _supabase.auth.currentUser;

    if (user == null) {
      throw Exception('Usuario no autenticado');
    }

    await _supabase.from('games').insert({
      'user_id': user.id,
      'title': title,
      'status': status,
      'platform': platform,
      'rating': rating,
      'notes': notes,
      'cover_url': coverUrl,
      'api_game_id': apiGameId,
    });
  }

  //  BORRAR juego por ID
  Future<void> deleteGame(String gameId) async {
    final user = _supabase.auth.currentUser;

    if (user == null) {
      throw Exception('Usuario no autenticado');
    }

    await _supabase
        .from('games')
        .delete()
        .eq('id', gameId);
  }

//  ACTUALIZAR juego por ID
Future<void> updateGame({
  required String gameId,
  required String title,
  required String status,
  String? platform,
  int? rating,
  String? notes,
}) async {
  final user = _supabase.auth.currentUser;

  if (user == null) {
    throw Exception('Usuario no autenticado');
  }

  await _supabase.from('games').update({
    'title': title,
    'status': status,
    'platform': platform,
    'rating': rating,
    'notes': notes,
  }).eq('id', gameId);
}


}