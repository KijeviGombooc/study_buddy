// ignore_for_file: use_key_in_widget_constructors

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:study_buddy/database/database.dart';

import 'screens/main_menu_screen.dart';
import 'settings/settings.dart';

void main(List<String> args) {
  runApp(StudyBuddyApp());
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
}

class StudyBuddyApp extends StatefulWidget {
  @override
  State<StudyBuddyApp> createState() => _StudyBuddyAppState();
}

class _StudyBuddyAppState extends State<StudyBuddyApp> {
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    DBHelper.init()
        .then((_) => Settings.init())
        .then((_) => setState(() => isLoading = false));
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Study Buddy",
      theme: ThemeData(
        primarySwatch: Colors.green,
        scaffoldBackgroundColor: Colors.lightGreen.shade100,
      ),
      home: isLoading ? const Scaffold() : MainMenuScreen(),
    );
  }
}
