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
  List<Map> newTasks = [];
  List<Map> doneTasks = [];
  List<Map> archivedTasks = [];

  static AppCubit get(context) => BlocProvider.of(context);

  int currentIndex = 0;
  List<Widget> screens = [
    TasksScreen(),
    const DoneTasksScreen(),
    const ArchivedTasksScreen()
  ];
  IconData fabIcon = Icons.edit;
  IconData checkBox = Icons.check_box_outline_blank;
  bool isButtonSheetShown = false;
  List<String> titles = [
    'New Tasks',
    'Done Tasks',
    'Archived Tasks',
  ];

  void changeIndex(int index) {
    currentIndex = index;
    emit(AppChangeNavBarState());
  }

  IconData changeCheckBox({
    required IconData icon,
  }) {
    emit(AppChangeCheckBox());
    return checkBox = icon;
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
        getDataFromDatabase(database);
      },
    ).then((value) {
      database = value;
      emit(AppCreateDatabaseState());
    });
  }

  void getDataFromDatabase(database) async {
    newTasks = [];
    doneTasks = [];
    archivedTasks = [];
    emit(AppLoadingState());
    database.rawQuery('SELECT * FROM tasks').then((value) {
      value.forEach((element) {
        if (element['status'] == 'new') {
          newTasks.add(element);
        } else if (element['status'] == 'done') {
          doneTasks.add(element);
        } else {
          archivedTasks.add(element);
        }
      });
      emit(AppGetDatabaseState());
    });
  }

  insertToDatabase({
    required String title,
    required String time,
    required String date,
  }) async {
    await database.transaction((txn) async {
      txn
          .rawInsert(
              'INSERT INTO Tasks(title,date,time,status) VALUES("$title","$time","$date","new")')
          .then((value) {
        print('$value successfully insert');
        emit(AppInsertDatabaseState());
        getDataFromDatabase(database);
      }).catchError((error) {
        print('Error when inserting New');
      });
    });
    return;
  }

  void updateData({required String status, required int id}) async {
    database.rawUpdate(
        'Update tasks SET status = ? WHERE id = ?', [status, id]).then((value) {
      getDataFromDatabase(database);
      emit(AppUpdateDatabaseState());
    });
  }

  void deleteData({required int id}) async {
    database.rawDelete('DELETE FROM tasks WHERE id = ?', [id]).then((value) {
      getDataFromDatabase(database);
      emit(AppDeleteDatabaseState());
    });
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
