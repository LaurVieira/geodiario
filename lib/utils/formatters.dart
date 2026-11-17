String _doisDigitos(int n) => n.toString().padLeft(2, '0');

String formatarData(DateTime d) =>
    '${_doisDigitos(d.day)}/${_doisDigitos(d.month)}/${d.year}';

String formatarHora(DateTime d) =>
    '${_doisDigitos(d.hour)}:${_doisDigitos(d.minute)}:${_doisDigitos(d.second)}';

String formatarDataHora(DateTime d) =>
    '${formatarData(d)} às ${_doisDigitos(d.hour)}:${_doisDigitos(d.minute)}';

String formatarCoordenada(double valor) => valor.toStringAsFixed(6);
