import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../model/note.dart';

class NotesDatabase {
  static final NotesDatabase instance = NotesDatabase._init();

  static Database? _database;
  NotesDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB("notes.db");
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future<void> _createDB(Database db, int version) async {
    final idType = "INTEGER PRIMARY KEY AUTO INCREMENT";
    final boolType = "BOOLEAN NOT NULL";
    final integerType = "INTEGER NOT NULL";
    final textType = "TEXT NOT NULL";
    await db.execute('''
      CREATE TABLE $tablesNotes
       (
         ${NoteFields.id} $idType,
         ${NoteFields.isImportant} $boolType,
         ${NoteFields.description} $textType ,
         ${NoteFields.number} $integerType,
         ${NoteFields.createdTime} $textType,
         ${NoteFields.title} $textType
       )
      ''');
  }

  Future<Note> create(Note note) async {
    final db = await instance.database;
    final id = await db.insert(tablesNotes, note.toJson());

    return note.copy(id: id);
  }

  Future<Note> readNote(int id) async {
    final db = await instance.database;
    final maps = await db.query(tablesNotes,
        columns: NoteFields.values,
        where: '${NoteFields.id} = ?',
        whereArgs: [id]);

    if (maps.isNotEmpty) {
      return Note.fromJson(maps.first);
    } else {
      throw Exception("ID $id not found");
    }
  }

  Future<List<Note>> readAllNotes() async {
    final db = await instance.database;
    final orderBy = '${NoteFields.createdTime} ASC';
    final response = await db.query(tablesNotes, orderBy: orderBy);

    return response.map((json) => Note.fromJson(json)).toList();
  }

  Future<int> update(Note note) async {
    final db = await instance.database;
    return await db.update(tablesNotes, note.toJson(),
        where: '${NoteFields.id} = ?', whereArgs: [note.id]);
  }

  Future<int> delete(int id) async {
    final db = await instance.database;
    return await db
        .delete(tablesNotes, where: '${NoteFields.id} = ?', whereArgs: [id]);
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
