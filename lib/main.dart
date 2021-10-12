import 'package:flutter/material.dart';
import 'package:practica3_tareas/src/view/finished_tasks.dart';
import 'package:practica3_tareas/src/view/home_tasks.dart';
import 'package:practica3_tareas/src/view/tasks_view.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: {
        '/agregar'    : (BuildContext context) => TasksView(),
        '/terminadas' : (BuildContext context) => FinishedTasks()
      },
      debugShowCheckedModeBanner: false,
      home: HomeTasks(),
    );
  }
}