import 'package:flutter/material.dart';
import 'package:untitled2/screens/chat_history_screen.dart';
import 'package:untitled2/screens/chat_screen.dart';
import 'package:untitled2/screens/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PageController _pageController = PageController();

  final List<Widget> _screens = [
            const ChatHistoryScreen(),
           const ChatScreen(),
           const ProfileScreen()
  ];

  int _currentIndex = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
      ),
      body: PageView(
        controller: _pageController,
        children:_screens,
        onPageChanged: (index){
          setState(() {
            _currentIndex = index;
          });
          _pageController.jumpToPage(index);
        },
      ),
      bottomNavigationBar:BottomNavigationBar(
          currentIndex: _currentIndex,
          elevation: 0,
          selectedItemColor:Theme.of(context).colorScheme.primary ,
          onTap: (index){
            setState(() {
              _currentIndex = index;
            });
            _pageController.jumpToPage(index);
          },
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.history),
              label: 'Chat History',
            ),
            BottomNavigationBarItem(icon: Icon(Icons.chat),
              label: 'Chat',
            ),
            BottomNavigationBarItem(icon: Icon(Icons.person),
              label:'Profile',
            )
          ]) ,
    );
  }
}
