import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:game_vault/screens/login_screen.dart';
import 'package:game_vault/screens/game_detail_screen.dart';
import 'package:game_vault/services/game_service.dart';
import 'package:game_vault/models/game.dart';
import 'package:game_vault/screens/add_game_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final gameService = GameService();

  late Future<List<Game>> gamesFuture;

  // ✅ FILTROS: estado actual del filtro
  String _filterStatus = 'all';

  // ✅ FILTROS: cache de todos los juegos
  List<Game> _allGames = [];

  @override
  void initState() {
    super.initState();
    // ✅ FILTROS: ahora usamos loader propio
    gamesFuture = _loadGames();
  }

  // ✅ FILTROS: cargar juegos y guardarlos en memoria
  Future<List<Game>> _loadGames() async {
    final games = await gameService.getUserGames();
    _allGames = games;
    return _applyFilter();
  }

  // ✅ FILTROS: aplicar filtro en memoria
  List<Game> _applyFilter() {
    if (_filterStatus == 'all') return _allGames;

    return _allGames.where((g) => g.status == _filterStatus).toList();
  }

  // 🔐 Logout
  Future<void> _logout() async {
    await Supabase.instance.client.auth.signOut();

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => const LoginScreen(),
      ),
      (route) => false,
    );
  }

  // 🎨 helper texto estado
  String _statusLabel(String status) {
    switch (status) {
      case 'pending':
        return 'Pendiente';
      case 'playing':
        return 'Jugando';
      case 'completed':
        return 'Completado';
      case 'abandoned':
        return 'Abandonado';
      default:
        return status;
    }
  }

  // 🎨 helper color estado
  Color _statusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'playing':
        return Colors.blue;
      case 'completed':
        return Colors.green;
      case 'abandoned':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  // ✅ FILTROS: widget del chip
  Widget _buildFilterChip(String value, String label) {
    final selected = _filterStatus == value;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) {
          setState(() {
            _filterStatus = value;
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Game Vault'),
        actions: [
          IconButton(
            onPressed: _logout,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),

      // ➕ botón añadir
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final shouldRefresh = await Navigator.push<bool>(
            context,
            MaterialPageRoute(
              builder: (_) => const AddGameScreen(),
            ),
          );

          if (shouldRefresh == true) {
            setState(() {
              gamesFuture = _loadGames(); // ✅ FILTROS: recarga correcta
            });
          }
        },
        child: const Icon(Icons.add),
      ),

      // ================== BODY ==================
      body: Column(
        children: [
          // ✅ FILTROS: barra horizontal
          SizedBox(
            height: 56,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                _buildFilterChip('all', 'Todas'),
                _buildFilterChip('pending', 'Pendiente'),
                _buildFilterChip('playing', 'Jugando'),
                _buildFilterChip('completed', 'Completado'),
                _buildFilterChip('abandoned', 'Abandonado'),
              ],
            ),
          ),

          // ================== LISTA ==================
          Expanded(
            child: FutureBuilder<List<Game>>(
              future: gamesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                }

                // ✅ FILTROS: aplicamos filtro en memoria
                final games = _applyFilter();

                if (games.isEmpty) {
                  return const Center(
                    child: Text('No hay juegos con este filtro'),
                  );
                }

                return ListView.builder(
                  itemCount: games.length,
                  itemBuilder: (context, index) {
                    final game = games[index];

                    return ListTile(
                      // 🎮 portada
                      leading: (game.coverUrl == null)
                          ? const Icon(Icons.videogame_asset)
                          : ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                game.coverUrl!,
                                width: 56,
                                height: 56,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) =>
                                    const Icon(Icons.broken_image),
                              ),
                            ),

                      title: Text(game.title),

                      // 🎨 chip de estado + plataforma
                      subtitle: Row(
                        children: [
                          Chip(
                            label: Text(
                              _statusLabel(game.status),
                              style: const TextStyle(
                                  color: Colors.white),
                            ),
                            backgroundColor:
                                _statusColor(game.status),
                            visualDensity: VisualDensity.compact,
                            padding: EdgeInsets.zero,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child:
                                Text(game.platform ?? '—'),
                          ),
                        ],
                      ),

                      // 🔍 ir a detalle
                      onTap: () async {
                        final shouldRefresh =
                            await Navigator.push<bool>(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                GameDetailScreen(game: game),
                          ),
                        );

                        if (shouldRefresh == true) {
                          setState(() {
                            gamesFuture = _loadGames(); // ✅ FILTROS
                          });
                        }
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}