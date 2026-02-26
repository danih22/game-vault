import 'dart:async';
import 'package:flutter/material.dart';
import 'package:game_vault/services/rawg_service.dart';

class RawgSelectedGame {
  final int apiGameId;
  final String title;
  final String? coverUrl;

  RawgSelectedGame({
    required this.apiGameId,
    required this.title,
    required this.coverUrl,
  });
}

class RawgSearchScreen extends StatefulWidget {
  const RawgSearchScreen({super.key});

  @override
  State<RawgSearchScreen> createState() => _RawgSearchScreenState();
}

class _RawgSearchScreenState extends State<RawgSearchScreen> {
  final _controller = TextEditingController();
  Timer? _debounce;

  late final RawgService _rawg;

  List<RawgGameResult> _results = [];
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    // La key viene por dart-define
    const key = String.fromEnvironment('RAWG_KEY');
    _rawg = RawgService(apiKey: key);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () async {
      final q = value.trim();
      if (q.isEmpty) {
        setState(() {
          _results = [];
          _error = null;
        });
        return;
      }

      setState(() {
        _loading = true;
        _error = null;
      });

      try {
        final res = await _rawg.searchGames(query: q, pageSize: 12);
        if (!mounted) return;
        setState(() => _results = res);
      } catch (e) {
        if (!mounted) return;
        setState(() => _error = e.toString());
      } finally {
        if (mounted) setState(() => _loading = false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    const key = String.fromEnvironment('RAWG_KEY');
    final keyOk = key.isNotEmpty;

    return Scaffold(
      appBar: AppBar(title: const Text('Buscar juego (RAWG)')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (!keyOk)
              const Padding(
                padding: EdgeInsets.only(bottom: 12),
                child: Text(
                  'Falta RAWG_KEY. Ejecuta: flutter run --dart-define=RAWG_KEY=TU_KEY',
                ),
              ),
            TextField(
              controller: _controller,
              onChanged: _onChanged,
              decoration: const InputDecoration(
                labelText: 'Buscar...',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            if (_loading) const LinearProgressIndicator(),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text('Error: $_error'),
              ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.separated(
                itemCount: _results.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, i) {
                  final g = _results[i];
                  return ListTile(
                    leading: (g.backgroundImage == null)
                        ? const Icon(Icons.videogame_asset)
                        : Image.network(
                            g.backgroundImage!,
                            width: 56,
                            height: 56,
                            fit: BoxFit.cover,
                          ),
                    title: Text(g.name),
                    subtitle: Text('RAWG id: ${g.id}'),
                    onTap: () {
                      Navigator.pop(
                        context,
                        RawgSelectedGame(
                          apiGameId: g.id,
                          title: g.name,
                          coverUrl: g.backgroundImage,
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}