import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:sqflite/sqflite.dart';
part 'system_parameter_state.dart';

class SystemParameterCubit extends Cubit<SystemParameterState> {
  SystemParameterCubit() : super(SystemParameterInitial());

  Future<void> loadFromPreferences() async {
    // Map<String, dynamic> data = await preferences.getPref();
    // if (data[SystemParameterPreferences.configStatus]) {
    //   var databasesPath = await getDatabasesPath();
    //   String path = '${databasesPath}master.db';
    //   emit(SystemParameterConfigured(databasePath: path));
    // } else {
    await setPreferences();
    // }
  }

  Future setPreferences() async {
    var databasesPath = await getDatabasesPath();
    String path = '${databasesPath}master.db';
    emit(SystemParameterConfigured(databasePath: path));
    await initializeDatabase(path);
    // await preferences.setSystemParameter(
    //     params: {SystemParameterPreferences.configStatus: true});
  }

  Future initializeDatabase(path) async {
    var path = (state as SystemParameterConfigured).databasePath;
    await openDatabase(path, version: 1,
        onCreate: (Database db, int version) async {
      await db.execute('''
      CREATE TABLE GUESS_TABLE (
        id_guess TEXT PRIMARY KEY, 
        check_in VARCHAR(255) NOT NULL, 
        check_out VARCHAR(255) NOT NULL, 
        guess_name VARCHAR(255) NOT NULL, 
        company VARCHAR(255) NOT NULL, 
        plate_number VARCHAR(255) NOT NULL, 
        employe_name VARCHAR(255) NOT NULL, 
        permission VARCHAR(255) NOT NULL, 
        need_for VARCHAR(255) NOT NULL, 
        notes VARCHAR(255) NOT NULL, 
        path_card VARCHAR(255) NOT NULL,
        created_at VARCHAR(255)
      )
    ''');
    });
  }
}
