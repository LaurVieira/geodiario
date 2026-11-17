import 'dart:async';

import 'package:geolocator/geolocator.dart';

class LocalizacaoException implements Exception {
  final String mensagem;
  const LocalizacaoException(this.mensagem);

  @override
  String toString() => mensagem;
}

class LocationService {
  Future<Position> obterPosicaoAtual() async {
    final servicoAtivo = await Geolocator.isLocationServiceEnabled();
    if (!servicoAtivo) {
      throw const LocalizacaoException(
        'O GPS está desligado. Ative a localização do aparelho.',
      );
    }

    var permissao = await Geolocator.checkPermission();
    if (permissao == LocationPermission.denied) {
      permissao = await Geolocator.requestPermission();
      if (permissao == LocationPermission.denied) {
        throw const LocalizacaoException('Permissão de localização negada.');
      }
    }

    if (permissao == LocationPermission.deniedForever) {
      throw const LocalizacaoException(
        'Permissão de localização negada permanentemente. '
        'Libere o acesso nas configurações do aparelho.',
      );
    }

    try {
      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 20),
        ),
      );
    } on TimeoutException {
      final ultima = await Geolocator.getLastKnownPosition();
      if (ultima != null) return ultima;
      throw const LocalizacaoException(
        'Não foi possível obter a localização. Tente novamente em local aberto.',
      );
    }
  }
}
