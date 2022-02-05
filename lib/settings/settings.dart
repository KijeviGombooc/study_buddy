import 'package:shared_preferences/shared_preferences.dart';
import 'package:study_buddy/settings/study_type.dart';

class Settings {
  static const String _studyTypeKey = "study_type_key";
  static StudyType _studyType = StudyType.normal;

  static StudyType get studyType {
    return _studyType;
  }

  static set studyType(StudyType val) {
    _studyType = val;
    SharedPreferences.getInstance().then(
      (sharedPreferences) => sharedPreferences.setInt(_studyTypeKey, val.index),
    );
  }

  static Future<void> init() async {
    await SharedPreferences.getInstance().then((sharedPreferences) {
      int? studyTypeInt = sharedPreferences.getInt(_studyTypeKey);
      if (studyTypeInt != null &&
          studyTypeInt >= 0 &&
          studyTypeInt < StudyType.values.length) {
        _studyType = StudyType.values[studyTypeInt];
      }
    });
  }
}
