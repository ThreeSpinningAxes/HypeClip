import 'package:flutter/material.dart';

class BottomNavigation extends StatefulWidget {
  const BottomNavigation({ Key? key }) : super(key: key);

  @override
  _BottomNavigationState createState() => _BottomNavigationState();
}

class _BottomNavigationState extends State<BottomNavigation> {

  int _currentIndex = 0;
  @override
  Widget build(BuildContext context) {
   
      
      return BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        selectedFontSize: 14,
        iconSize: 23,
        selectedItemColor: Color.fromARGB(255, 8, 104, 187),
        unselectedItemColor: Colors.white,

        
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.my_library_music),
            activeIcon: Icon(Icons.my_library_music, size: 28),
            label: 'Library',

          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            activeIcon: Icon(Icons.search, size: 28),
            label: "Explore"
          )
        ],
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      );
  }
}