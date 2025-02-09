import 'package:flutter/material.dart';

class BottemChatField extends StatefulWidget {
  const BottemChatField({super.key});

  @override
  State<BottemChatField> createState() => _BottemChatFieldState();
}

class _BottemChatFieldState extends State<BottemChatField> {
  //controller for the input field
  final TextEditingController _textEditingController = TextEditingController();

  final FocusNode textFieldFocus = FocusNode();
  //focus node
  @override
  void dispose() {
    _textEditingController.dispose();
    textFieldFocus.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: Theme.of(context).textTheme.titleLarge!.color!,
          ),
        ),
        child: Row(
          children: [
            IconButton(onPressed: () {}, icon: const Icon(Icons.image)),
            const SizedBox(
              width: 5,
            ),
             Expanded(
                child: TextField(
                  focusNode: textFieldFocus,
              controller: _textEditingController,
              textInputAction: TextInputAction.send,
              onSubmitted: (String value){},
              decoration: InputDecoration.collapsed(hintText: 'Enter a prompt...',
              border:OutlineInputBorder(
                borderSide: BorderSide.none,
               borderRadius: BorderRadius.circular(30),
              )),
            )),
            IconButton(
                onPressed: () {
                  // chatProvider.sendMessage();
                },
                icon: const Icon(Icons.send))
          ],
        ));
  }
}
