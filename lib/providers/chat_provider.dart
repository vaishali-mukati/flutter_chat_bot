import 'package:flutter/cupertino.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:path_provider/path_provider.dart' as path;
import 'package:untitled2/constants.dart';

import '../hive/chat_history.dart';
class ChatProvider extends ChangeNotifier{
 // init Hive box
  static initHive() async{
    final dir = await path.getApplicationDocumentsDirectory();
    Hive.init(dir.path);
    await Hive.initFlutter(Constants.geminiDB);

    // register adapters
     if(!Hive.isAdapterRegistered(0)){
       Hive.registerAdapter(ChatHistoryAdapter());
       
       //open the chat history box 
       await Hive.openBox<ChatHistory>(Constants.chatHistoryBox);
     }
  }
}