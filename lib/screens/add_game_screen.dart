import 'package:flutter/material.dart';
import 'package:game_vault/services/game_service.dart';
import 'package:game_vault/screens/rawg_search_screen.dart'; 

class AddGameScreen extends StatefulWidget {
  const AddGameScreen({super.key});

  @override
  State<AddGameScreen> createState() => _AddGameScreenState();
}

class _AddGameScreenState extends State<AddGameScreen> {
  final _formKey = GlobalKey<FormState>();
  final _gameService = GameService();

  final _titleController = TextEditingController();
  final _notesController = TextEditingController();
  final _ratingController = TextEditingController();

  String _status = 'pending';

  // Lista de plataformas (dropdown)
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

  //  RAWG datos del juego seleccionado en la API
  int? _apiGameId; 
  String? _coverUrl; 

  @override
  void dispose() {
    _titleController.dispose();
    _notesController.dispose();
    _ratingController.dispose();
    super.dispose();
  }

  //  RAWG abrir buscador RAWG y rellenar automáticamente
  Future<void> _openRawgSearch() async {
    final selected = await Navigator.push<RawgSelectedGame>(
      context,
      MaterialPageRoute(builder: (_) => const RawgSearchScreen()),
    );

    if (selected == null) return;

    setState(() {
      _apiGameId = selected.apiGameId;
      _coverUrl = selected.coverUrl;
    });

    // Rellenamos el título automáticamente
    _titleController.text = selected.title;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final title = _titleController.text.trim();
    final notes = _notesController.text.trim();
    final ratingText = _ratingController.text.trim();

    final int? rating = ratingText.isEmpty ? null : int.tryParse(ratingText);

    setState(() => _isLoading = true);

    try {
      await _gameService.insertGame(
        title: title,
        status: _status,
        platform: _platform,
        notes: notes.isEmpty ? null : notes,
        rating: rating,
        apiGameId: _apiGameId, 
        coverUrl: _coverUrl, 
      );

      if (!mounted) return;

      // Avisamos a Home para refrescar
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
        title: const Text('Añadir juego'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [


              //  Título
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
              const SizedBox(height: 12),

              //  RAWG botón para buscar 
              OutlinedButton.icon(
                onPressed: _isLoading ? null : _openRawgSearch,
                icon: const Icon(Icons.search),
                label: const Text('Buscar en RAWG'),
              ),

              //  RAWG mostrar info básica de selección
              if (_apiGameId != null) ...[
                const SizedBox(height: 8),
                Text(
                  'Seleccionado (RAWG id): $_apiGameId',
                  style: const TextStyle(fontSize: 12),
                ),
              ],

//  RAWG mostrar portada si la hay
              if (_coverUrl != null) ...[
  const SizedBox(height: 12),
  Center(
    child: ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.network(
        _coverUrl!,
        height: 180,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) =>
            const Icon(Icons.broken_image, size: 80),
      ),
    ),
  ),
],

              const SizedBox(height: 16),

              //  Estado
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

              //  Plataforma (dropdown)
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

              //  Rating
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

              //  Notas
              TextFormField(
                controller: _notesController,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Notas',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),

              //  Guardar
              ElevatedButton.icon(
                onPressed: _isLoading ? null : _save,
                icon: _isLoading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.save),
                label: Text(_isLoading ? 'Guardando...' : 'Guardar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}