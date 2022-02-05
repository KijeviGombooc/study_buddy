import 'dart:convert';

import 'package:study_buddy/Exceptions/custom_exception.dart';
import 'package:study_buddy/database/card_data.dart';
import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:study_buddy/database/subject_data.dart';
import 'package:study_buddy/database/topic_data.dart';

class DBHelper {
  static late Database _db;
  static const String _dbName = "study_buddy.db";

  static Future<void> init() async {
    _db = await openDatabase(
      // Set the path to the database. Note: Using the `join` function from the
      // `path` package is best practice to ensure the path is correctly
      // constructed for each platform.
      join(await getDatabasesPath(), _dbName),
      // When the database is first created, create a table to store dogs.
      onCreate: (db, version) async {
        // Run the CREATE TABLE statement on the database.
        await db.execute(SubjectData.createTableCommand);
        await db.execute(TopicData.createTableCommand);
        await db.execute(CardData.createTableCommand);
      },
      // Set the version. This executes the onCreate function and provides a
      // path to perform database upgrades and downgrades.
      version: 1,
    );
  }

  static Future<List<SubjectData>> getSubjects() async {
    List<Map<String, Object?>> maps = await _db.query(
      SubjectData.tableName,
      columns: [SubjectData.colId, SubjectData.colName],
    );

    return List<SubjectData>.generate(maps.length, (i) {
      int? id = maps[i][SubjectData.colId] as int?;
      String? name = maps[i][SubjectData.colName] as String?;
      if (id == null || name == null) print("Error: 'id' or 'name' is null!");

      return SubjectData(id: id as int, name: name as String);
    });
  }

  static Future<List<TopicData>> getTopicsOfSubject(int subjectId) async {
    List<Map<String, Object?>> maps = await _db.query(
      TopicData.tableName,
      columns: [TopicData.colId, TopicData.colName],
      where: "${TopicData.colSubjectRowId} = ?",
      whereArgs: [subjectId],
    );

    return List<TopicData>.generate(maps.length, (i) {
      int? id = maps[i][TopicData.colId] as int?;
      String? name = maps[i][TopicData.colName] as String?;
      if (id == null || name == null) print("Error: 'id' or 'name' is null!");

      return TopicData(id: id as int, name: name as String);
    });
  }

  static Future<List<CardData>> getCardsOfTopic(int topicId) async {
    List<Map<String, Object?>> maps = await _db.query(
      CardData.tableName,
      columns: [CardData.colName, CardData.colDesc],
      where: "${CardData.colTopicRowId} = ?",
      whereArgs: [topicId],
    );

    return List<CardData>.generate(maps.length, (i) {
      String? front = maps[i][CardData.colName] as String?;
      String? back = maps[i][CardData.colDesc] as String?;
      if (front == null || back == null) {
        print("Error: 'name' or 'desc' is null!");
      }

      return CardData(front: front as String, back: back as String);
    });
  }

  static deleteTopic(int topicId) async {
    // delete cards related to topic
    await _db.delete(
      CardData.tableName,
      where: "${CardData.colTopicRowId} = ?",
      whereArgs: [topicId],
    );
    // delete topic
    await _db.delete(
      TopicData.tableName,
      where: "${TopicData.colId} = ?",
      whereArgs: [topicId],
    );
  }

  static deleteSubject(int subjectId) async {
    // go through each topic to delete its cards too
    for (TopicData topic in await getTopicsOfSubject(subjectId)) {
      deleteTopic(topic.id);
    }
    // delete the subject itself
    await _db.delete(
      SubjectData.tableName,
      where: "${SubjectData.colId} = ?",
      whereArgs: [subjectId],
    );
  }

  // static void insertTestData() async {
  //   for (var i = 0; i < 5; i++) {
  //     int subjectId = await insertSubject("Subject ${i + 1}");
  //     if (subjectId == 0) continue;

  //     for (var j = 0; j < 5; j++) {
  //       int topicId = await insertTopic(subjectId, "Topic ${j + 1}");
  //       if (topicId == 0) continue;

  //       for (var k = 0; k < 5; k++) {
  //         await insertCard(topicId, "Card ${k + 1}", "Back: ${k + 1}");
  //       }
  //     }
  //   }
  // }

  static Future<int> tryInsertSubject(String name) async {
    List<Map> res = await _db.query(
      SubjectData.tableName,
      columns: [SubjectData.colId],
      where: "${SubjectData.colName} = ?",
      whereArgs: [name],
    );
    if (res.isNotEmpty) {
      return res[0][SubjectData.colId] as int;
    } else {
      return await _db.insert(
        SubjectData.tableName,
        {SubjectData.colName: name},
      );
    }
  }

  static Future<int> tryInsertTopic(int subjectId, String name) async {
    List<Map> res = await _db.query(
      TopicData.tableName,
      columns: [TopicData.colId],
      where: "${TopicData.colName} = ? AND ${TopicData.colSubjectRowId} = ?",
      whereArgs: [name, subjectId],
    );
    if (res.isNotEmpty) {
      return res[0][TopicData.colId] as int;
    } else {
      return await _db.insert(
        TopicData.tableName,
        {
          TopicData.colSubjectRowId: subjectId,
          TopicData.colName: name,
        },
      );
    }
  }

  static insertCard(int topicId, String front, String back) async {
    return await _db.insert(
      CardData.tableName,
      {
        CardData.colTopicRowId: topicId,
        CardData.colName: front,
        CardData.colDesc: back,
      },
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  static loadFromString(String string) async {
    try {
      Map root = jsonDecode(string);
      Map subjects;
      try {
        subjects = root["Subjects"] as Map;
      } catch (_) {
        throw const CustomException("Root must be 'Subjects'!");
      }

      for (MapEntry subjectEntry in subjects.entries) {
        String subject = subjectEntry.key as String;
        Map topics = subjectEntry.value as Map;
        int subjectId = await tryInsertSubject(subject);

        for (MapEntry topicEntry in topics.entries) {
          String topic = topicEntry.key as String;
          Map cards = topicEntry.value as Map;
          int topicId = await tryInsertTopic(subjectId, topic);

          for (MapEntry cardEntry in cards.entries) {
            String cardFront = cardEntry.key as String;
            String cardBack = cardEntry.value as String;
            await insertCard(topicId, cardFront, cardBack);
          }
        }
      }
    } on CustomException catch (_e) {
      rethrow;
    } on DatabaseException catch (_e) {
      throw const CustomException("Database error.");
    } catch (e) {
      throw const CustomException("Parsing json failed.");
    }
  }
}
