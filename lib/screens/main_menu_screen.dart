// ignore_for_file: use_key_in_widget_constructors

import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:study_buddy/Exceptions/custom_exception.dart';
import 'package:study_buddy/database/database.dart';
import 'package:study_buddy/screens/subjects_screen.dart';
import 'package:study_buddy/settings/settings.dart';
import 'package:study_buddy/settings/study_type.dart';
import 'package:study_buddy/widgets/main_menu_button.dart';

class MainMenuScreen extends StatefulWidget {
  @override
  State<MainMenuScreen> createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends State<MainMenuScreen> {
  StudyType _studyType = Settings.studyType;
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Study Buddy"), centerTitle: true),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  MainMenuButton(
                    onPressed: _onSubjectsPressed,
                    text: "Subjects",
                  ),
                  // MainMenuButton(
                  //   onPressed: _onLoadFromUrlPressed,
                  //   text: "Load from url",
                  // ),
                  MainMenuButton(
                    onPressed: _onLoadFromFilePressed,
                    text: "Load from file",
                  ),
                  MainMenuButton(
                    onPressed: _onStudyTypePressed,
                    text: "Study type: ${_studyType.name}",
                  ),
                ],
              ),
            ),
    );
  }

  void _onSubjectsPressed() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SubjectsScreen(),
      ),
    );
  }

  void _onLoadFromFilePressed() async {
    setState(() => isLoading = true);
    try {
      FilePickerResult? fileRes =
          await FilePicker.platform.pickFiles(type: FileType.any);
      if (fileRes == null) {
        throw Exception();
      }
      PlatformFile platformFile = fileRes.files.first;
      File file = File(platformFile.path as String);
      String string = await file.readAsString();
      String? err = await DBHelper.loadFromString(string);
      if (err != null) {
        _showMessage(err);
      } else {
        _showMessage("Finished loading");
      }
    } on CustomException catch (e) {
      _showMessage(e.toString());
    } catch (_) {
      _showMessage("Failed loading file");
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _showMessage(String? message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: message == null
            ? const Text("Loading finished successfully.")
            : Text(message),
      ),
    );
  }

  void _onStudyTypePressed() {
    setState(() {
      if (_studyType == StudyType.normal) {
        _studyType = Settings.studyType = StudyType.iterative;
      } else {
        _studyType = Settings.studyType = StudyType.normal;
      }
    });
  }
}
