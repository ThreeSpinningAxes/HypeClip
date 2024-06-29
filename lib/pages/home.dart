import 'package:flutter/material.dart';
import 'package:hypeclip/OnBoarding/widgets/Auth.dart';
import 'package:hypeclip/Pages/explore.dart';
import 'package:hypeclip/Pages/library.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List pageController = [Library(), Explore()]; //Library()
  int selectedTabIndex = 0;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
            appBar: AppBar(
              title: Text('HypeClip'),
              centerTitle: true,
              leading: Builder(
                builder: (context) {
                  return IconButton(
                    icon: const Icon(Icons.account_circle_outlined, size: 28),
                    onPressed: () {
                      Scaffold.of(context).openDrawer();
                    },
                  );
                },
              ),
            ),
            bottomNavigationBar: BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.my_library_music),
                  activeIcon: Icon(Icons.my_library_music, size: 28),
                  label: 'Library',
                ),
                BottomNavigationBarItem(
                    icon: Icon(Icons.search),
                    activeIcon: Icon(Icons.search, size: 28),
                    label: "Explore")
              ],
              currentIndex: selectedTabIndex,
              selectedFontSize: 14,
              iconSize: 23,
              selectedItemColor: Color.fromARGB(255, 8, 104, 187),
              unselectedItemColor: Colors.white,
              onTap: (index) {
                setState(() {
                  selectedTabIndex = index;
                });
              },
            ),
            body: pageController[selectedTabIndex],
            drawer: Drawer(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  SizedBox(
                    height: 150, // Set this to your desired height
                    child: const DrawerHeader(
                      decoration: BoxDecoration(
                        color: Color.fromARGB(255, 8, 104, 187),
                      ),
                      child: Text('Profile'),
                    ),
                  ),
                  ListTile(
                    title: const Text('Account Information'),
                    leading: Icon(Icons.account_box),
                    onTap: () {
                      // Update the state of the app.
                      // ...
                    },
                  ),
                  ListTile(
                    title: const Text('Connected Music Accounts'),
                    leading: Icon(Icons.music_note),
                    onTap: () {
                      // Update the state of the app.
                      // ...
                    },
                  ),
                  ListTile(
                    title: const Text('Log out'),
                    leading: Icon(Icons.logout),
                    onTap: () {
                      Auth().signOut();
                      // Update the state of the app.
                      // ...
                    },
                  ),
                ],
              ),
            )));
  }
}
