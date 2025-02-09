import 'package:flutter/cupertino.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart' as path;
import 'package:untitled2/constants.dart';
import 'package:untitled2/hive/settings.dart';
import 'package:untitled2/hive/user_model.dart';
import 'package:untitled2/model/message.dart';

import '../hive/chat_history.dart';

class ChatProvider extends ChangeNotifier {
  //List of messages

  List<Message> _inChatMessages = [];

  //page controller
  final PageController _pagecontroller = PageController();

  //images file list
  List<XFile>? _imagesFileList = [];

  //index of current screen
  int _currentIndex = 0;

  //current chatid
  String _currentChatId = '';

  //initialize generative model
  GenerativeModel? _model;

  //initialize text model
  GenerativeModel? _textModel;

  //initialize vision model
  GenerativeModel? _visionModel;

  //current model
  String _modelType = 'gemini-pro';

  //loading bool
  bool _isLoading = false;

  //getter
  List<Message> get inChatMessages => _inChatMessages;

  PageController get pageController => _pagecontroller;

  List<XFile>? get imageFileList => _imagesFileList;

  int get currentIndex => _currentIndex;

  String get currentChatId => _currentChatId;

  GenerativeModel? get model => _model;

   GenerativeModel? get textModel => _textModel;

  GenerativeModel? get visionModel => _visionModel;

  String get modelType => _modelType;

  bool get isLoading => _isLoading;

  // init Hive box
  static initHive() async {
    final dir = await path.getApplicationDocumentsDirectory();
    Hive.init(dir.path);
    await Hive.initFlutter(Constants.geminiDB);

    // register adapters
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(ChatHistoryAdapter());

      //open the chat history box
      await Hive.openBox<ChatHistory>(Constants.chatHistoryBox);
    }

    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(UserModelAdapter());
      await Hive.openBox<UserModel>(Constants.userBox);
    }

    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(SettingsAdapter());
      await Hive.openBox<Settings>(Constants.settingsBox);
    }
  }
}
