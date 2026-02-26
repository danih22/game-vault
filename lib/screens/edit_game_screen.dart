import 'package:flutter/material.dart';
import 'package:game_vault/models/game.dart';
import 'package:game_vault/services/game_service.dart';

class EditGameScreen extends StatefulWidget {
  final Game game;

  const EditGameScreen({
    super.key,
    required this.game,
  });

  @override
  State<EditGameScreen> createState() => _EditGameScreenState();
}

class _EditGameScreenState extends State<EditGameScreen> {
  final _formKey = GlobalKey<FormState>();
  final _gameService = GameService();

  late final TextEditingController _titleController;
  late final TextEditingController _notesController;
  late final TextEditingController _ratingController;

  String _status = 'pending';

  final List<String> _platforms = const [
    'PC',
    'PlayStation 5',
    'PlayStation 4',
    'Xbox Series X|S',
    'Xbox One',
    'Nintendo Switch',
    'Steam Deck',
    'Android',
    'iOS',
  ];

  String? _platform;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.game.title);
    _notesController = TextEditingController(text: widget.game.notes ?? '');
    _ratingController =
        TextEditingController(text: widget.game.rating?.toString() ?? '');
    _status = widget.game.status;
    _platform = widget.game.platform;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _notesController.dispose();
    _ratingController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final title = _titleController.text.trim();
    final notes = _notesController.text.trim();
    final ratingText = _ratingController.text.trim();

    final int? rating =
        ratingText.isEmpty ? null : int.tryParse(ratingText);

    setState(() => _isLoading = true);

    try {
      await _gameService.updateGame(
        gameId: widget.game.id,
        title: title,
        status: _status,
        platform: _platform,
        notes: notes.isEmpty ? null : notes,
        rating: rating,
      );

      if (!mounted) return;

      // devolvemos true para refrescar donde venimos (detalle / home)
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al guardar: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar juego'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Título *',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  final v = value?.trim() ?? '';
                  if (v.isEmpty) return 'El título es obligatorio';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                value: _status,
                decoration: const InputDecoration(
                  labelText: 'Estado',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'pending', child: Text('Pendiente')),
                  DropdownMenuItem(value: 'playing', child: Text('Jugando')),
                  DropdownMenuItem(value: 'completed', child: Text('Completado')),
                  DropdownMenuItem(value: 'abandoned', child: Text('Abandonado')),
                ],
                onChanged: (value) {
                  if (value == null) return;
                  setState(() => _status = value);
                },
              ),
              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                value: _platform,
                decoration: const InputDecoration(
                  labelText: 'Plataforma',
                  border: OutlineInputBorder(),
                ),
                items: _platforms
                    .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                    .toList(),
                onChanged: (value) => setState(() => _platform = value),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _ratingController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Rating (0-10)',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  final v = value?.trim() ?? '';
                  if (v.isEmpty) return null;
                  final n = int.tryParse(v);
                  if (n == null) return 'Introduce un número';
                  if (n < 0 || n > 10) return 'Debe estar entre 0 y 10';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _notesController,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Notas',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),

              ElevatedButton.icon(
                onPressed: _isLoading ? null : _save,
                icon: _isLoading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.save),
                label: Text(_isLoading ? 'Guardando...' : 'Guardar cambios'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}