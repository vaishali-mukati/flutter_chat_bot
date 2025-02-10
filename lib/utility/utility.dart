// animated dialog
import 'package:flutter/material.dart';
void showMyAnimatedDialog({
  required BuildContext context,
   required String title,
   required String content ,
     required String actionText,required Function(bool) onActionPresses})async{

  showGeneralDialog(context: context,
      barrierDismissible: true,
      barrierLabel: '',
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder:(context ,animation, seconderyAnimation) {
        return Container(

        );

      }, transitionBuilder: (context, animation, seconderyAnimation, child) {
        return ScaleTransition(
          scale: Tween<double>(begin: 0.5, end: 1.0).animate(animation),
          child: FadeTransition(
            opacity: animation,
            child: AlertDialog(
              title: Text(
                title,
                textAlign: TextAlign.center,
              ),
              content: Text(
                content,
                textAlign: TextAlign.center,
              ),
              actions: [
                TextButton(
                    onPressed: () {
                      onActionPresses(false);
                      Navigator.of(context).pop();
                    },
                    child: const Text('Cancel')),
                TextButton(
                    onPressed: () {
                      onActionPresses(true);
                      Navigator.of(context).pop();
                    },
                    child: Text(actionText)),
              ],
            ),
          ),
        );
      }
  );

}