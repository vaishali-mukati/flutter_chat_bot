
import 'package:flutter/cupertino.dart';

import '../model/message.dart';
import '../providers/chat_provider.dart';
import 'assistant_message.dart';
import 'my_message_widget.dart';

class ChatMessages extends StatelessWidget {
  const ChatMessages({super.key,required this.scrollController,required this.chatProvider});

  final ScrollController scrollController;
  final ChatProvider chatProvider;
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        controller: scrollController,
        itemCount: chatProvider.inChatMessages.length,
        itemBuilder: (context, index) {
          final message = chatProvider.inChatMessages[index];
          return message.role.name == Role.user.name ? MyMessageWidget(
              message: message) :
          AssistantMessageWidget(
            message: message.message.toString(),);
        });
  }
}