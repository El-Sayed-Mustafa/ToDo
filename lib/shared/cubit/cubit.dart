import 'package:bloc/bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sqflite/sqflite.dart';
import 'package:to_do_app/shared/cubit/states.dart';

import '../../modules/archived_tasks/archive_tasks_screen.dart';
import '../../modules/done_tasks/done_tasks_screen.dart';
import '../../modules/tasks/tasks_screen.dart';

class AppCubit extends Cubit<AppStates> {
  AppCubit() : super(AppInitialState());
  List<Map> tasks = [];

  static AppCubit get(context) => BlocProvider.of(context);

  int currentIndex = 0;
  List<Widget> screens = [
    TasksScreen(),
    const DoneTasksScreen(),
    const ArchivedTasksScreen()
  ];
  IconData fabIcon = Icons.edit;
  bool isButtonSheetShown = false;
  List<String> titles = [
    'New Tasks',
    'Do ne Tasks',
    'Archived Tasks',
  ];

  void changeIndex(int index) {
    currentIndex = index;
    emit(AppChangeNavBarState());
  }

  late Database database;

  void createDatabase() {
    openDatabase(
      'todo.db',
      version: 1,
      onCreate: (database, version) async {
        database
            .execute("CREATE TABLE Tasks ("
                "id INTEGER PRIMARY KEY,"
                "title TEXT,"
                "date TEXT,"
                "time TEXT,"
                "status TEXT"
                ")")
            .then((value) {})
            .catchError((error) {
          print('error on created');
        });
      },
      onOpen: (database) {
        print('db is opened');
        getDataFromDatabase(database).then((value) {
          tasks = value;
          print(tasks);
          emit(AppGetDatabaseState());
        });
      },
    ).then((value) {
      database = value;
      emit(AppCreateDatabaseState());
    });
  }

  Future<List<Map>> getDataFromDatabase(database) async {
    return await database.rawQuery('SELECT * FROM tasks');
  }

  Future insertToDatabase({
    required String title,
    required String time,
    required String date,
  }) async {
    return await database.transaction((txn) async {
      txn
          .rawInsert(
              'INSERT INTO Tasks(title,date,time,status) VALUES("$title","$time","$date","new")')
          .then((value) {
        print('$value successfully insert');
        emit(AppInsertDatabaseState());
      }).catchError((error) {
        print('Error when inserting New');
      });
    });
    return;
  }

  void changeBottomSheet({
    required bool isShow,
    required IconData icon,
  }) {
    isButtonSheetShown = isShow;
    fabIcon = icon;
    emit(AppChangeBottomSheetState());
  }
}
