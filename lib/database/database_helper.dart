import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/registro.dart';

class DatabaseHelper {
  DatabaseHelper._();

  static final DatabaseHelper instance = DatabaseHelper._();

  static const String _nomeBanco = 'geodiario.db';
  static const int _versao = 1;
  static const String tabela = 'registros';

  Database? _db;

  Future<Database> get database async {
    return _db ??= await _abrirBanco();
  }

  Future<Database> _abrirBanco() async {
    final caminho = join(await getDatabasesPath(), _nomeBanco);
    return openDatabase(
      caminho,
      version: _versao,
      onCreate: _criarTabelas,
    );
  }

  Future<void> _criarTabelas(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $tabela (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        titulo TEXT NOT NULL,
        descricao TEXT,
        caminho_foto TEXT NOT NULL,
        data_hora TEXT NOT NULL,
        latitude REAL NOT NULL,
        longitude REAL NOT NULL
      )
    ''');
  }

  Future<int> inserir(Registro registro) async {
    final db = await database;
    return db.insert(tabela, registro.toMap());
  }

  Future<List<Registro>> listarTodos() async {
    final db = await database;
    final linhas = await db.query(tabela, orderBy: 'data_hora DESC');
    return linhas.map(Registro.fromMap).toList();
  }

  Future<Registro?> buscarPorId(int id) async {
    final db = await database;
    final linhas = await db.query(
      tabela,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (linhas.isEmpty) return null;
    return Registro.fromMap(linhas.first);
  }

  Future<int> excluir(int id) async {
    final db = await database;
    return db.delete(tabela, where: 'id = ?', whereArgs: [id]);
  }
}
