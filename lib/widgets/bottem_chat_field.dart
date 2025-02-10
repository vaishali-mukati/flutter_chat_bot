import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:untitled2/providers/chat_provider.dart';
import 'package:untitled2/utility/utility.dart';
import 'package:untitled2/widgets/preview_images_widget.dart';

class BottomChatField extends StatefulWidget {
  const BottomChatField({super.key, required this.chatProvider});

  final ChatProvider chatProvider;

  @override
  State<BottomChatField> createState() => _BottomChatFieldState();
}

class _BottomChatFieldState extends State<BottomChatField> {
  //controller for the input field
  final TextEditingController _textEditingController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  final FocusNode textFieldFocus = FocusNode();

  //focus node
  @override
  void dispose() {
    _textEditingController.dispose();
    textFieldFocus.dispose();
    super.dispose();
  }

  Future<void> sendChatMessage({required String message,
    required ChatProvider chatProvider,
    required bool isTextOnly}) async {
    try {
      print('error');
      await chatProvider.sentMessage(message: message, isTextOnly: isTextOnly);
    } catch (e) {
      print('error: $e');
    } finally {
      _textEditingController.clear();
      widget.chatProvider.setImagesFileList(listValue: []);
      textFieldFocus.unfocus();
    }
  }

  //initialize image picker
  void pickImage() async {
    try {
      final pickedImage = await _picker.pickMultiImage(
          maxWidth: 800, maxHeight: 800, imageQuality: 95);
      widget.chatProvider.setImagesFileList(listValue: pickedImage);
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    bool hasImages = widget.chatProvider.imageFileList != null &&
        widget.chatProvider.imageFileList!.isNotEmpty;
    return Container(
        decoration: BoxDecoration(
          color: Theme
              .of(context)
              .cardColor,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: Theme
                .of(context)
                .textTheme
                .titleLarge!
                .color!,
          ),
        ),
        child: Column(
          children: [
            if(hasImages) const PreviewImagesWidget(),
            Row(
              children: [
                IconButton(
                    onPressed: () {
                      if (hasImages) {
                        //show the delete dialog
                        showMyAnimatedDialog(context:context,
                            title: 'Delete Images',
                            content: 'Are you sure you want to delete the images',
                            actionText: 'Delete',
                            onActionPresses: (value){
                            widget.chatProvider.setImagesFileList(listValue: []);
                            });
                      } else {
                        pickImage();
                      }
                    },
                    icon: Icon(hasImages ? Icons.delete_forever : Icons.image)),
                const SizedBox(
                  width: 5,
                ),
                Expanded(
                    child: TextField(
                      focusNode: textFieldFocus,
                      controller: _textEditingController,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (String value) {
                        if (value.isNotEmpty) {
                          sendChatMessage(
                              message: _textEditingController.text,
                              chatProvider: widget.chatProvider,
                              isTextOnly: hasImages ? false :true);
                        }
                      },
                      decoration: InputDecoration.collapsed(
                          hintText: 'Enter a prompt...',
                          border: OutlineInputBorder(
                            borderSide: BorderSide.none,
                            borderRadius: BorderRadius.circular(30),
                          )),
                    )),
                GestureDetector(
                  onTap: () {
                    //send the message
                    if (_textEditingController.text.isNotEmpty) {
                      sendChatMessage(
                          message: _textEditingController.text,
                          chatProvider: widget.chatProvider,
                          isTextOnly: hasImages ? false :true);
                    }
                  },
                  child: Container(
                      decoration: BoxDecoration(
                        color: Colors.deepPurple,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      margin: const EdgeInsets.all(5.0),
                      child: const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Icon(
                          Icons.arrow_upward,
                          color: Colors.white,
                        ),
                      )),
                ),
              ],
            ),
          ],
        ));
  }
}
