import 'package:flutter/material.dart';
import 'package:my_shop/screens/home/home_screen.dart';
import 'package:my_shop/screens/setting/setting_screen.dart';

class MainNavigator extends StatefulWidget {
  const MainNavigator({super.key});

  @override
  _MainNavigatorState createState() => _MainNavigatorState();
}

class _MainNavigatorState extends State<MainNavigator> {
  int _selectedIndex = 0;

  // Make sure the number of screens matches the bottom navigation items
  final List<Widget> widgetOptions = const [
    HomeScreen(),
    SettingScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widgetOptions[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        selectedItemColor: Colors.amber,
        unselectedItemColor: Colors.blueGrey,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'မူလ',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.verified_user),
            label: 'ပရိုဖိုင်',
          ),
        ],
      ),
    );
  }
}
