import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:hypeclip/OnBoarding/Registration/connectMusicLibrariesRegistrationPage.dart';
import 'package:hypeclip/Pages/Explore/explore.dart';
import 'package:hypeclip/Pages/library.dart';
import 'package:hypeclip/Services/UserService.dart';


class Home extends StatefulWidget {
  const Home({super.key});

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List pageController = [Library(), Explore()]; //Library()
  List pageNames = ["Library", "Explore"];
  int selectedTabIndex = 0;

  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;
    // Determine the profile picture URL or null if not available
    String? profilePicUrl = user?.photoURL;
    
    return SafeArea(
        child: Scaffold(
            appBar: AppBar(
              title: Text(pageNames[selectedTabIndex], style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white)),
            
              centerTitle: false,
              leading: Builder(
                builder: (context) {
                  return IconButton(
                icon: profilePicUrl != null
                    ? CircleAvatar(
                        backgroundImage: NetworkImage(profilePicUrl),
                        radius: 16, // Adjust the size to fit your AppBar
                      )
                    : const Icon(Icons.account_circle_outlined, size: 28), // Default icon
                onPressed: () {
                  Scaffold.of(context).openDrawer();
                },
              );}
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
            UserAccountsDrawerHeader(
              accountName: Text(Userservice.user.username ?? Userservice.user.email!),
              accountEmail: null, // You can also display the user's email here if you want
              currentAccountPicture: profilePicUrl != null
                  ? CircleAvatar(
                      backgroundImage: NetworkImage(profilePicUrl, ),radius: 16,
                    )
                  : CircleAvatar(
                      backgroundColor: Colors.grey.shade800,
                      child: Icon(Icons.account_circle, size: 28),
                    ),
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 8, 104, 187),
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
                      Navigator.push(context, MaterialPageRoute(builder: (context) => ConnectMusicLibrariesRegistrationPage()));
                      // Update the state of the app.
                      // ...
                    },
                  ),
                  ListTile(
                    title: const Text('Log out'),
                    leading: Icon(Icons.logout),
                    onTap: () async {
                      await Userservice.logout();
                      // Update the state of the app.
                      // ...
                    },
                  ),
                ],
              ),
            )));
  }
}
