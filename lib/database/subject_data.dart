class SubjectData {
  final int id;
  final String name;

  SubjectData({required this.id, required this.name});

  static const String tableName = "subjects";
  static const String colId = "subject_row_id";
  static const String colName = "name";
  static const String createTableCommand = """CREATE TABLE $tableName (
                $colId INTEGER PRIMARY KEY,
                $colName TEXT UNIQUE
                )""";
}
