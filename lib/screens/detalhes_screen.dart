import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../database/database_helper.dart';
import '../models/registro.dart';
import '../services/photo_service.dart';
import '../utils/formatters.dart';
import '../widgets/foto_registro.dart';

class DetalhesScreen extends StatefulWidget {
  final Registro registro;

  const DetalhesScreen({super.key, required this.registro});

  @override
  State<DetalhesScreen> createState() => _DetalhesScreenState();
}

class _DetalhesScreenState extends State<DetalhesScreen> {
  bool _excluindo = false;

  Future<void> _confirmarExclusao() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir registro?'),
        content: const Text(
          'O registro e a foto serão apagados permanentemente do aparelho.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
    if (confirmar != true) return;

    setState(() => _excluindo = true);
    try {
      await DatabaseHelper.instance.excluir(widget.registro.id!);
      await PhotoService().excluirFoto(widget.registro.caminhoFoto);
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _excluindo = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao excluir: $e')),
      );
    }
  }

  void _copiarCoordenadas() {
    final r = widget.registro;
    Clipboard.setData(ClipboardData(
      text: '${formatarCoordenada(r.latitude)}, ${formatarCoordenada(r.longitude)}',
    ));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Coordenadas copiadas.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.registro;
    final texto = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes'),
        actions: [
          IconButton(
            tooltip: 'Excluir',
            onPressed: _excluindo ? null : _confirmarExclusao,
            icon: const Icon(Icons.delete_outline),
          ),
        ],
      ),
      body: ListView(
        children: [
          Container(
            color: Colors.black,
            height: 340,
            child: Hero(
              tag: 'foto_${r.id}',
              child: FotoRegistro(caminho: r.caminhoFoto, fit: BoxFit.contain),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
            child: Text(r.titulo, style: texto.headlineSmall),
          ),
          if (r.descricao.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(r.descricao, style: texto.bodyLarge),
            ),
          const Divider(height: 32),
          ListTile(
            leading: const Icon(Icons.calendar_today),
            title: const Text('Data'),
            subtitle: Text(formatarData(r.dataHora)),
          ),
          ListTile(
            leading: const Icon(Icons.schedule),
            title: const Text('Hora'),
            subtitle: Text(formatarHora(r.dataHora)),
          ),
          ListTile(
            leading: const Icon(Icons.location_on),
            title: const Text('Localização'),
            subtitle: Text(
              'Latitude: ${formatarCoordenada(r.latitude)}\n'
              'Longitude: ${formatarCoordenada(r.longitude)}',
            ),
            isThreeLine: true,
            trailing: IconButton(
              tooltip: 'Copiar coordenadas',
              icon: const Icon(Icons.copy),
              onPressed: _copiarCoordenadas,
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
