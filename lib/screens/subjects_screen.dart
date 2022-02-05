// ignore_for_file: use_key_in_widget_constructors

import 'package:flutter/material.dart';
import 'package:study_buddy/database/database.dart';
import 'package:study_buddy/database/subject_data.dart';
import 'package:study_buddy/screens/topics_screen.dart';
import 'package:study_buddy/widgets/category_button.dart';

class SubjectsScreen extends StatefulWidget {
  @override
  State<SubjectsScreen> createState() => _SubjectsScreenState();
}

class _SubjectsScreenState extends State<SubjectsScreen> {
  List<SubjectData>? _subjects;

  @override
  void initState() {
    super.initState();
    DBHelper.getSubjects().then((subjects) {
      if (subjects.length == 1) {
        Navigator.pop(context);
        Navigator.push(context, MaterialPageRoute(builder: (ctx) {
          return TopicsScreen(subject: subjects[0]);
        }));
        return;
      }
      setState(() => _subjects = subjects);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Subjects"), centerTitle: true),
      body: _subjects == null
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(8.0),
              child: ListView.builder(
                itemCount: _subjects!.length,
                itemBuilder: (ctx, i) {
                  return Dismissible(
                    key: UniqueKey(),
                    onDismissed: (_) => _onDismissed(i),
                    confirmDismiss: (_) => _confirmDismiss(i),
                    child: CategoryButton(
                      onPressed: () => _onPressed(i),
                      text: _subjects![i].name,
                    ),
                  );
                },
              ),
            ),
    );
  }

  _onDismissed(int i) {
    DBHelper.deleteSubject(_subjects![i].id);
    setState(() {
      _subjects!.removeAt(i);
      //TODO: might not be necessery (was needed to visibly refresh data)
      // _subjects = List<SubjectData>.generate(
      //   _subjects!.length,
      //   (index) {
      //     return SubjectData(
      //         id: _subjects![index].id, name: _subjects![index].name);
      //   },
      // );
    });
  }

  _onPressed(int i) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (ctx) {
          return TopicsScreen(
            subject: _subjects![i],
          );
        },
      ),
    );
  }

  Future<bool?> _confirmDismiss(int i) {
    return showDialog(
        context: context,
        builder: (ctx) {
          return AlertDialog(
            title: Text(
                "Are you sure you want to delete subject ${_subjects![i].name}?"),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context, true);
                },
                child: const Text("yes"),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context, false);
                },
                child: const Text("No"),
              ),
            ],
          );
        });
  }
}
