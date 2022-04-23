// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
// import 'package:matabapp/context.dart';
import 'context.dart';
import 'package:hive/hive.dart';
import 'package:money_management/static.dart' as Static;

import './BE/tasks.dart';

class AddTask extends StatelessWidget {
  AddTask({
    Key? key,
    required this.type,
    required this.index,
    required this.text,
  }) : super(key: key);

  final String type;
  final int index;
  final String text;
  TextEditingController controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    if (type == 'edit') {
      controller.text = text;
    }
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Static.PrimaryColor,
        elevation: 0,
        title: Text(
          type == 'add' ? 'Add Todo' : 'Edit Todo',
          style: const TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
          color: Colors.white,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          children: [
            const SizedBox(
              height: 10,
            ),
            TextField(
              controller: controller,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(
                    10,
                  ),
                  borderSide: const BorderSide(
                    width: 2,
                    color: Colors.grey,
                  ),
                ),
                labelText: 'Add Task',
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            ElevatedButton(
              onPressed: () {
                onPress(
                  controller.text,
                );
                Navigator.of(context).pop();
              },
              child: Text(
                type == 'add' ? 'Add Todo' : 'Edit Todo',
                style: const TextStyle(color: Colors.white),
              ),
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Static.PrimaryColor),
                fixedSize: MaterialStateProperty.all(
                  const Size(100, 40),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void onPress(String title) {
    if (type == 'add') {
      add(title);
    } else {
      edit(title);
    }
  }

  add(String title) async {
    if (title.isEmpty) {
      return "This field cannot be empty";
    } else {
      var box = await Hive.openBox('todo');
      Task task = Task(title, false);
      box.add(task);

      controller.clear();
      // var currentDate = DateTime.now();
      // DatePicker.showTimePicker(
      //   ,
      //   showSecondsColumn: false,
      //   showTitleActions: true,
      //   onChanged: (date) {},
      //   onConfirm: (date) async {
      //     if (title.isNotEmpty) {
      //       var box = await Hive.openBox('todo');
      //       Task task = Task(title, false);
      //       box.add(task);

      //       controller.clear();
      //     }
      //   },
      //   currentTime: DateTime.now(),
      // );
    }
  }

  edit(String title) async {
    var box = await Hive.openBox('todo');
    Task task = Task(title, false);
    box.putAt(index, task);
  }
}
