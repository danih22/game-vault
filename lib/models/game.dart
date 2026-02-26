
//Creamos la clase Game. Tiene atributos, un constructor, y métodos para convertir de y a JSON, 
//lo que es esencial para interactuar con Supabase.
class Game {
  final String id;
  final String userId;
  final String title;
  final String status;
  final String? platform;
  final String? coverUrl;
  final int? rating;
  final String? notes;
  final int? apiGameId;
  final DateTime createdAt;

  Game({
    required this.id,
    required this.userId,
    required this.title,
    required this.status,
    this.platform,
    this.coverUrl,
    this.rating,
    this.notes,
    this.apiGameId,
    required this.createdAt,
  });

  /// 🔹 Convertir de JSON (Supabase → Flutter)
  factory Game.fromJson(Map<String, dynamic> json) {
    return Game(
      id: json['id'],
      userId: json['user_id'],
      title: json['title'],
      status: json['status'],
      platform: json['platform'],
      coverUrl: json['cover_url'],
      rating: json['rating'],
      notes: json['notes'],
      apiGameId: json['api_game_id'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  /// 🔹 Convertir a JSON (Flutter → Supabase)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'status': status,
      'platform': platform,
      'cover_url': coverUrl,
      'rating': rating,
      'notes': notes,
      'api_game_id': apiGameId,
      'created_at': createdAt.toIso8601String(),
    };
  }
}