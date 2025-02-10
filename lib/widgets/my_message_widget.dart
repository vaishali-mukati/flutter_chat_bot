import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:untitled2/model/message.dart';
import 'package:untitled2/widgets/preview_images_widget.dart';

class MyMessageWidget extends StatelessWidget {
  const MyMessageWidget({super.key,required this.message});

   final Message message;
  @override
  Widget build(BuildContext context) {
    return Align(
        alignment:Alignment.centerRight,
      child: Container(
        constraints: BoxConstraints(
          maxWidth:MediaQuery.of(context).size.width * 0.7,
      ),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(18),
        ),
        padding: const EdgeInsets.all(20),
        margin: const EdgeInsets.only(bottom: 8),
        child: Column(
          children: [
            if(message.imageUrls.isNotEmpty) PreviewImagesWidget(message: message,),
            MarkdownBody(
              data: message.message.toString(),
               selectable: true,
            ),
          ],
        ),
    ));
  }
}
