import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:untitled2/model/message.dart';
import 'package:untitled2/providers/chat_provider.dart';

class PreviewImagesWidget extends StatelessWidget {
  const PreviewImagesWidget({super.key, this.message});

  final Message? message;

  @override
  Widget build(BuildContext context) {
    return Consumer<ChatProvider>(builder: (context, chatProvider, child) {
      final messageToShow =
          message != null ? message!.imageUrls : chatProvider.imageFileList;
      final padding = message != null
          ? EdgeInsets.zero
          : const EdgeInsets.only(left: 8.0, right: 8.0);

      return Padding(
        padding: padding,
        child: SizedBox(
          height: 18,
          child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: messageToShow!.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.fromLTRB(4.0, 8.0, 4.0, 0.0),
                  child: ClipRRect(
                      child: Image.file(
                          File(message != null
                              ? message!.imageUrls[index]
                              : chatProvider.imageFileList![index].path),
                          height: 80,
                          width: 80,
                          fit: BoxFit.cover)),
                );
              }),
        ),
      );
    });
  }
}
