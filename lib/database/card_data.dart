import 'package:study_buddy/database/topic_data.dart';

class CardData {
  final String front;
  final String back;

  const CardData({required this.front, required this.back});

  static const String tableName = "cards";
  static const String colId = "card_row_id";
  static const String colName = "name";
  static const String colDesc = "desc";
  static const String colTopicRowId = "topic_row_id";

  static const String createTableCommand = """CREATE TABLE $tableName (
                $colId INTEGER PRIMARY KEY,
                $colName TEXT,
                $colDesc TEXT,
                $colTopicRowId INTEGER,
                FOREIGN KEY($colTopicRowId)
                REFERENCES ${TopicData.tableName}($colId),
                UNIQUE($colTopicRowId, $colName)
                )""";
}
