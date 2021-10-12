import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:practica3_tareas/src/model/tasks_model.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseTasks {
  static final _nombreBD = "TASKSBD";
  static final _versionBD = 1;
  static final _nombreTBL = "tblTasks";

  static Database? _database;

  Future<Database?> get database async{
    if( _database != null ) return _database;
    _database = await _initDatabase();
    return _database;
  }

  Future<Database> _initDatabase() async{
    Directory carpeta = await getApplicationDocumentsDirectory();
    String rutaBD = join(carpeta.path,_nombreBD);
    return openDatabase(
      rutaBD,
      version: _versionBD,
      onCreate: _crearTabla
    );
  }

  _crearTabla(Database db, int version) async{
    await db.execute("CREATE TABLE $_nombreTBL (idTarea INTEGER PRIMARY KEY, nomTarea VARCHAR(100), dscTarea VARCHAR(200), fechaEntrega DATE, entregada Boolean)");
  }

  Future<int> insert(Map<String,dynamic> row) async{
    var conexion = await database;
    return conexion!.insert(_nombreTBL, row);
  }

  Future<int> update(Map<String,dynamic> row) async{
    var conexion = await database;
     return conexion!.update(_nombreTBL, row, where: 'idTarea= ?', whereArgs: [row['idTarea']]);
  }

  Future<int> delete(int idTarea) async{
    var conextion = await database;
    return await conextion!.delete(_nombreTBL,where: 'idTarea = ?', whereArgs: [idTarea]);
  }

  Future<List<TasksModel>> getAll() async{
    var conexion = await database;
    var result = await conexion!.query(_nombreTBL);
    return result.map((notaMap) => TasksModel.fromMap(notaMap)).toList();
  }

  Future<TasksModel> getOne(int idTarea) async{
    var conexion = await database;
    var result = await conexion!.query(_nombreTBL,where: 'idTarea=?',whereArgs: [idTarea]);
    return TasksModel.fromMap(result.first);
  }
}