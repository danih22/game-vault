import 'package:flutter/material.dart';
import 'package:game_vault/models/game.dart';
import 'package:game_vault/services/game_service.dart';
import 'package:game_vault/screens/edit_game_screen.dart';

class GameDetailScreen extends StatefulWidget {
  final Game game;

  const GameDetailScreen({
    super.key,
    required this.game,
  });

  @override
  State<GameDetailScreen> createState() => _GameDetailScreenState();
}

class _GameDetailScreenState extends State<GameDetailScreen> {
  final _gameService = GameService();
  bool _isDeleting = false;

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

  Future<void> _delete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar juego'),
        content: Text('¿Seguro que quieres eliminar "${widget.game.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isDeleting = true);

    try {
      await _gameService.deleteGame(widget.game.id);

      if (!mounted) return;

      // devolvemos true para refrescar Home
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al eliminar: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isDeleting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final game = widget.game;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle del juego'),
        actions: [


//  Botón de editar
          IconButton(
  onPressed: () async {
    final shouldRefresh = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => EditGameScreen(game: widget.game),
      ),
    );

    if (shouldRefresh == true) {
      if (!mounted) return;
      Navigator.pop(context, true); // para refrescar Home
    }
  },
  icon: const Icon(Icons.edit),
),


// Botón de eliminar
          IconButton(
            onPressed: _isDeleting ? null : _delete,
            icon: _isDeleting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.delete),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Text(
              game.title,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Estado'),
              subtitle: Text(_statusLabel(game.status)),
            ),
            const Divider(),

            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Plataforma'),
              subtitle: Text(game.platform ?? '—'),
            ),
            const Divider(),

            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Rating'),
              subtitle: Text(game.rating?.toString() ?? '—'),
            ),
            const Divider(),

            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Notas'),
              subtitle: Text(
                (game.notes == null || game.notes!.trim().isEmpty)
                    ? '—'
                    : game.notes!,
              ),
            ),
          ],
        ),
      ),
    );
  }
}