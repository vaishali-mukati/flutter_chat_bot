import 'package:hive/hive.dart';
import 'package:untitled2/constants.dart';
import 'package:untitled2/hive/chat_history.dart';
import 'package:untitled2/hive/settings.dart';
import 'package:untitled2/hive/user_model.dart';

class Boxes {
  //get chat history box

  static Box<ChatHistory> getChatHistory() =>
      Hive.box<ChatHistory>(Constants.chatHistoryBox);

  // get user box
  static Box<UserModel> getUser() =>
      Hive.box<UserModel>(Constants.userBox);

  //get settings box
  static Box<Settings> getSettings() =>
      Hive.box<Settings>(Constants.settingsBox);
}
