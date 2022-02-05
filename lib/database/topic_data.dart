import 'package:study_buddy/database/subject_data.dart';

class TopicData {
  final int id;
  final String name;

  TopicData({required this.id, required this.name});

  static const String tableName = "topics";
  static const String colId = "topic_row_id";
  static const String colName = "name";
  static const String colSubjectRowId = "subject_row_id";

  static const String createTableCommand = """CREATE TABLE $tableName (
                $colId INTEGER PRIMARY KEY,
                $colName TEXT,
                $colSubjectRowId INTEGER,
                FOREIGN KEY($colSubjectRowId)
                REFERENCES ${SubjectData.tableName}($colId),
                UNIQUE($colSubjectRowId, $colName)
                )""";
}
