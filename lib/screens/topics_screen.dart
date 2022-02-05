// ignore_for_file: use_key_in_widget_constructors

import 'package:flutter/material.dart';
import 'package:study_buddy/database/database.dart';
import 'package:study_buddy/database/subject_data.dart';
import 'package:study_buddy/database/topic_data.dart';
import 'package:study_buddy/screens/cards_screen.dart';
import 'package:study_buddy/widgets/category_button.dart';

class TopicsScreen extends StatefulWidget {
  final SubjectData subject;

  const TopicsScreen({required this.subject});

  @override
  State<TopicsScreen> createState() => _TopicsScreenState();
}

class _TopicsScreenState extends State<TopicsScreen> {
  List<TopicData>? _topics;

  @override
  void initState() {
    super.initState();
    DBHelper.getTopicsOfSubject(widget.subject.id).then((topics) {
      if (topics.length == 1) {
        Navigator.pop(context);
        Navigator.push(context, MaterialPageRoute(builder: (ctx) {
          return CardsScreen(subject: widget.subject, topic: topics[0]);
        }));
        return;
      }
      setState(() => _topics = topics);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.subject.name), centerTitle: true),
      body: _topics == null
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(8.0),
              child: ListView.builder(
                itemCount: _topics!.length,
                itemBuilder: (ctx, i) {
                  return Dismissible(
                    key: UniqueKey(),
                    onDismissed: (_) => _onDismissed(i),
                    confirmDismiss: (_) => _confirmDismiss(i),
                    child: CategoryButton(
                      onPressed: () => _onPressed(i),
                      text: _topics![i].name,
                    ),
                  );
                },
              ),
            ),
    );
  }

  _onDismissed(int i) {
    DBHelper.deleteTopic(_topics![i].id);
    setState(() {
      _topics!.removeAt(i);
    });
  }

  _onPressed(int i) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (ctx) {
          return CardsScreen(
            subject: widget.subject,
            topic: _topics![i],
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
                "Are you sure you want to delete topic ${_topics![i].name}?"),
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
