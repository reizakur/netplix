import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:intl/intl.dart';
import 'package:meta/meta.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:visito/models/datatamu.dart';
import 'package:visito/system_parameter/system_parameter_cubit.dart';

part 'tamu_controller_state.dart';

class TamuControllerCubit extends Cubit<TamuControllerState> {
  TamuControllerCubit({required this.systemParameterCubit})
      : super(TamuControllerInitial());
  SystemParameterCubit systemParameterCubit;
  late Database db;

  Future<int> addRecordsOcr(DataKendaraan datakendaraan) async {
    var state = systemParameterCubit.state;

    db = await openDatabase(
        (systemParameterCubit.state as SystemParameterConfigured).databasePath,
        version: 1);

    // await db.insert('GUESS_TABLE', datakendaraan.toMap()); // add RETURNING id
    int id_gues = await db.insert('GUESS_TABLE', datakendaraan.toMap());
    return id_gues;
  }

  Future<String> fetchPrimaryKey(String datein) async {
    db = await openDatabase(
        (systemParameterCubit.state as SystemParameterConfigured).databasePath,
        version: 1);
    List<Map> maps = await db.query('GUESS_TABLE',
        columns: ['id_guess'],
        where:
            "DATE(check_in) = ?", // Use the DATE function to extract the date part
        whereArgs: [datein], // Provide the formatted date as an argument
        orderBy: 'id_guess DESC',
        limit: 1);

    if (maps.isNotEmpty) {
      String largestId = maps.first['id_guess'];

      return largestId; // Convert the largest ID to a string and return it
    } else {
      return ''; // Return an empty string if no records are found
    }
  }

  Future<Map<String, dynamic>?> fetchguess(String code) async {
    db = await openDatabase(
      (systemParameterCubit.state as SystemParameterConfigured).databasePath,
      version: 1,
    );

    List<Map<String, dynamic>> maps = await db.query(
      'GUESS_TABLE',
      where: "id_guess = ?",
      whereArgs: [code],
      orderBy: 'id_guess DESC',
      limit: 1,
    );

    if (maps.isNotEmpty) {
      return maps.first;
    } else {
      return null;
    }
  }

  Future<Map<String, dynamic>?> reprint(String code) async {
    db = await openDatabase(
      (systemParameterCubit.state as SystemParameterConfigured).databasePath,
      version: 1,
    );

    List<Map<String, dynamic>> maps = await db.query(
      'GUESS_TABLE',
      where: "id_guess = ?",
      whereArgs: [code],
      orderBy: 'id_guess DESC',
      limit: 1,
    );

    if (maps.isNotEmpty) {
      return maps.first;
    } else {
      return null;
    }
  }

  Future<int> checkOut(String idGuess) async {
    final db = await openDatabase(
      (systemParameterCubit.state as SystemParameterConfigured).databasePath,
      version: 1,
    );

    final newValue = {
      'check_out': DateTime.now().toIso8601String(), // Format tanggal dan waktu
    };

    // Update the check_out column for the given id_guess
    return await db.update(
      'GUESS_TABLE',
      newValue,
      where: 'id_guess = ?',
      whereArgs: [idGuess],
    );
  }

//tidakjuga
  Future<List<DataKendaraan>> fetchGuessall() async {
    db = await openDatabase(
        (systemParameterCubit.state as SystemParameterConfigured).databasePath,
        version: 1);

    List<Map> maps = await db.query(
      'GUESS_TABLE',
      orderBy: 'check_in DESC',
    );

    List<DataKendaraan> result = [];

    int length = maps.length;

    for (int i = 0; i < length; i++) {
      print(maps[i]);
      result.add(DataKendaraan.fromMap(map: maps[i]));
    }

    return result;
  }

  Future<List<DataKendaraan>> fetchGuessDisc() async {
    db = await openDatabase(
        (systemParameterCubit.state as SystemParameterConfigured).databasePath,
        version: 1);

    List<Map> maps = await db
        .rawQuery('SELECT DISTINCT employe_name FROM GUESS_TABLE limit 25');

    List<DataKendaraan> result = [];

    int length = maps.length;

    for (int i = 0; i < length; i++) {
      // print(maps[i]);
      result.add(DataKendaraan.fromMap(map: maps[i]));
    }

    return result;
  }

  Future<List<DataKendaraan>> fetchbeforetodays() async {
    db = await openDatabase(
        (systemParameterCubit.state as SystemParameterConfigured).databasePath,
        version: 1);

    // Mendapatkan tanggal 2 hari yang lalu
    DateTime twoDaysAgo = DateTime.now().subtract(Duration(days: 1));

    String formattedDate = DateFormat('yyyy-MM-dd').format(twoDaysAgo);

    // Query untuk mengambil data dengan filter berdasarkan 'created_at'
    List<Map> maps = await db.query(
      'GUESS_TABLE',
      where: 'check_in < ?',
      whereArgs: [formattedDate],
    );

    List<DataKendaraan> result = [];

    int length = maps.length;

    for (int i = 0; i < length; i++) {
      result.add(DataKendaraan.fromMap(map: maps[i]));
    }

    return result;
  }

  Future<void> deleteImgData(
      String imageFiles, List<Map<String, dynamic>> map) async {
    // Open the database

    Database db = await openDatabase(
        (systemParameterCubit.state as SystemParameterConfigured).databasePath,
        version: 1);

    // DateTime cutoffDate = DateTime.now().subtract(Duration(days: 2));

    String directoryPath = dirname(imageFiles);

    RegExp regExp = RegExp(r"File: '(.*?)'");
    Iterable<RegExpMatch> matches = regExp.allMatches(imageFiles);

    List<String> filePaths = [];
    for (var match in matches) {
      String path = match.group(1) ?? '';
      if (path.isNotEmpty && path != 'null') {
        filePaths.add(path);
      }
    }

    Set<String> directoryPaths = {};
    for (String path in filePaths) {
      String directoryPath = dirname(path);
      directoryPaths.add(directoryPath); // Use a Set to avoid duplicates
    }

    DateTime cutoffDate = DateTime.now().subtract(Duration(days: 1));

    // Step 3: Delete files older than 1 day
    for (String directoryPath in directoryPaths) {
      final directory = Directory(directoryPath);

      if (!await directory.exists()) {
        continue;
      }

      List<FileSystemEntity> files = directory.listSync();
      for (var file in files) {
        if (file is File) {
          try {
            DateTime lastModifiedDate = await file.lastModified();
            if (lastModifiedDate.isBefore(cutoffDate)) {
              await file.delete();
            } else {}
          } catch (e) {}
        }
      }
    }

    for (Map<String, dynamic> entry in map) {
      String idGuess = entry['id_guess'];

      try {
        await db.delete(
          'GUESS_TABLE',
          where: 'id_guess = ?',
          whereArgs: [idGuess],
        );
      } catch (e) {}
    }
  }

  // () {}

  Future<void> deleteOnline() async {
    db = await openDatabase(
        (systemParameterCubit.state as SystemParameterConfigured).databasePath,
        version: 1);
    await db.delete(
      'GUESS_TABLE',
      where: 'permission = ?',
      whereArgs: ['ONLINE'],
    );
  }
}
