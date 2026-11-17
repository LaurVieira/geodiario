import 'package:flutter/material.dart';

import '../database/database_helper.dart';
import '../models/registro.dart';
import '../widgets/registro_card.dart';
import 'detalhes_screen.dart';
import 'novo_registro_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _db = DatabaseHelper.instance;
  late Future<List<Registro>> _registros;

  @override
  void initState() {
    super.initState();
    _registros = _db.listarTodos();
  }

  Future<void> _recarregar() async {
    final consulta = _db.listarTodos();
    setState(() {
      _registros = consulta;
    });
    await consulta;
  }

  Future<void> _novoRegistro() async {
    final salvou = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const NovoRegistroScreen()),
    );
    if (salvou == true) {
      await _recarregar();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registro salvo!')),
      );
    }
  }

  Future<void> _abrirDetalhes(Registro registro) async {
    final excluiu = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => DetalhesScreen(registro: registro)),
    );
    if (excluiu == true) {
      await _recarregar();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registro excluído.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('GeoDiário')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _novoRegistro,
        icon: const Icon(Icons.add_a_photo),
        label: const Text('Novo registro'),
      ),
      body: FutureBuilder<List<Registro>>(
        future: _registros,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text('Erro ao carregar os registros:\n${snapshot.error}'),
              ),
            );
          }

          final registros = snapshot.data ?? [];
          if (registros.isEmpty) {
            return const _EstadoVazio();
          }

          return RefreshIndicator(
            onRefresh: _recarregar,
            child: GridView.builder(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 96),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.78,
              ),
              itemCount: registros.length,
              itemBuilder: (context, i) => RegistroCard(
                registro: registros[i],
                onTap: () => _abrirDetalhes(registros[i]),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _EstadoVazio extends StatelessWidget {
  const _EstadoVazio();

  @override
  Widget build(BuildContext context) {
    final cores = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.photo_camera_outlined, size: 72, color: cores.primary),
            const SizedBox(height: 16),
            Text(
              'Nenhum registro ainda',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            const Text(
              'Toque em "Novo registro" para fotografar um lugar. '
              'A data, a hora e a localização são salvas automaticamente.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
