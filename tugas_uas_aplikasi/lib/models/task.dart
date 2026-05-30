import 'package:flutter/material.dart';

class Task {
  final String id;
  String title;
  String course;
  DateTime deadline;
  String? description;
  String priority;
  bool isDone;

  Task({
    required this.id,
    required this.title,
    required this.course,
    required this.deadline,
    this.description,
    required this.priority,
    this.isDone = false,
  });
}

class Jadwal {
  final String id;
  final String course;
  final String day;
  final String startTime;
  final String endTime;
  final String room;

  Jadwal({
    required this.id,
    required this.course,
    required this.day,
    required this.startTime,
    required this.endTime,
    required this.room,
  });
}

final ValueNotifier<List<Task>> globalTasks = ValueNotifier([]);
final ValueNotifier<List<Jadwal>> globalSchedules = ValueNotifier([]);
