import 'package:flutter/material.dart';

import '../models/registro.dart';
import '../utils/formatters.dart';
import 'foto_registro.dart';

class RegistroCard extends StatelessWidget {
  final Registro registro;
  final VoidCallback onTap;

  const RegistroCard({super.key, required this.registro, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final texto = Theme.of(context).textTheme;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Hero(
                tag: 'foto_${registro.id}',
                child: FotoRegistro(caminho: registro.caminhoFoto, cacheWidth: 400),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    registro.titulo,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: texto.titleSmall,
                  ),
                  const SizedBox(height: 2),
                  Text(formatarDataHora(registro.dataHora), style: texto.bodySmall),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
