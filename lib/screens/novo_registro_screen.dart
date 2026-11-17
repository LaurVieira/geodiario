import 'dart:io';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';

import '../database/database_helper.dart';
import '../models/registro.dart';
import '../services/location_service.dart';
import '../services/photo_service.dart';
import '../utils/formatters.dart';

class NovoRegistroScreen extends StatefulWidget {
  const NovoRegistroScreen({super.key});

  @override
  State<NovoRegistroScreen> createState() => _NovoRegistroScreenState();
}

class _NovoRegistroScreenState extends State<NovoRegistroScreen> {
  final _formKey = GlobalKey<FormState>();
  final _tituloController = TextEditingController();
  final _descricaoController = TextEditingController();

  final _photoService = PhotoService();
  final _locationService = LocationService();

  XFile? _foto;
  DateTime? _dataHora;
  Position? _posicao;
  bool _obtendoLocalizacao = false;
  String? _erroLocalizacao;
  bool _salvando = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _capturarFoto());
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _descricaoController.dispose();
    super.dispose();
  }

  void _mostrarMensagem(String texto) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(texto)));
  }

  Future<void> _capturarFoto() async {
    XFile? foto;
    try {
      foto = await _photoService.capturarFoto();
    } catch (e) {
      _mostrarMensagem('Não foi possível abrir a câmera: $e');
      return;
    }
    if (foto == null || !mounted) return;

    setState(() {
      _foto = foto;
      _dataHora = DateTime.now();
      _posicao = null;
      _erroLocalizacao = null;
    });

    await _obterLocalizacao();
  }

  Future<void> _obterLocalizacao() async {
    setState(() {
      _obtendoLocalizacao = true;
      _erroLocalizacao = null;
    });
    try {
      final posicao = await _locationService.obterPosicaoAtual();
      if (!mounted) return;
      setState(() => _posicao = posicao);
    } catch (e) {
      if (!mounted) return;
      setState(() => _erroLocalizacao = e.toString());
    } finally {
      if (mounted) setState(() => _obtendoLocalizacao = false);
    }
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;
    if (_foto == null) {
      _mostrarMensagem('Tire uma foto antes de salvar.');
      return;
    }
    if (_posicao == null) {
      _mostrarMensagem('Aguarde a localização ser obtida.');
      return;
    }

    setState(() => _salvando = true);
    String? caminhoSalvo;
    try {
      caminhoSalvo = await _photoService.salvarFoto(_foto!);

      final registro = Registro(
        titulo: _tituloController.text.trim(),
        descricao: _descricaoController.text.trim(),
        caminhoFoto: caminhoSalvo,
        dataHora: _dataHora!,
        latitude: _posicao!.latitude,
        longitude: _posicao!.longitude,
      );
      await DatabaseHelper.instance.inserir(registro);

      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (caminhoSalvo != null) {
        await _photoService.excluirFoto(caminhoSalvo);
      }
      _mostrarMensagem('Erro ao salvar o registro: $e');
    } finally {
      if (mounted) setState(() => _salvando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final podeSalvar =
        _foto != null && _posicao != null && !_salvando && !_obtendoLocalizacao;

    return Scaffold(
      appBar: AppBar(title: const Text('Novo registro')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _PreviaFoto(foto: _foto, onTap: _capturarFoto),
            if (_foto != null)
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: _salvando ? null : _capturarFoto,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Tirar outra foto'),
                ),
              ),
            const SizedBox(height: 8),
            if (_foto != null)
              _PainelInformacoes(
                dataHora: _dataHora,
                posicao: _posicao,
                carregando: _obtendoLocalizacao,
                erro: _erroLocalizacao,
                onTentarNovamente: _obterLocalizacao,
              ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _tituloController,
              decoration: const InputDecoration(
                labelText: 'Título',
                hintText: 'Ex.: Praça da Liberdade',
                border: OutlineInputBorder(),
              ),
              maxLength: 60,
              textCapitalization: TextCapitalization.sentences,
              validator: (valor) =>
                  (valor == null || valor.trim().isEmpty) ? 'Informe um título' : null,
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _descricaoController,
              decoration: const InputDecoration(
                labelText: 'Descrição (opcional)',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
              maxLines: 3,
              maxLength: 200,
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: podeSalvar ? _salvar : null,
              icon: _salvando
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.save),
              label: Text(_salvando ? 'Salvando...' : 'Salvar registro'),
            ),
          ],
        ),
      ),
    );
  }
}

class _PreviaFoto extends StatelessWidget {
  final XFile? foto;
  final VoidCallback onTap;

  const _PreviaFoto({required this.foto, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cores = Theme.of(context).colorScheme;

    return AspectRatio(
      aspectRatio: 4 / 3,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: foto == null
            ? Material(
                color: cores.surfaceContainerHighest,
                child: InkWell(
                  onTap: onTap,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.photo_camera, size: 56, color: cores.primary),
                      const SizedBox(height: 8),
                      const Text('Toque para tirar uma foto'),
                    ],
                  ),
                ),
              )
            : Image.file(File(foto!.path), fit: BoxFit.cover),
      ),
    );
  }
}

class _PainelInformacoes extends StatelessWidget {
  final DateTime? dataHora;
  final Position? posicao;
  final bool carregando;
  final String? erro;
  final VoidCallback onTentarNovamente;

  const _PainelInformacoes({
    required this.dataHora,
    required this.posicao,
    required this.carregando,
    required this.erro,
    required this.onTentarNovamente,
  });

  @override
  Widget build(BuildContext context) {
    final cores = Theme.of(context).colorScheme;

    Widget linhaLocalizacao;
    if (carregando) {
      linhaLocalizacao = const ListTile(
        dense: true,
        leading: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
        title: Text('Obtendo localização...'),
      );
    } else if (erro != null) {
      linhaLocalizacao = ListTile(
        dense: true,
        leading: Icon(Icons.location_off, color: cores.error),
        title: Text(erro!, style: TextStyle(color: cores.error)),
        trailing: TextButton(
          onPressed: onTentarNovamente,
          child: const Text('Tentar de novo'),
        ),
      );
    } else if (posicao != null) {
      linhaLocalizacao = ListTile(
        dense: true,
        leading: const Icon(Icons.location_on),
        title: Text(
          'Lat ${formatarCoordenada(posicao!.latitude)}, '
          'Long ${formatarCoordenada(posicao!.longitude)}',
        ),
      );
    } else {
      linhaLocalizacao = const SizedBox.shrink();
    }

    return Card(
      child: Column(
        children: [
          if (dataHora != null)
            ListTile(
              dense: true,
              leading: const Icon(Icons.schedule),
              title: Text('${formatarData(dataHora!)} às ${formatarHora(dataHora!)}'),
            ),
          linhaLocalizacao,
        ],
      ),
    );
  }
}
