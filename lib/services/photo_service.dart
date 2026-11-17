import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class PhotoService {
  final ImagePicker _picker = ImagePicker();

  Future<XFile?> capturarFoto() {
    return _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
      maxWidth: 1920,
    );
  }

  Future<String> salvarFoto(XFile foto) async {
    final documentos = await getApplicationDocumentsDirectory();
    final pasta = Directory(p.join(documentos.path, 'fotos'));
    if (!await pasta.exists()) {
      await pasta.create(recursive: true);
    }

    final extensao = p.extension(foto.path).isEmpty ? '.jpg' : p.extension(foto.path);
    final nomeArquivo = 'geo_${DateTime.now().millisecondsSinceEpoch}$extensao';
    final destino = p.join(pasta.path, nomeArquivo);

    await foto.saveTo(destino);
    return destino;
  }

  Future<void> excluirFoto(String caminho) async {
    final arquivo = File(caminho);
    if (await arquivo.exists()) {
      await arquivo.delete();
    }
  }
}
