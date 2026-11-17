import 'dart:io';

import 'package:flutter/material.dart';

class FotoRegistro extends StatelessWidget {
  final String caminho;
  final BoxFit fit;
  final int? cacheWidth;

  const FotoRegistro({
    super.key,
    required this.caminho,
    this.fit = BoxFit.cover,
    this.cacheWidth,
  });

  @override
  Widget build(BuildContext context) {
    return Image.file(
      File(caminho),
      fit: fit,
      cacheWidth: cacheWidth,
      errorBuilder: (context, error, stackTrace) => Container(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        alignment: Alignment.center,
        child: const Icon(Icons.broken_image_outlined, size: 48),
      ),
    );
  }
}
