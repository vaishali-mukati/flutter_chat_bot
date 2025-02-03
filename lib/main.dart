import 'package:flutter/material.dart';
import 'package:untitled2/screens/home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      // themeMode: ThemeMode.dark,
      //   theme: ThemeData(
      //     brightness: Brightness.light,
      //   ),
      //   darkTheme: ThemeData(
      //     brightness: Brightness.dark,
      //   ),
        debugShowCheckedModeBanner: false,
      home:const HomeScreen()
    );
  }
}
