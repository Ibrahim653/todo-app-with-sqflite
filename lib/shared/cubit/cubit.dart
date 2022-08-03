import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sqflite/sqflite.dart';
import 'package:todo_app/shared/cubit/states.dart';

import '../../modules/archived_screen.dart';
import '../../modules/done_screen.dart';
import '../../modules/new_tasks_screen.dart';

class AppCubit extends Cubit<AppStates> {
  AppCubit() : super(AppInitialState());

  static AppCubit get(context) => BlocProvider.of(context);

  Database? database;

  List<Map> newTasks = [];
  List<Map> doneTasks = [];
  List<Map> archivedTasks = [];

  int currentIndex = 0;
  List<Widget> screens = const[
    NewTaskScreen(),
    DoneScreen(),
    ArchivedScreen(),
  ];
  List<String> titles = ["New Tasks", "Done Tasks", "Archived Tasks"];

  void changeIndex(int index) {
    currentIndex = index;
    emit(AppChangeBottomNavBarState());
  }

  void createDatabase() {
    openDatabase('todo.db', version: 1, onCreate: (database, version) async {
      print("database created");
      await database
          .execute(
              'CREATE TABLE tasks (id INTEGER PRIMARY KEY,title TEXT,date TEXT,time TEXT,status TEXT)')
          .then((value) {
        print("table created");
      }).catchError((error) {
        print("error when created table${error.toString()}");
      });
    }, onOpen: (database) {
      print("database opened");
      getDataFromDB(database);
    }).then((value) {
      database = value;
      emit(AppCreateDBState());
    });
  }

  insertToDatabase({
    required String title,
    required String time,
    required String date,
  }) async {
    await database!.transaction((txn) {
      return txn
          .rawInsert(
              'INSERT INTO tasks(title,date,time,status)VALUES("$title","$date","$time","new")')
          .then((value) {
        print('$value inserted successfully');
        emit(AppInsertToDBState());

        getDataFromDB(database);
      }).catchError((error) {
        print("error when inserting record${error.toString()}");
      });
    });
  }

  void updateData({required String status, required int id}) {
    database!.rawUpdate(
        'UPDATE tasks SET status = ? WHERE id = ?', [status, id]).then((value) {
      getDataFromDB(database);
      emit(AppUpdateDBState());
    });
  }

  void deleteData({required int id}) {
    database!.rawDelete('DELETE FROM tasks WHERE id = ?', [id]).then((value) {
      getDataFromDB(database);
      emit(AppDeleteDBState());
    });
  }

  void getDataFromDB(database) {
    newTasks = [];
    doneTasks = [];
    archivedTasks = [];
    emit(AppGetDBLoadingState());
    database!.rawQuery('SELECT * FROM tasks').then((value) {
      emit(AppGetDBState());
      value.forEach((element) {
        if (element['status'] == "new") {
          newTasks.add(element);
        } else if (element['status'] == "Done") {
          doneTasks.add(element);
        } else {
          archivedTasks.add(element);
        }
      });
    });
  }

  IconData fabIcon = Icons.edit;
  bool isBottomSheetShown = false;

  void changeBottomSheetState({
    required bool isShown,
    required IconData icon,
  }) {
    isBottomSheetShown = isShown;
    fabIcon = icon;
    emit(AppChangeBottomSheetState());
  }
}
