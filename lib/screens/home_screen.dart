import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:game_vault/models/game.dart';
import 'package:game_vault/services/game_service.dart';
import 'package:game_vault/screens/login_screen.dart';
import 'package:game_vault/screens/add_game_screen.dart';
import 'package:game_vault/screens/game_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final gameService = GameService();

  late Future<List<Game>> gamesFuture;

  // filtro actual
  String selectedFilter = 'Todas';

// ===============================
//  WIDGETS DE LA UI
// ===============================
  Widget _buildKpiCard({
  required String title,
  required String value,
  required IconData icon,
  required Color color,
}) {
  return Expanded(
    child: Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
        child: Column(
          children: [
            Icon(icon, color: color, size: 26),
            const SizedBox(height: 6),
            Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              title,
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    ),
  );
}

Widget _buildKpiSection({
  required int total,
  required int completed,
  required int playing,
  required int pending,
}) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    child: Row(
      children: [
        _buildKpiCard(
          title: 'Total',
          value: total.toString(),
          icon: Icons.videogame_asset,
          color: Colors.blue,
        ),
        const SizedBox(width: 8),
        _buildKpiCard(
          title: 'Completados',
          value: completed.toString(),
          icon: Icons.check_circle,
          color: Colors.green,
        ),
        const SizedBox(width: 8),
        _buildKpiCard(
          title: 'Jugando',
          value: playing.toString(),
          icon: Icons.sports_esports,
          color: Colors.orange,
        ),
        const SizedBox(width: 8),
        _buildKpiCard(
          title: 'Pendientes',
          value: pending.toString(),
          icon: Icons.schedule,
          color: Colors.grey,
        ),
      ],
    ),
  );
}

  @override
  void initState() {
    super.initState();
    gamesFuture = _loadGames();
  }

  Future<List<Game>> _loadGames() async {
    return await gameService.getUserGames();
  }

  // ===============================
  //  LOGOUT
  // ===============================
  Future<void> _logout() async {
    await Supabase.instance.client.auth.signOut();

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  // ===============================
  //  FILTRADO
  // ===============================
  List<Game> _applyFilter(List<Game> games) {
    if (selectedFilter == 'Todas') return games;

    return games.where((g) {
      switch (selectedFilter) {
        case 'Pendiente':
          return g.status == 'pending';
        case 'Jugando':
          return g.status == 'playing';
        case 'Completado':
          return g.status == 'completed';
        case 'Abandonado':
          return g.status == 'abandoned';
        default:
          return true;
      }
    }).toList();
  }

  // ===============================
  // CHIP DE ESTADO DEL JUEGO
  // ===============================
  Widget _buildStatusChip(String status) {
    Color color;
    String text;

    switch (status) {
      case 'playing':
        color = Colors.blue;
        text = 'Jugando';
        break;
      case 'completed':
        color = Colors.green;
        text = 'Completado';
        break;
      case 'pending':
        color = Colors.orange;
        text = 'Pendiente';
        break;
      case 'abandoned':
        color = Colors.red;
        text = 'Abandonado';
        break;
      default:
        color = Colors.grey;
        text = status;
    }

    return Chip(
      label: Text(text),
      backgroundColor: color.withOpacity(0.15),
      labelStyle: TextStyle(
        color: color,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  // ===============================
  //  BARRA DE PROGRESO DE LA BIBLIOTECA
  // ===============================
  Widget _buildProgressSection({
    required int total,
    required int completed,
  }) {
    final percent = total == 0 ? 0.0 : completed / total;

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Progreso de la biblioteca',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            // barra de progreso animada
          TweenAnimationBuilder<double>(
  tween: Tween(begin: 0, end: percent),
  duration: const Duration(milliseconds: 800),
  builder: (context, value, _) {
    return LinearProgressIndicator(
      value: value,
      minHeight: 10,
      borderRadius: BorderRadius.circular(10),
    );
  },
),

            const SizedBox(height: 8),

            // texto porcentaje
            Text(
              '${(percent * 100).toStringAsFixed(1)}% completado',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  // ===============================
  //  UI PRINCIPAL
  // ===============================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Game Vault 🏆'),
        actions: [
          IconButton(
            onPressed: _logout,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),


      // ===============================
      //  BOTÓN AÑADIR
      // ===============================
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
              gamesFuture = _loadGames();
            });
          }
        },
        child: const Icon(Icons.add),
      ),

      // ===============================
      //  BODY
      // ===============================
      body: FutureBuilder<List<Game>>(
        future: gamesFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final allGames = snapshot.data!;

final total = allGames.length;

final completed =
    allGames.where((g) => g.status == 'completed').length;

final playing =
    allGames.where((g) => g.status == 'playing').length;

final pending =
    allGames.where((g) => g.status == 'pending').length;

    final filteredGames = _applyFilter(allGames);

if (filteredGames.isEmpty) {
  return CustomScrollView(
    slivers: [

      SliverToBoxAdapter(
        child: _buildKpiSection(
          total: total,
          completed: completed,
          playing: playing,
          pending: pending,
        ),
      ),

      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: const [
              SizedBox(height: 60),

              Icon(
                Icons.videogame_asset_off,
                size: 60,
                color: Colors.grey,
              ),

              SizedBox(height: 16),

              Text(
                "Tu biblioteca está vacía",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              SizedBox(height: 8),

              Text(
                "Pulsa + para añadir tu primer juego",
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),

    ],
  );
}

              allGames.where((g) => g.status == 'completed').length;

          return CustomScrollView(
            slivers: [

// ===============================
//  KPIS
// ===============================
              SliverToBoxAdapter(
  child: _buildKpiSection(
    total: total,
    completed: completed,
    playing: playing,
    pending: pending,
  ),
),
              // ===============================
              //  DASHBOARD (PRO)
              // ===============================
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: _buildProgressSection(
                    total: total,
                    completed: completed,
                  ),
                ),
              ),

              // ===============================
              //  FILTROS
              // ===============================
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Wrap(
                    spacing: 8,
                    children: [
                      for (final filter in [
                        'Todas',
                        'Pendiente',
                        'Jugando',
                        'Completado',
                        'Abandonado',
                      ])
                        ChoiceChip(
                          label: Text(filter),
                          selected: selectedFilter == filter,
                          onSelected: (_) {
                            setState(() {
                              selectedFilter = filter;
                            });
                          },
                        ),
                    ],
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 12)),

              // ===============================
              //  LISTA DE JUEGOS
              // ===============================
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final game = filteredGames[index];

                    return ListTile(
                      leading: game.coverUrl != null
                          ? Image.network(
                              game.coverUrl!,
                              width: 50,
                              fit: BoxFit.cover,
                            )
                          : const Icon(Icons.videogame_asset),
                      title: Text(game.title),
                      subtitle: Text(game.platform ?? '—'),
                      trailing: _buildStatusChip(game.status),
                      onTap: () async {
                        final shouldRefresh =
                            await Navigator.push<bool>(
                          context,
                          MaterialPageRoute(
                            builder: (_) => GameDetailScreen(game: game),
                          ),
                        );

                        if (shouldRefresh == true) {
                          setState(() {
                            gamesFuture = _loadGames();
                          });
                        }
                      },
                    );
                  },
                  childCount: filteredGames.length,
                ),
              ),
            ],
          );
        },
      ),
    );

    
  }
}