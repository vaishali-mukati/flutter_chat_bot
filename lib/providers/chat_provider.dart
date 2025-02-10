import 'dart:math';
import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart' as path;
import 'package:untitled2/api/api_service.dart';
import 'package:untitled2/constants.dart';
import 'package:untitled2/hive/settings.dart';
import 'package:untitled2/hive/user_model.dart';
import 'package:untitled2/model/message.dart';
import 'package:uuid/uuid.dart';

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

  //setters

  //set inChatMessages
  Future<void> setInChatMessages({required String chatId}) async {
    final messagesFromDB = await loadMessagesFromDB(chatId: chatId);
    for (var message in messagesFromDB) {
      if (inChatMessages.contains(message)) {
        debugPrint('message already exist');
        continue;
      }
      _inChatMessages.add(message);
    }
    notifyListeners();
  }

  // load messages from database
  Future<List<Message>> loadMessagesFromDB({required String chatId}) async {
    //open the box of chat id
    await Hive.openBox('${Constants.chatMessagesBox}$chatId');

    final messageBox = Hive.box('${Constants.chatMessagesBox}$chatId');

    final newData = messageBox.keys.map((e) {
      final message = messageBox.get(e);
      final messageData = Message.fromMap(Map<String, dynamic>.from(message));

      return messageData;
    }).toList();
    notifyListeners();
    return newData;
  }

  // set file list
  void setImagesFileList({required List<XFile> listValue}) {
    _imagesFileList = listValue;
    notifyListeners();
  }

//et the current model
  String setCurrentModel({required String newModel}) {
    _modelType = newModel;
    notifyListeners();
    return newModel;
  }

//function to set the model based on bool -istextOnly

  Future<void> setModel({required bool isTextOnly}) async {
    if (isTextOnly) {
      _model = _textModel ??
          GenerativeModel(
              model: setCurrentModel(newModel: 'gemini-1.0-pro'),
              apiKey: ApiService.apiKey);
    } else {
      _model = _visionModel ??
          GenerativeModel(
              model: setCurrentModel(newModel: 'gemini-pro-vision'),
              apiKey: ApiService.apiKey);
    }
    notifyListeners();
  }

  //set current page index
  void setCurrentIndex({required int newIndex}) {
    _currentIndex = newIndex;
    notifyListeners();
  }

  //set current chat ID
  void setCurrentChatId({required String newChatId}) {
    _currentChatId = newChatId;
    notifyListeners();
  }

//set loading
  void setLoading({required bool value}) {
    _isLoading = value;
    notifyListeners();
  }

  //send message to gemini to get the streamed response
  Future<void> sentMessage(
      {required String message, required bool isTextOnly}) async {
    //set model
    await setModel(isTextOnly: isTextOnly);
    print('---------set model -----${setModel(isTextOnly: isTextOnly)}');
    //set loading
    setLoading(value: true);

    //get chat id
    String chatId = getChatId();

    //list of history messages
    List<Content> history = [];
    history = await getHistory(chatId: chatId);

    //get the images url
    List<String> imagesUrls = getImagesUrl(isTextOnly: isTextOnly);

    //user message id
    final userMessageId  = const Uuid().v4();
    final userMessage = Message(
        messageId: userMessageId,
        chatId: chatId,
        role: Role.user,
        message: StringBuffer(message),
        imageUrls: imagesUrls,
        timeSent: DateTime.now());

    // add this message to the list of inChat messages
    _inChatMessages.add(userMessage);
    notifyListeners();

    if (currentChatId.isEmpty) {
      setCurrentChatId(newChatId: chatId);
    }

    // send message to the model and wait for the response
    await sendMessageAndWaitForResponse(
      message: message,
      chatId: chatId,
      isTextOnly: isTextOnly,
      history: history,
      userMessage: userMessage,
    );
  }

  // send message to the model and wait for the response
  Future<void> sendMessageAndWaitForResponse(
      {required String message,
      required String chatId,
      required bool isTextOnly,
      required List<Content> history,
      required Message userMessage}) async {
    //start the chat session - only send history is its text - only

    final chatSession = _model!.startChat(
      history: history.isEmpty || !isTextOnly ? null : history,
    );
    // get content

    final content = await getContent(message: message, isTextOnly: isTextOnly);

    //assistent message id
      final modelMessageId = const Uuid().v4();
    //assistant message

    final assistantMessage = userMessage.copyWith(
      messageId: modelMessageId,
      role: Role.assistant,
      message: StringBuffer(),
      timeSent: DateTime.now(),
    );

    // add this message to this list on inChatMessage
    _inChatMessages.add(assistantMessage);
    notifyListeners();

    //wait fo stream response
    chatSession.sendMessageStream(content).asyncMap((event) {
      return event;
    }).listen((event) {
      _inChatMessages
          .firstWhere((element) =>
              element.messageId == assistantMessage.messageId &&
              element.role.name == Role.assistant.name)
          .message
          .write(event.text);
      notifyListeners();
    }, onDone: () async{
      //save message to hive Data Base
      setLoading(value: false);

      //set loading to false
    }).onError((error, stackTrace) {
      //set loading o false
      setLoading(value: false);
    });
  }

  Future<Content> getContent(
      {required String message, required bool isTextOnly}) async {
    if (isTextOnly) {
      //generate text from text -only input
      return Content.text(message);
    } else {
      final imageFutures = _imagesFileList
          ?.map((imageFile) => imageFile.readAsBytes())
          .toList(growable: false);

      final imageBytes = await Future.wait(imageFutures!);

      final prompt = TextPart(message);
      final imageParts = imageBytes
          .map((byte) => DataPart('image/jpeg', Uint8List.fromList(byte)))
          .toList();

      return Content.multi([prompt, ...imageParts]);
    }
  }

  // get the images url
  List<String> getImagesUrl({required bool isTextOnly}) {
    List<String> imagesUrls = [];
    if (!isTextOnly && imageFileList != null) {
      for (var image in imageFileList!) {
        imagesUrls.add(image.path);
      }
    }
    return imagesUrls;
  }

  Future<List<Content>> getHistory({required String chatId}) async {
    List<Content> _history = [];
    if (currentChatId.isNotEmpty) {
      await setInChatMessages(chatId: chatId);

      for (var message in inChatMessages) {
        if (message.role == Role.user) {
          _history.add(Content.text(message.message.toString()));
        } else {
          _history.add(Content.model([TextPart(message.message.toString())]));
        }
      }
    }
    return _history;
  }

  String getChatId() {
    if (currentChatId.isEmpty) {
      return const Uuid().v4();
    } else {
      return currentChatId;
    }
  }

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
