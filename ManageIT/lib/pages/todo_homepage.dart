import 'dart:developer';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:money_management/pages/BE/tasks.dart';
import 'package:money_management/pages/add_task.dart';
// import 'package:matabapp/BE/ts.dart';
// import 'package:matabapp/context.dart';
// import 'package:matabapp/screens/todo_screasken.dart';
import 'package:money_management/static.dart' as Static;

class TodoHome extends StatefulWidget {
  const TodoHome({Key? key}) : super(key: key);

  @override
  _TodoHomeState createState() => _TodoHomeState();
}

class _TodoHomeState extends State<TodoHome> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Static.PrimaryColor,
          centerTitle: true,
          elevation: 0,
          title: const Text(
            'Tasks',
            style: TextStyle(
              fontSize: 30,
            ),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AddTask(
                  type: 'add',
                  index: -1,
                  text: '',
                ),
              ),
            );
          },
          child: const Icon(
            Icons.add,
            color: Colors.white,
            size: 32.0,
          ),
          backgroundColor: Static.PrimaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              16.0,
            ),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                height: 20,
              ),
              const Text(
                "Today",
                style: TextStyle(color: Static.PrimaryColor),
              ),
              const SizedBox(
                height: 10,
              ),
              FutureBuilder(
                future: Hive.openBox('todo'),
                builder: (context, snapshot) {
                  if (snapshot.hasData &&
                      snapshot.connectionState == ConnectionState.done) {
                    return todoList();
                  } else {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                },
              )
            ],
          ),
        ));
  }

  Widget todoList() {
    Box todoBox = Hive.box('todo');
    return ValueListenableBuilder(
        valueListenable: todoBox.listenable(),
        builder: (context, Box box, child) {
          if (box.values.isEmpty) {
            return const Center(
                child: Text(
              'Look\'s like you are free today!',
              style: TextStyle(
                color: Static.PrimaryColor,
              ),
            ));
          } else {
            return SizedBox(
              height: 400,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: todoBox.length,
                itemBuilder: (context, index) {
                  final Task task = box.getAt(index);
                  return GestureDetector(
                    onTap: () {
                      if (task.isdo == false) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AddTask(
                              type: 'edit',
                              index: index,
                              text: task.tasktitle,
                            ),
                          ),
                        );
                      }
                    },
                    child: Card(
                      shape: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: const BorderSide(
                          width: 0,
                        ),
                      ),
                      color: Static.PrimaryColor,
                      child: ListTile(
                        leading: IconButton(
                          icon: Icon(
                            task.isdo == false
                                ? Icons.brightness_1_outlined
                                : Icons.check_circle,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            if (task.isdo == true) {
                              checkButo(false, task.tasktitle, index);
                            } else {
                              checkButo(true, task.tasktitle, index);
                            }
                          },
                        ),
                        title: Text(
                          task.tasktitle,
                          style: const TextStyle(
                            color: Colors.white,
                          ),
                        ),
                        trailing: IconButton(
                          icon: const Icon(
                            Icons.delete,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            remove(index);
                          },
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
          }
        });
  }

  checkButo(bool pros, String title, int index) {
    if (pros == false) {
      var box = Hive.box('todo');
      Task task = Task(title, false);
      box.putAt(index, task);
    } else {
      var box = Hive.box('todo');
      Task task = Task(title, true);
      box.putAt(index, task);
    }
  }

  void remove(int index) {
    var box = Hive.box('todo');
    box.deleteAt(index);
  }
}
