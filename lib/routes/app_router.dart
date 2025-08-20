import 'package:flutter/material.dart';
import 'package:taskmanager_app_getitdone/routes/pages.dart';
import 'package:taskmanager_app_getitdone/utils/shared_preferences_helper.dart';
import '../page_not_found.dart';
import '../splash_screen.dart';
import '../welcome_screen.dart';
import '../tasks/data/local/model/task_model.dart';
import '../tasks/presentation/pages/new_task_screen.dart';
import '../tasks/presentation/pages/tasks_screen.dart';
import '../tasks/presentation/pages/update_task_screen.dart';

Route onGenerateRoute(RouteSettings routeSettings) {
  switch (routeSettings.name) {
    case Pages.initial:
      return MaterialPageRoute(
        builder: (context) => const SplashScreen(),
      );
    case Pages.welcome:
      return MaterialPageRoute(
        builder: (context) => const WelcomeScreen(),
      );
    case Pages.home:
      return MaterialPageRoute(
        builder: (context) => const TasksScreen(),
      );
    case Pages.createNewTask:
      return MaterialPageRoute(
        builder: (context) => const NewTaskScreen(),
      );
    case Pages.updateTask:
      final args = routeSettings.arguments as TaskModel;
      return MaterialPageRoute(
        builder: (context) => UpdateTaskScreen(taskModel: args),
      );
    default:
      return MaterialPageRoute(
        builder: (context) => const PageNotFound(),
      );
  }
}