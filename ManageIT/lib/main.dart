// ignore_for_file: prefer_const_constructors, use_key_in_widget_constructors

import 'package:flutter/material.dart';
import 'package:money_management/pages/splash.dart';
import 'package:money_management/theme.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'pages/BE/tasks.dart';

void main() async {
  await Hive.initFlutter();
  await Hive.openBox('money');
  Hive.registerAdapter(TaskAdapter());
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of our application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Money Manager',
      theme: myTheme,
      home: Splash(),
    );
  }
}
