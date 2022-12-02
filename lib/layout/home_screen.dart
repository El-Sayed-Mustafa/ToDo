import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';
import 'package:to_do_app/modules/archived_tasks/archive_tasks_screen.dart';
import 'package:to_do_app/modules/done_tasks/done_tasks_screen.dart';
import 'package:to_do_app/modules/tasks/tasks_screen.dart';
import 'package:flutter/widgets.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../shared/component/components.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int currentIndex = 0;
  List<Widget> screens = [
    const TasksScreen(),
    const DoneTasksScreen(),
    const ArchivedTasksScreen()
  ];
  List<Map> tasks = [];

  IconData fabIcon = Icons.edit;
  bool isButtonSheetShown = false;
  var scaffoldkey = GlobalKey<ScaffoldState>();
  var formKey = GlobalKey<FormState>();

  List<String> titles = ['New Tasks', 'Do ne Tasks', 'Archived Tasks'];

  late Database database;
  var titleController = TextEditingController();
  var timeController = TextEditingController();
  var dateController = TextEditingController();

  @override
  void initState() {
    createDatabase();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldkey,
      appBar: AppBar(
        title: Text(titles[currentIndex]),
      ),
      body: screens[currentIndex],
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (isButtonSheetShown) {
            if (formKey.currentState?.validate() == true) {
              insertToDatabase(
                      title: titleController.text,
                      date: dateController.text,
                      time: timeController.text)
                  .then((value) {
                isButtonSheetShown = false;
                Navigator.pop(context);
                setState(() {
                  fabIcon = Icons.edit;
                });
              });
            }
          } else {
            isButtonSheetShown = true;
            scaffoldkey.currentState
                ?.showBottomSheet(
                  (context) => Container(
                    decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(30),
                          topRight: Radius.circular(30),
                        )),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Form(
                        key: formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            defaultFormField(
                              controller: titleController,
                              type: TextInputType.text,
                              onTap: () {},
                              validate: (String value) {
                                if (value.isEmpty) {
                                  return 'title must not be empty';
                                }
                                return null;
                              },
                              label: 'Task Title',
                              prefix: Icons.title,
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            defaultFormField(
                              controller: timeController,
                              type: TextInputType.datetime,
                              onTap: () {
                                showTimePicker(
                                        context: context,
                                        initialTime: TimeOfDay.now())
                                    .then((value) {
                                  timeController.text =
                                      value!.format(context).toString();
                                });
                              },
                              validate: (String value) {
                                if (value.isEmpty) {
                                  return 'title must not be empty';
                                }
                                return null;
                              },
                              label: 'Task Time',
                              prefix: Icons.watch_later_outlined,
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            defaultFormField(
                              onTap: () {
                                showDatePicker(
                                  context: context,
                                  initialDate: DateTime.now(),
                                  firstDate: DateTime.now(),
                                  lastDate: DateTime.parse('2050-12-02'),
                                ).then((value) {
                                  dateController.text = DateFormat.yMMMd()
                                      .format(value!)
                                      .toString();
                                });
                              },
                              controller: dateController,
                              type: TextInputType.text,
                              validate: (String value) {
                                if (value.isEmpty) {
                                  return 'date must not be empty';
                                }
                                return null;
                              },
                              label: 'Task Date',
                              prefix: Icons.calendar_today,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                )
                .closed
                .then((value) {
              isButtonSheetShown = false;
              setState(() {
                fabIcon = Icons.edit;
              });
            });
            setState(() {
              fabIcon = Icons.add;
            });
          }
        },
        child: Icon(fabIcon),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) {
          setState(() {
            currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.task),
            label: 'Tasks',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.check_circle_outline),
            label: 'Done',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.archive_outlined),
            label: 'Archived',
          ),
        ],
      ),
    );
  }

  void createDatabase() async {
    database = await openDatabase(
      'todo.db',
      version: 1,
      onCreate: (db, version) async {
        db
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
      onOpen: (db) {
        print('db is opened');
        getDataFromDatabase(db).then((value) {
          tasks = value;
        });
      },
    );
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
      }).catchError((error) {
        print('Error when inserting New');
      });
    });
    return;
  }

  Future<List<Map>> getDataFromDatabase(database) async {
    return await database.rawQuery('SELECT * FROM tasks');
  }
}
