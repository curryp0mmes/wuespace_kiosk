import 'package:flutter/material.dart';
import 'package:wuespace_kiosk/user.dart';
import 'package:wuespace_kiosk/item.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MainScreen(),
    );
  }
}


class MainScreen extends StatefulWidget {
  @override
  MainScreenState createState() => MainScreenState();
}

class MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  Item? selectedItem;

  final List<Widget> _screens;

  MainScreenState() : _screens = [
    ItemListScreen(),
    UserListScreen(isForSelectingUser: false),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void openUserSelectionScreenForItem(Item item) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => UserListScreen(
        isForSelectingUser: true,
        selectedItem: item,
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.store),
            label: 'Items',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Users',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        onTap: _onItemTapped,
      ),
    );
  }
}

