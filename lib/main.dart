import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:taskmanager_app_getitdone/routes/app_router.dart';
import 'package:taskmanager_app_getitdone/routes/pages.dart';
import 'package:taskmanager_app_getitdone/tasks/data/local/data_sources/task_data_provider.dart';
import 'package:taskmanager_app_getitdone/tasks/data/repository/task_repository.dart';
import 'package:taskmanager_app_getitdone/tasks/presentation/bloc/tasks_bloc.dart';
import 'package:taskmanager_app_getitdone/utils/color_palette.dart';

import 'bloc_state_observer.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Bloc.observer = BlocStateOberver();
  SharedPreferences preferences = await SharedPreferences.getInstance();
  runApp(MyApp(
    preferences: preferences,
  ));
}

class MyApp extends StatelessWidget {
  final SharedPreferences preferences;

  const MyApp({super.key, required this.preferences});

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider(
        create: (context) =>
            TaskRepository(taskDataProvider: TaskDataProvider(preferences)),
        child: BlocProvider(
            create: (context) => TasksBloc(context.read<TaskRepository>()),
            child: MaterialApp(
              title: 'Task Manager',
              debugShowCheckedModeBanner: false,
              initialRoute: Pages.initial,
              onGenerateRoute: onGenerateRoute,
              theme: ThemeData(
                fontFamily: 'Sora',
                visualDensity: VisualDensity.adaptivePlatformDensity,
                canvasColor: Colors.transparent,
                colorScheme: ColorScheme.fromSeed(seedColor: kPrimaryColor),
                useMaterial3: true,
              ),
            )));
  }
}