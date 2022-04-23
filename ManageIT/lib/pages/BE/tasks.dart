import 'package:hive/hive.dart';

part 'tasks.g.dart';

@HiveType(typeId: 1)
class Task {
  @HiveField(0)
  String tasktitle;

  @HiveField(1)
  bool isdo;

  Task(this.tasktitle, this.isdo);
}
